
-----------------------------------------------Cria o esquema
DROP SCHEMA IF EXISTS audit CASCADE;
CREATE SCHEMA audit;

CREATE TABLE audit.historico_mudancas_cfb (
    schema_name TEXT NOT NULL,
    table_name TEXT NOT NULL,
    user_name TEXT,
    action_tstamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
    action TEXT NOT NULL CHECK (action IN ('I', 'D', 'U')),
    original_data TEXT,
    new_data TEXT,
    query TEXT
) with (fillfactor=100);

CREATE TABLE audit.ins_CliCompraProd AS SELECT * FROM oper_cfb.CliCompraProd WHERE 1=0;
CREATE TABLE audit.ins_Cliente AS SELECT * FROM oper_cfb.Cliente WHERE 1=0;
CREATE TABLE audit.ins_Produto AS SELECT * FROM oper_cfb.Produto WHERE 1=0;
CREATE TABLE audit.ins_ProdCateg AS SELECT * FROM oper_cfb.ProdCateg WHERE 1=0;

------------------------------------------------- função geral 
CREATE OR REPLACE FUNCTION audit.if_modified_func() RETURNS TRIGGER AS $body$
DECLARE
    v_old_data TEXT;
    v_new_data TEXT;
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        v_old_data := ROW(OLD.*);
        v_new_data := ROW(NEW.*);
        INSERT INTO audit.historico_mudancas_cfb (schema_name, table_name, user_name, action, original_data, new_data, query)
        VALUES (TG_TABLE_SCHEMA::TEXT, TG_TABLE_NAME::TEXT, session_user::TEXT, SUBSTRING(TG_OP, 1, 1), v_old_data, v_new_data, current_query());
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        v_old_data := ROW(OLD.*);
        INSERT INTO audit.historico_mudancas_cfb (schema_name, table_name, user_name, action, original_data, query)
        VALUES (TG_TABLE_SCHEMA::TEXT, TG_TABLE_NAME::TEXT, session_user::TEXT, SUBSTRING(TG_OP, 1, 1), v_old_data, current_query());
        RETURN OLD;
    ELSIF (TG_OP = 'INSERT') THEN
        v_new_data := ROW(NEW.*);
        INSERT INTO audit.historico_mudancas_cfb (schema_name, table_name, user_name, action, new_data, query)
        VALUES (TG_TABLE_SCHEMA::TEXT, TG_TABLE_NAME::TEXT, session_user::TEXT, SUBSTRING(TG_OP, 1, 1), v_new_data, current_query());
        RETURN NEW;
    ELSE
        RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - Other action occurred: %, at %', TG_OP, NOW();
        RETURN NULL;
    END IF;
EXCEPTION
    WHEN data_exception THEN
        RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - UDF ERROR [DATA EXCEPTION] - SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
        RETURN NULL;
    WHEN unique_violation THEN
        RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - UDF ERROR [UNIQUE] - SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE WARNING '[AUDIT.IF_MODIFIED_FUNC] - UDF ERROR [OTHER] - SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
        RETURN NULL;
END;
$body$
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, audit;

---------------------------------------------------------- trigger especifico CliCompraProd

CREATE OR REPLACE FUNCTION audit.ins_CliCompraProd_func() RETURNS trigger AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit.ins_CliCompraProd (Quantidade, IDCompra, DataCompra, IDCliente, IDProduto)
        VALUES (NEW.Quantidade, NEW.IDCompra, NEW.DataCompra, NEW.IDCliente, NEW.IDProduto);
        RETURN NEW;
    ELSE
        RAISE WARNING '[AUDIT.INS_CLICOMPRAPROD_FUNC] - Other action occurred: %, at %', TG_OP, now();
        RETURN NULL;
    END IF;
EXCEPTION
    WHEN data_exception THEN
        RAISE WARNING '[AUDIT.INS_CLICOMPRAPROD_FUNC] - UDF ERROR [DATA EXCEPTION] - SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
        RETURN NULL;
    WHEN unique_violation THEN
        RAISE WARNING '[AUDIT.INS_CLICOMPRAPROD_FUNC] - UDF ERROR [UNIQUE] - SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE WARNING '[AUDIT.INS_CLICOMPRAPROD_FUNC] - UDF ERROR [OTHER] - SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
        RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, audit;

