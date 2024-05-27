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

-- dimensao Endereco
insert into dw_cfb.Endereco
select
    Bairro,
    Rua,
    IDMunicipio,
    IDUF,
    NomeMunicipio,
    NomeUF,
    gen_random_uuid()
from (
    select distinct
        c.Bairro,
        c.Rua,
        m.IDMunicipio,
        u.IDUF,
        m.NomeMunicipio,
        u.NomeUF
    from
        Cliente c
    left join Municipio m on c.IDMunicipio = m.IDMunicipio
    full join UF u on c.IDUF = u.IDUF
) as distinct_combinations
EXCEPT
SELECT
    Bairro,
    RuaCliente,
    IDMunicipio,
    IDUF,
    Municipio,
    UF,
    EnderecoKey
FROM dw_cfb.Endereco;

-- dimensao Medicamento
INSERT INTO dw_cfb.Medicamento
select
    p.IDProduto,
    p.PrecVenda,
    p.NomeProduto,
    p.DtValidade,
    p.DescrProd,
    gen_random_uuid()
from
    Produto p;

-- Categorias
INSERT INTO dw_cfb.Categoria
select 
    ctg.IDCategoria,
    ctg.NomeCategoria
from 
    Categoria ctg;

INSERT INTO dw_cfb.ProdCateg
select
    dwm.ProdutoKey,
    cat.IDCategoria
from 
    ProdCateg cat inner join dw_cfb.Medicamento dwm on dwm.ProdutoID=cat.IDProduto;

-- dimensao Data
INSERT INTO dw_cfb.Calendario
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
    where cast(t.DataCompra as date) not in (select DataCompleta from dw_cfb.Calendario)
        ) as a;

--

-- CliCompraProd não tem hora

alter table CliCompraProd alter column DataCompra SET data type timestamp with time zone;

INSERT INTO dw_cfb.ReceitaDetalhada
SELECT
    t.IDCompra,
    (p.PrecVenda * t.Quantidade) as ValorReceita,
    t.Quantidade,
    CAST(t.DataCompra AS TIME) as HoraPedido, 
    dwp.ProdutoKey,
    dwe.EnderecoKey,
    dwc.ClienteKey,
    dwcal.CalendarioKey
FROM
    CliCompraProd t 
    INNER JOIN Produto p ON t.IDProduto = p.IDProduto
    INNER JOIN Cliente c ON t.IDCliente = c.IDCliente
    INNER JOIN dw_cfb.Endereco dwe ON c.Rua = dwe.RuaCliente 
                                    AND c.Bairro = dwe.Bairro 
                                    AND c.IDMunicipio = dwe.IDMunicipio 
                                    AND c.IDUF = dwe.IDUF
    INNER JOIN dw_cfb.Cliente dwc ON dwc.ClienteID = c.IDCliente
    INNER JOIN dw_cfb.Medicamento dwp ON dwp.ProdutoID = p.IDProduto
    INNER JOIN dw_cfb.Calendario dwcal ON dwcal.DataCompleta = CAST(t.DataCompra AS DATE)
EXCEPT
SELECT
    IDPedido,
    ValorReceita,
    QuantMedicamentos,
    HoraPedido,
    ProdutoKey,
    EnderecoKey,
    ClienteKey,
    CalendarioKey
FROM dw_cfb.ReceitaDetalhada;
