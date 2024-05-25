set search_path=dw_cfb;

-- TODO truncar do dw aqui

set search_path=oper_cfb;

-- dimensão Cliente
INSERT INTO dw_cfb.Cliente
select 
	c.IDCliente,
	c.NomeCliente,
    c.EmailCliente,
    t.TelefoneCliente,
	gen_random_uuid()
from
	Cliente c left join Cliente_TelefoneCliente t on c.IDCliente = t.IDCliente;

-- Criar tabela que tem todos os endereços
CREATE SEQUENCE endereco_id_seq; -- Cria IDs p endereço

CREATE TABLE Endereco_Completo
(
  EnderecoID INT NOT NULL DEFAULT nextval('endereco_id_seq'),
  Bairro VARCHAR(255) NOT NULL,
  RuaCliente VARCHAR(255) NOT NULL,
  Municipio VARCHAR(255) NOT NULL,
  UF CHAR(2) NOT NULL
);

INSERT INTO Endereco_Completo
select 
    c.Bairro,
    c.Rua,
    m.NomeMunicipio,
    u.NomeUF
from
    Cliente c left join Municipio m on c.IDMunicipio = m.IDMunicipio
    full join UF u on c.IDUF = u.IDUF;

-- dimensao Endereco
INSERT INTO dw_cfb.Endereco
select 
    EnderecoID,
    Bairro,
    RuaCliente,
    Municipio,
    UF,
    gen_random_uuid()
from
    Endereco_Completo;

-- dimensao Medicamento
-- Rever: Categoria não é única por produto!
INSERT INTO dw_cfb.Medicamento
select
    p.IDProduto,
    p.PrecVenda,
    p.NomeProduto,
    p.DtValidade,
    p.DescrProd,
    p.
    gen_random_uuid()
from
    Produto p, ...

-- dimensao Data
insert into dw_cfb.Calendario
select
	a.datacompleta,
	a.diasemana,
	a.dia,
	a.mes,
	a.ano,
	a.trimestre,
    gen_random_uuid()
from (
    select distinct
        cast(t.DataCompra as date) as datacompleta,
        to_char(t.DataCompra, 'DY') as diasemana,
        extract(day from t.DataCompra) as dia,
        to_char(t.DataCompra, 'MM') as mes,
        cast(to_char(t.DataCompra, 'Q')as int) as trimestre,
        extract(year from t.DataCompra) as ano
    from 
        CliCompraProd t 
    where cast(t.DataCompra as date) not in (select DataCompleta from dw_zagi.Calendario)
        ) as a;

--
insert into dw_cfb.Receita
