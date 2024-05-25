
/************************************************************            
						ATENÇÃO!
Por favor, leia cuidadosamente todo o código antes de executá-lo.

1. Rode o script em partes e valide cada ponto.
2. Leia as referências passadas como comentários.

************************************************************/
/*****

Rode apenas depois de rodar os scripts: 

DDL create tables Lojas ZAGI PT BR.sql
DML insert Lojas ZAGI PT BR.sql
DW ZAGI PT BR.sql

Siga atentamente os passos abaixo.

*****/

set search_path=dw_zagi;

-- Truncar todas as tabelas do DW, caso já existam

truncate table Vendas;
delete from Calendario;
delete from Cliente;
delete from Loja;
delete from Produto;

set search_path=oper_zagi;

---carga da tabela do censo (fonte externa)
CREATE TABLE CensoCliente(
	IDCliente int NOT NULL,
	Genero char(1) NOT NULL,
	EstadoCivil varchar(20) NOT NULL,
	NivelEducacional varchar(50) NOT NULL,
	CreditoPraca int NOT NULL,
	PRIMARY KEY  (IDCliente) );

INSERT INTO CensoCliente values
(1,'M','Solteiro','Graduação',700),
(2,'F','Solteiro','Mestrado',650),
(3,'F','Casado','Graduação',623),
(4,'F','Casado','Doutorado',750),
(5,'M','Solteiro','Primário',680),
(6,'F','Casado','Graduação',500),
(7,'M','Solteiro','Mestrado',560),
(8,'M','Casado','Graduação',640),
(9,'M','Solteiro','Graduação',590),
(10,'F','Solteiro','Primário',680);


-- \echo Observe a quantidade de linhas com full join e com inner join
-- \echo Por que ocorre isso?
-- \echo Por que você pode usar com o inner ou com o full join? E qual você deve usar nesse caso?

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
	CensoCliente cc full join Cliente c on c.ClienteID = cc.IDCliente;

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
	CensoCliente cc inner join Cliente c on c.ClienteID = cc.IDCliente;

INSERT INTO dw_zagi.Cliente
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
	CensoCliente cc inner join Cliente c on c.ClienteID = cc.IDCliente;

-- \echo Dimensão de lojas vazia
select * from dw_zagi.Loja;

/****

Base da carga da base de dados da área de facilities.

****/

CREATE TABLE Layout(
	IDLayout char(1) NOT NULL,
	DescricaoLayout varchar NOT NULL,
	PRIMARY KEY (IDLayout) 
);

INSERT INTO Layout
     VALUES
	('M','Moderno'),
	('T','Tradicional');

CREATE TABLE SistemaCheckout(
	IDSCheckout char(3) NOT NULL,
	SistemaCheckout varchar NOT NULL,
PRIMARY KEY (IDSCheckout)
);

INSERT INTO SistemaCheckout VALUES
('AS','Auto-serviço'),
('CX','Caixa'),
('MX','Misto');

CREATE TABLE LojaDBOper(
	IDLoja int NOT NULL,
	Tamanhom2 int NOT NULL,
	IDSCheckout char(3) NOT NULL,
	IDLayout char(1) NOT NULL,
PRIMARY KEY (IDLoja));

ALTER TABLE LojaDBOper ADD CONSTRAINT fk_layout_em_loja
FOREIGN KEY(IDLayout) REFERENCES Layout (IDLayout);

ALTER TABLE LojaDBOper ADD CONSTRAINT fk_checkout_em_loja
FOREIGN KEY(IDSCheckout) REFERENCES SistemaCheckout (IDSCheckout);

INSERT INTO LojaDBOper
     VALUES
	(1,51000,'CX','M'),
	(2,35000,'AS','T'),
	(3,55000,'MX','T');

-- \echo Carregando a dimensão Loja - por que o uso do left e do full?

select
	gen_random_uuid(),
	l.LojaID,
	l.LojaCEP,
	r.RegiaoNome,
	lo.Tamanhom2,
	sc.sistemacheckout,
	lt.DescricaoLayout
from
	Loja l left join Regiao r on r.RegiaoID=l.RegiaoID
	full join LojaDBOper lo on lo.IDLoja=l.LojaID
	full join SistemaCheckout sc on sc.IDSCheckout = lo.IDSCheckout
	full join Layout lt on lt.IDLayout=lo.IDLayout;

INSERT INTO dw_zagi.Loja
select
	gen_random_uuid(),
	l.LojaID,
	l.LojaCEP,
	r.RegiaoNome,
	lo.Tamanhom2,
	sc.sistemacheckout,
	lt.DescricaoLayout
from
	Loja l left join Regiao r on r.RegiaoID=l.RegiaoID
	full join LojaDBOper lo on lo.IDLoja=l.LojaID
	full join SistemaCheckout sc on sc.IDSCheckout = lo.IDSCheckout
	full join Layout lt on lt.IDLayout=lo.IDLayout;

-- \echo Carga da dimensão Produto
-- \echo Por que o uso do LEFT join?

INSERT INTO dw_zagi.Produto
select
	gen_random_uuid(),
	p.ProdID,
	p.ProdNome,
	p.ProdPreco,
	f.FornNome,
	c.CategNome
from
	Produto p left outer join Fornecedor f on f.FornID=p.FornID
	left outer join Categoria c on c.CategID=p.CategID;

-- Calendário, insere com valores distintos de transação , para facilitar

--------------------------------------------- lab
-------------------------------------------------

insert into dw_zagi.Atendente
select
    gen_random_uuid(),
    a.AtendenteID,
    a.AtendNome
from
    oper_zagi.Atendente a;

----------------------------------------------
-----------------------------------------------

-- carregar apenas as datas novas
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
	Trans_de_Venda t 
where cast(t.TRNVendaData as date) not in (select DataCompleta from dw_zagi.Calendario)
	) as a;

-- Vendas
-- transação de venda não tem hora

alter table Trans_de_Venda alter column TRNVendaData SET data type timestamp with time zone;
-- mudar valores pra trazer hora
-- #21

-- \echo Atenção para carregar o fato vendas

select * from dw_zagi.Vendas;

-- \echo É necessário compatibilizar os tipos de dados time zone

alter table dw_zagi.Vendas alter column hora SET data type timestamp with time zone;

-- \echo O que faz o EXCEPT na instrução abaixo

insert into dw_zagi.Vendas
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
EXCEPT -- esse vai tirar as linhas que JÁ estão na tabela de vendas
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

---- validando ....

Select * from dw_zagi.Vendas;

-- \ echo a quantidade de linhas da instrução abaixo precisa ser a mesma que você acabou de carregar no fato vendas 

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

-----------------------------------------------------------lab
ALTER TABLE VENDAS ALTER COLUMN Avaliacao SET NOT NULL;
ALTER TABLE VENDAS ALTER COLUMN ChaveAtendente SET NOT NULL;
-----------------------------------------------------------