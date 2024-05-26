Drop schema if exists audit cascade;
create schema audit;
set search_path=audit;

-- Gravar as alterações em uma tabela
create table audit.historico_mudancas_cfb (
schema_name text not null,
table_name text not null,
user_name text,
action_tstamp timestamp with time zone not null default current_timestamp,
action TEXT NOT NULL check (action in ('I','D','U')),
original_data text,
new_data text,
query text
) with (fillfactor=100);

-- Função de trigger para gravar as alterações de forma geral
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
insert into audit.historico_mudancas_cfb (schema_name,table_name,user_name,action,original_data,new_data,query)
values (TG_TABLE_SCHEMA::TEXT,TG_TABLE_NAME::TEXT,session_user::TEXT,substring(TG_OP,1,1),v_old_data,v_new_data, current_query());
RETURN NEW;
elsif (TG_OP = 'DELETE') then
v_old_data := ROW(OLD.*);
insert into audit.historico_mudancas_cfb (schema_name,table_name,user_name,action,original_data,query)
values (TG_TABLE_SCHEMA::TEXT,TG_TABLE_NAME::TEXT,session_user::TEXT,substring(TG_OP,1,1),v_old_data, current_query());
RETURN OLD;
elsif (TG_OP = 'INSERT') then
v_new_data := ROW(NEW.*);
insert into audit.historico_mudancas_cfb (schema_name,table_name,user_name,action,new_data,query)
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

-- salvando modificações na tabela CLiCompraProd como registro de log
CREATE TRIGGER CliCompraProd_if_modified_trg
AFTER INSERT OR UPDATE OR DELETE ON oper_cfb.CliCompraProd
FOR EACH ROW EXECUTE PROCEDURE audit.if_modified_func();

-- Trigger para salvar inserções da tabela CliCompraProd

Create table audit.ins_CliCompraProd as select * from oper_cfb.CliCompraProd where 1=0; 

CREATE OR REPLACE FUNCTION audit.ins_CliCompraProd_func() RETURNS trigger AS $body$
DECLARE
    v_old_data TEXT;
    v_new_data TEXT;
BEGIN
if (TG_OP = 'INSERT') then
v_new_data := ROW(NEW.*);
insert into audit.ins_CliCompraProd values (NEW.IDCompra,NEW.DataCompra,NEW.IDCliente,NEW.IDProduto);
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
CREATE TRIGGER CliCompraProd_insert_trg
AFTER INSERT ON oper_cfb.CliCompraProd
FOR EACH ROW EXECUTE PROCEDURE audit.ins_CliCompraProd_func();


truncate table audit.ins_CliCompraProd;

-- montar uma consulta para o fato vendas

-- Ensure the schema is correctly set
SET search_path=dw_cfb;

-- Create the view for ReceitaDetalhada
CREATE OR REPLACE VIEW dw_cfb.ViewReceitaDetalhada AS
SELECT 
    r.HoraPedido AS Hora,
    r.ValorReceita,
    r.IDPedido AS PedidoID,
    r.QuantMedicamentos,
    p.NomeProduto,
    p.PrecVenda AS PrecoProduto,
    c.Ano,
    c.DataCompleta,
    c.Dia AS DiaMes,
    c.DiaSemana,
    c.Mes,
    c.Trimestre,
    cli.NomeCliente,
    cli.EmailCliente,
    cli.Telefone,
    e.Bairro,
    e.RuaCliente,
    e.Municipio,
    e.UF
FROM
    dw_cfb.ReceitaDetalhada r
    INNER JOIN dw_cfb.Calendario c ON r.CalendarioKey = c.CalendarioKey
    INNER JOIN dw_cfb.Cliente cli ON cli.ClienteKey = r.ClienteKey
    INNER JOIN dw_cfb.Medicamento p ON p.ProdutoKey = r.ProdutoKey
    INNER JOIN dw_cfb.Endereco e ON e.EnderecoKey = r.EnderecoKey;

-- Query the view
SELECT * FROM dw_cfb.ViewReceitaDetalhada;