-- Cria o trigger
DROP TRIGGER IF EXISTS CliCompraProd_if_modified_trg ON oper_cfb.CliCompraProd;

CREATE TRIGGER CliCompraProd_if_modified_trg
AFTER INSERT OR UPDATE OR DELETE ON oper_cfb.CliCompraProd
FOR EACH ROW EXECUTE FUNCTION audit.ins_CliCompraProd_func();

---------------------------------------------------------- trigger especifico Cliente

CREATE OR REPLACE FUNCTION audit.ins_Cliente_func() RETURNS trigger AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit.ins_Cliente (Bairro, Rua, NomeCliente, Senha, IDCliente, EmailCliente, IDMunicipio, IDUF)
        VALUES (NEW.Bairro, NEW.Rua, NEW.NomeCliente, NEW.Senha, NEW.IDCliente, NEW.EmailCliente, NEW.IDMunicipio, NEW.IDUF);
        RETURN NEW;
    ELSE
        RAISE WARNING '[AUDIT.INS_CLIENTE_FUNC] - Other action occurred: %, at %', TG_OP, now();
        RETURN NULL;
    END IF;
EXCEPTION
    WHEN data_exception THEN
        RAISE WARNING '[AUDIT.INS_CLIENTE_FUNC] - UDF ERROR [DATA EXCEPTION] - SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
        RETURN NULL;
    WHEN unique_violation THEN
        RAISE WARNING '[AUDIT.INS_CLIENTE_FUNC] - UDF ERROR [UNIQUE] - SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE WARNING '[AUDIT.INS_CLIENTE_FUNC] - UDF ERROR [OTHER] - SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
        RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, audit;

-- Cria o trigger
DROP TRIGGER IF EXISTS Cliente_insert_trg ON oper_cfb.Cliente;

CREATE TRIGGER Cliente_insert_trg
AFTER INSERT OR UPDATE OR DELETE ON oper_cfb.Cliente
FOR EACH ROW EXECUTE FUNCTION audit.ins_Cliente_func();

---------------------------------------------------------- trigger especifico Produto

CREATE OR REPLACE FUNCTION audit.ins_Produto_func() RETURNS trigger AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit.ins_Produto (IDProduto, PrecVenda, NomeProduto, DescrProd, DtValidade, IDEstoque, IDCliente)
        VALUES (NEW.IDProduto, NEW.PrecVenda, NEW.NomeProduto, NEW.DescrProd, NEW.DtValidade, NEW.IDEstoque, NEW.IDCliente);
        RETURN NEW;
    ELSE
        RAISE WARNING '[AUDIT.INS_PRODUTO_FUNC] - Other action occurred: %, at %', TG_OP, now();
        RETURN NULL;
    END IF;
EXCEPTION
    WHEN data_exception THEN
        RAISE WARNING '[AUDIT.INS_PRODUTO_FUNC] - UDF ERROR [DATA EXCEPTION] - SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
        RETURN NULL;
    WHEN unique_violation THEN
        RAISE WARNING '[AUDIT.INS_PRODUTO_FUNC] - UDF ERROR [UNIQUE] - SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE WARNING '[AUDIT.INS_PRODUTO_FUNC] - UDF ERROR [OTHER] - SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
        RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, audit;

-- Cria o trigger
DROP TRIGGER IF EXISTS Produto_insert_trg ON oper_cfb.Produto;

CREATE TRIGGER Produto_insert_trg
AFTER INSERT OR UPDATE OR DELETE ON oper_cfb.Produto
FOR EACH ROW EXECUTE FUNCTION audit.ins_Produto_func();

---------------------------------------------------------- trigger especifico Produto-Categoria

