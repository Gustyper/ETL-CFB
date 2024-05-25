/*****

PARTE INCREMENTAL

https://bryteflow.com/postgres-cdc-6-easy-methods-capture-data-changes/#:~:text=5.,%2DAhead%20Log%20(WAL).

****/

Drop schema if exists audit cascade;
create schema audit;
set search_path=audit;


/****
-- Gravar as alterações em uma tabela
****/
create table audit.historico_mudancas_zagi (
schema_name text not null,
table_name text not null,
user_name text,
action_tstamp timestamp with time zone not null default current_timestamp,
action TEXT NOT NULL check (action in ('I','D','U')),
original_data text,
new_data text,
query text
) with (fillfactor=100);


/***

Função de trigger para gravar as alterações de forma geral

****/

CREATE OR REPLACE FUNCTION audit.if_modified_func() RETURNS trigger AS $body$
DECLARE
    v_old_data TEXT;
    v_new_data TEXT;
BEGIN
/*  If this actually for real auditing (where you need to log EVERY action),
then you would need to use something like dblink or plperl that could log outside the transaction,
regardless of whether the transaction committed or rolled back.
*/
    /* This dance with casting the NEW and OLD values to a ROW is not necessary in pg 9.0+ */
if (TG_OP = 'UPDATE') then
v_old_data := ROW(OLD.*);
v_new_data := ROW(NEW.*);
insert into audit.historico_mudancas_zagi (schema_name,table_name,user_name,action,original_data,new_data,query)
values (TG_TABLE_SCHEMA::TEXT,TG_TABLE_NAME::TEXT,session_user::TEXT,substring(TG_OP,1,1),v_old_data,v_new_data, current_query());
RETURN NEW;
elsif (TG_OP = 'DELETE') then
v_old_data := ROW(OLD.*);
insert into audit.historico_mudancas_zagi (schema_name,table_name,user_name,action,original_data,query)
values (TG_TABLE_SCHEMA::TEXT,TG_TABLE_NAME::TEXT,session_user::TEXT,substring(TG_OP,1,1),v_old_data, current_query());
RETURN OLD;
elsif (TG_OP = 'INSERT') then
v_new_data := ROW(NEW.*);
insert into audit.historico_mudancas_zagi (schema_name,table_name,user_name,action,new_data,query)
values (TG_TABLE_SCHEMA::TEXT,TG_TABLE_NAME::TEXT,session_user::TEXT,substring(TG_OP,1,1),v_new_data, current_query());
RETURN NEW;
else
RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - Other action occurred: %, at %',TG_OP,now();
RETURN NULL;
end if;

EXCEPTION
WHEN data_exception THEN
RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - UDF ERROR [DATA EXCEPTION] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
RETURN NULL;
WHEN unique_violation THEN
RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - UDF ERROR [UNIQUE] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
RETURN NULL;
WHEN others THEN
RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - UDF ERROR [OTHER] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
RETURN NULL;
END;
$body$
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, audit;


-- Then create the trigger for your table using the below query,

-- salvando modificações na tabela Trans_de_venda como registro de log
CREATE TRIGGER Trans_de_Venda_if_modified_trg
AFTER INSERT OR UPDATE OR DELETE ON oper_zagi.Trans_de_Venda
FOR EACH ROW EXECUTE PROCEDURE audit.if_modified_func();

-- salvando modificações na tabela incluido_em como registro de log
CREATE TRIGGER incluido_em_if_modified_trg
AFTER INSERT OR UPDATE OR DELETE ON oper_zagi.incluido_em
FOR EACH ROW EXECUTE PROCEDURE audit.if_modified_func();


/***
Trigger para salvar inserções da tabela Trans_de_Venda

***/

Create table audit.ins_Trans_de_Venda as select * from oper_zagi.Trans_de_venda where 1=0; 

CREATE OR REPLACE FUNCTION audit.ins_Trans_de_Venda_func() RETURNS trigger AS $body$
DECLARE
    v_old_data TEXT;
    v_new_data TEXT;
BEGIN
if (TG_OP = 'INSERT') then
v_new_data := ROW(NEW.*);
insert into audit.ins_Trans_de_Venda values (NEW.trnvendaid,NEW.trnvendadata,NEW.lojaid,NEW.clienteid);
RETURN NEW;
else
RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - Other action occurred: %, at %',TG_OP,now();
RETURN NULL;
end if;

EXCEPTION
WHEN data_exception THEN
RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - UDF ERROR [DATA EXCEPTION] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
RETURN NULL;
WHEN unique_violation THEN
RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - UDF ERROR [UNIQUE] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
RETURN NULL;
WHEN others THEN
RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - UDF ERROR [OTHER] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
RETURN NULL;
END;
$body$
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, audit;

-- salvando exatamente a linha recém inserida como uma nova linha em uma tabela "espelho"
CREATE TRIGGER Trans_de_Venda_insert_trg
AFTER INSERT ON oper_zagi.Trans_de_Venda
FOR EACH ROW EXECUTE PROCEDURE audit.ins_Trans_de_Venda_func();

/***
Trigger para salvar inserções da tabela incluido_em

***/

