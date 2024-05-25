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
  UF CHAR(2) NOT NULL,
  IDUF CHAR(2) NOT NULL,
  IDMunicipio INT NOT NULL
);

INSERT INTO Endereco_Completo
select 
    c.Bairro,
    c.Rua,
    m.NomeMunicipio,
    u.NomeUF
    u.IDUF,
    m.IDMunicipio
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

-- CliCompraProd não tem hora

alter table CliCompraProd alter column DataCompra SET data type timestamp with time zone;

insert into dw_cfb.ReceitaDetalhada
select
    t.IDCompra,
    (p.PrecVenda * t.Quantidade) as ValorReceita,
    t.Quantidade,
    t.DataCompra as hora,
    dwp.ProdutoKey,
    dwe.EnderecoKey,
    dwc.ClienteKey,
    dwcal.CalendarioKey
from
    CliCompraProd t inner join Produto p on t.IDProduto = p.IDProduto
    -- inner join -- LIDAR COM A CATEGORIA AINDA
    inner join Cliente c on t.IDCliente = t.IDCliente
    inner join Endereco_Completo e on c.Rua = e.RuaCliente and 
                                    c.Bairro = e.Bairro and
                                    c.IDMunicipio = e.IDMunicipio and
                                    c.IDUF = e.IDUF
    inner join dw_cfb.Cliente dwc on dwc.ClienteID = c.IDCliente
    inner join dw_cfb.Endereco dwe on dwe.EnderecoID = e.EnderecoID
    inner join dw_cfb.Medicamento dwp on dwp.ProdutoID = p.IDProduto
    inner join dw_cfb.Calendario dwcal on dwcal.DataCompleta=cast(t.DataCompra as date)
EXCEPT
SELECT
    ReceitaID,
    ValorReceita,
    QuantMedicamentos,
    HoraPedido,
    ProdutoKey,
    EnderecoKey,
    ClienteKey,
    CalendarioKey
FROM dw_cfb;

    