CREATE OR REPLACE FUNCTION audit.ins_ProdCateg_func() RETURNS trigger AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit.ins_ProdCateg (IDProduto, IDCategoria)
        VALUES (NEW.IDProduto, NEW.IDCategoria);
        RETURN NEW;
    ELSE
        RAISE WARNING '[AUDIT.INS_PRODCATEG_FUNC] - Other action occurred: %, at %', TG_OP, now();
        RETURN NULL;
    END IF;
EXCEPTION
    WHEN data_exception THEN
        RAISE WARNING '[AUDIT.INS_PRODCATEG_FUNC] - UDF ERROR [DATA EXCEPTION] - SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
        RETURN NULL;
    WHEN unique_violation THEN
        RAISE WARNING '[AUDIT.INS_PRODCATEG_FUNC] - UDF ERROR [UNIQUE] - SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE WARNING '[AUDIT.INS_PRODCATEG_FUNC] - UDF ERROR [OTHER] - SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
        RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, audit;

-- Cria o trigger
DROP TRIGGER IF EXISTS ProdCateg_insert_trg ON oper_cfb.ProdCateg;

CREATE TRIGGER ProdCateg_insert_trg
AFTER INSERT ON oper_cfb.ProdCateg
FOR EACH ROW EXECUTE FUNCTION audit.ins_ProdCateg_func();

------------------------------------------ atualizações DW

SET search_path = oper_cfb;

INSERT INTO UF (IDUF, NomeUF) VALUES ('RS', 'Rio Grande do Sul');
INSERT INTO Municipio (IDMunicipio, NomeMunicipio, IDUF) VALUES (10, 'Cachoeirinha', 'RS');
INSERT INTO Cliente (Bairro, Rua, NomeCliente, Senha, IDCliente, EmailCliente, IDMunicipio, IDUF) VALUES ('Morada do Vale', 'Morada do Vale', 'Júlio Chavez', '****', 100, 'julio.cesar.chaves@prof.fgv.edu.br', 10, 'RS');
INSERT INTO Cliente_TelefoneCliente (TelefoneCliente, IDCliente) VALUES (991120291, 100);
INSERT INTO Produto (IDProduto, PrecVenda, NomeProduto, DescrProd, DtValidade, IDEstoque, IDCliente) VALUES (69, 500.00, 'Trembolona', 'Anabolizante', '1978-10-10', 2, 100);
INSERT INTO CliCompraProd (Quantidade, IDCompra, DataCompra, IDCliente, IDProduto) VALUES (999, 15, '2030-05-30', 100, 50);

set search_path=oper_cfb;

-- Atualiza o Cliente
INSERT INTO dw_cfb.Cliente
select 
	c.IDCliente,
	c.NomeCliente,
    c.EmailCliente,
    t.TelefoneCliente,
	gen_random_uuid()
from
	audit.ins_Cliente c left join Cliente_TelefoneCliente t on c.IDCliente = t.IDCliente;

-- Atualiza o Calendario
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
        audit.ins_CliCompraProd t 
    where cast(t.DataCompra as date) not in (select DataCompleta from dw_cfb.Calendario)
        ) as a;

-- Atualiza o Medicamento
INSERT INTO dw_cfb.Medicamento
select
    p.IDProduto,
    p.PrecVenda,
    p.NomeProduto,
    p.DtValidade,
    p.DescrProd,
    gen_random_uuid()
from
    audit.ins_Produto p;

-- Atualiza as Categorias
INSERT INTO dw_cfb.ProdCateg
select
    dwm.ProdutoKey,
    cat.IDCategoria
from 
    audit.ins_ProdCateg cat inner join dw_cfb.Medicamento dwm on dwm.ProdutoID=cat.IDProduto;

-- Atualiza o Endereco
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
        audit.ins_Cliente c
    left join Municipio m on c.IDMunicipio = m.IDMunicipio
    inner join UF u on c.IDUF = u.IDUF
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

-- Atualiza a ReceitaDetalhada
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
    audit.ins_CliCompraProd t
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

TRUNCATE TABLE audit.ins_CliCompraProd;
TRUNCATE TABLE audit.ins_Cliente;
TRUNCATE TABLE audit.ins_Produto;
TRUNCATE TABLE audit.ins_ProdCateg;