Create table audit.ins_incluido_em as select * from oper_zagi.incluido_em where 1=0; 

CREATE OR REPLACE FUNCTION audit.ins_incluido_em_func() RETURNS trigger AS $body$
BEGIN
if (TG_OP = 'INSERT') then
insert into audit.ins_incluido_em values (NEW.qtdprodtransv,NEW.prodid,NEW.trnvendaid);
RETURN NEW;
else
RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - Other action occurred: %, at %',TG_OP,now();
RETURN NULL;
end if;

EXCEPTION
WHEN data_exception THEN
RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - UDF ERROR [DATA EXCEPTION] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
RETURN NULL;
WHEN unique_violation THEN
RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - UDF ERROR [UNIQUE] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
RETURN NULL;
WHEN others THEN
RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - UDF ERROR [OTHER] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
RETURN NULL;
END;
$body$
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, audit;

-- salvando exatamente a linha recém inserida como uma nova linha em uma tabela "espelho"
CREATE TRIGGER incluido_em_insert_trg
AFTER INSERT ON oper_zagi.incluido_em
FOR EACH ROW EXECUTE PROCEDURE audit.ins_incluido_em_func();


/****
Para o caso de começar do zero, como apagar a trigger?

DROP TRIGGER Trans_de_Venda_if_modified_trg on oper_zagi.Trans_de_Venda;
*****/

-- vamos vender 4 xícaras do DAMA

/*
Produto
 7 | Xícara acorda estudante 

loja
3 | 35400 

Cliente
   3 | Pam  
*/

INSERT INTO oper_zagi.Trans_de_Venda VALUES (7,'2024-03-09 16:51:25-03',3,3);
INSERT INTO oper_zagi.Incluido_em (QTDProdTransV,ProdID,TRNVendaID) VALUES (2,7,7);
-- delete from oper_zagi.Incluido_em where ProdID=7 and TRNVendaID=7;

-- Cliente - exemplo de dimensão
-- salvando modificações na tabela dimensão cliente como registro de log
CREATE TRIGGER cliente_if_modified_trg
AFTER INSERT OR UPDATE OR DELETE ON oper_zagi.cliente
FOR EACH ROW EXECUTE PROCEDURE audit.if_modified_func();


/***
Trigger para salvar inserções da tabela cliente

***/

Create table audit.ins_cliente as select * from oper_zagi.cliente where 1=0;

CREATE OR REPLACE FUNCTION audit.ins_cliente_func() RETURNS trigger AS $body$
BEGIN
if (TG_OP = 'INSERT') then
insert into audit.ins_cliente values (NEW.clienteid,NEW.clientenome,NEW.clientecep);
RETURN NEW;
else
RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - Other action occurred: %, at %',TG_OP,now();
RETURN NULL;
end if;

EXCEPTION
WHEN data_exception THEN
RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - UDF ERROR [DATA EXCEPTION] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
RETURN NULL;
WHEN unique_violation THEN
RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - UDF ERROR [UNIQUE] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
RETURN NULL;
WHEN others THEN
RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - UDF ERROR [OTHER] - SQLSTATE: %, SQLERRM: %',SQLSTATE,SQLERRM;
RETURN NULL;
END;
$body$
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, audit;

-- salvando exatamente a linha recém inserida como uma nova linha em uma tabela "espelho"
CREATE TRIGGER cliente_insert_trg
AFTER INSERT ON oper_zagi.Cliente
FOR EACH ROW EXECUTE PROCEDURE audit.ins_cliente_func();

INSERT INTO oper_zagi.cliente VALUES (4,'Manuela','07461');

/*****

Atualizar calendário

repete a mesma instrução da carga inicial

O resultado esperado é apenas a data das transações que você inseriu depois da carga inicial

******/

insert into dw_zagi.Calendario
select
	gen_random_uuid(),
	a.datacompleta,
	a.diasemana,
	a.dia,
	a.mes,
	a.trimestre,
	a.ano
from (
select distinct
	cast(t.TRNVendaData as date) as datacompleta,
	to_char(t.TRNVendaData, 'DY') as diasemana,
	extract(day from t.TRNVendaData) as dia,
	to_char(t.TRNVendaData, 'MM') as mes,
	cast(to_char(t.TRNVendaData, 'Q')as int) as trimestre,
	extract(year from t.TRNVendaData) as ano
from 
	oper_zagi.Trans_de_Venda t 
where cast(t.TRNVendaData as date) not in (select DataCompleta from dw_zagi.Calendario)
	) as a;


-- atualização do fato vendas
-- tome nota da quantidade de linhas

select * from dw_zagi.Vendas;


-- só funciona se inserir nas duas tabelas: incluido_em e Trans_de_venda

-- MODO 1 - lento apenas novas transações das tabelas de auditoria

--insert into dw_zagi.Vendas
select
	t.TRNVendaID,
	t.TRNVendaData as hora,
	(ie.QTDProdTransV * p.ProdPreco) as ReaisVendidos,
	ie.QTDProdTransV,
	dwp.ChaveProduto,
	dwc.ChaveCliente,
	dwcal.ChaveCalendario as ChaveCalendario,
	dwl.ChaveLoja
from
	audit.ins_Trans_de_Venda t inner join audit.ins_Incluido_em ie on t.TRNVendaID=ie.TRNVendaID
	inner join oper_zagi.Produto p on p.ProdID=ie.ProdID
	inner join oper_zagi.Fornecedor f on f.FornID=p.FornID
	inner join oper_zagi.Categoria c on c.CategID=p.CategID
	inner join oper_zagi.Loja l on l.LojaID=t.LojaID
	inner join oper_zagi.Cliente cli on cli.ClienteID=t.ClienteID
	inner join dw_zagi.Produto dwp on dwp.IDProduto=p.ProdID
	inner join dw_zagi.Loja dwl on dwl.IDLoja=l.LojaID
	inner join dw_zagi.Cliente dwc on dwc.IDCliente=cli.ClienteID
	inner join dw_zagi.Calendario dwcal on dwcal.DataCompleta=cast(t.TRNVendaData as date);


-- MODO 2 - lento a diferença entre a base OPER e o DW - opção mais pesada

-- insert into dw_zagi.Vendas
select
    t.TRNVendaID,
    t.TRNVendaData as hora,
    (ie.QTDProdTransV * p.ProdPreco) as ReaisVendidos,
    ie.QTDProdTransV,
    dwp.ChaveProduto,
    dwc.ChaveCliente,
    dwcal.ChaveCalendario as ChaveCalendario,
    dwl.ChaveLoja,
	-----------------lab
    t.Avaliacao,
    dwa.ChaveAtendente
	--------------------
from
    Trans_de_Venda t inner join Incluido_em ie on t.TRNVendaID=ie.TRNVendaID
    inner join Produto p on p.ProdID=ie.ProdID
    inner join Fornecedor f on f.FornID=p.FornID
    inner join Categoria c on c.CategID=p.CategID
    inner join Loja l on l.LojaID=t.LojaID
    inner join Cliente cli on cli.ClienteID=t.ClienteID
    inner join dw_zagi.Produto dwp on dwp.IDProduto=p.ProdID
    inner join dw_zagi.Loja dwl on dwl.IDLoja=l.LojaID
    inner join dw_zagi.Cliente dwc on dwc.IDCliente=cli.ClienteID
    inner join dw_zagi.Calendario dwcal on dwcal.DataCompleta=cast(t.TRNVendaData as date)
	-----------------lab
    inner join dw_zagi.Atendente dwa on dwa.IDAtendente = t.AtendenteID
	-----------------
EXCEPT
SELECT TID
      ,Hora
      ,ReaisVendidos
      ,UnidadesVendidas
      ,ChaveProduto
      ,ChaveCliente
      ,ChaveCalendario
      ,ChaveLoja
	  -----------------lab
      ,Avaliacao
      ,ChaveAtendente
	  ----------------
  FROM dw_zagi.Vendas;

/****

Se não vier nada, conferir se as tabelas de staging correspondem ao conteúdo incremental.

Usando o MODO 1, depois que você carregou as novas transações, pode truncar as tabelas

Observe que num sistema em produção você teria que programar a limpeza das tabelas de audit para ocorrer com o sistema fora do ar.

*****/

truncate table audit.ins_Incluido_em;
truncate table audit.ins_Trans_de_Venda;

-- Atualizar dimensão cliente
-- MODO 1 apenas, devido à surrogate key
--INSERT INTO dw_zagi.Cliente
select 
	gen_random_uuid(),
	c.ClienteID,
	c.ClienteNome,
	c.ClienteCEP,
	cc.Genero,
	cc.EstadoCivil,
	cc.NivelEducacional,
	cc.CreditoPraca
from
	oper_zagi.CensoCliente cc inner join audit.ins_cliente c on c.ClienteID = cc.IDCliente;

truncate table audit.ins_cliente;

--- montar uma consulta para o fato vendas

create or replace view dw_zagi.FatoVendas as
select 
	v.Hora,v.ReaisVendidos,v.TID,v.UnidadesVendidas,
	p.NomeProduto,p.NomeCategoriaProduto,p.NomeFornecedorProduto,p.PrecoProduto,
	c.Ano,c.DataCompleta,c.DiaMes,c.DiaSemana,c.Mes,c.Trimestre,
	cli.CEPCliente,cli.CreditoPracaCliente,cli.EstadoMaritalCliente,cli.GeneroCliente,cli.NivelEducacionalCliente,cli.NomeCliente,
	l.CEPLoja,l.CheckoutLoja,l.LayoutLoja,l.NomeRegiaoLoja,l.TamanhoLoja
from
	dw_zagi.Vendas v inner join dw_zagi.Calendario c on v.ChaveCalendario=c.ChaveCalendario
	inner join dw_zagi.Cliente cli on cli.ChaveCliente = v.ChaveCliente
	inner join dw_zagi.Produto p on p.ChaveProduto = v.ChaveProduto
	inner join dw_zagi.Loja l on l.ChaveLoja = v.ChaveLoja;

select * from dw_zagi.FatoVendas;

/******

Partir para a parte de dashboard no excel

******/