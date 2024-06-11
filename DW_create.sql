DROP SCHEMA IF EXISTS dw_cfb CASCADE;
CREATE SCHEMA dw_cfb;

SET search_path=dw_cfb;

-- Cliente Dimension
CREATE TABLE Cliente
(
  ClienteID INT NOT NULL,
  NomeCliente VARCHAR(255) NOT NULL,
  EmailCliente VARCHAR(255) NOT NULL,
  Telefone VARCHAR(20) NOT NULL,
  ClienteKey UUID NOT NULL,
  PRIMARY KEY (ClienteKey)
);

-- Endereco Dimension
CREATE TABLE Endereco
(
  Bairro VARCHAR(255) NOT NULL,
  RuaCliente VARCHAR(255) NOT NULL,
  IDMunicipio INT NOT NULL,
  IDUF CHAR(2) NOT NULL,
  Municipio VARCHAR(255) NOT NULL,
  UF VARCHAR(100) NOT NULL,
  PorcentagemDeIdosos DECIMAL(10,2) NOT NULL,
  EnderecoKey UUID NOT NULL,
  PRIMARY KEY (EnderecoKey)
);

-- Medicamento Dimension
CREATE TABLE Medicamento
(
  ProdutoID INT NOT NULL,
  PrecVenda DECIMAL(10,2) NOT NULL,
  NomeProduto VARCHAR(255) NOT NULL,
  DtValidade DATE NOT NULL,
  DescrProd TEXT NOT NULL,
  ProdutoKey UUID NOT NULL,
  PRIMARY KEY (ProdutoKey)
);

-- Calendario Dimension
CREATE TABLE Calendario
(
  DataCompleta DATE NOT NULL,
  DiaSemana VARCHAR(10) NOT NULL,
  Dia INT NOT NULL,
  Mes VARCHAR NOT NULL,
  Ano INT NOT NULL,
  Trimestre INT NOT NULL,
  CalendarioKey UUID NOT NULL,
  PRIMARY KEY (CalendarioKey)
);

-- Receita Fact Table
CREATE TABLE Receita
(
  ReceitaID INT NOT NULL,
  ValorReceita DECIMAL(10,2) NOT NULL,
  QuantMedicamentos INT NOT NULL,
  ProdutoKey UUID NOT NULL,
  EnderecoKey UUID NOT NULL,
  CalendarioKey UUID NOT NULL,
  ClienteKey UUID NOT NULL,
  PRIMARY KEY (ReceitaID),
  FOREIGN KEY (ProdutoKey) REFERENCES Medicamento(ProdutoKey),
  FOREIGN KEY (EnderecoKey) REFERENCES Endereco(EnderecoKey),
  FOREIGN KEY (CalendarioKey) REFERENCES Calendario(CalendarioKey),
  FOREIGN KEY (ClienteKey) REFERENCES Cliente(ClienteKey)
);

-- ReceitaDetalhada Fact Table
CREATE TABLE ReceitaDetalhada
(
  IDPedido INT NOT NULL,
  ValorReceita DECIMAL(10,2) NOT NULL,
  QuantMedicamentos INT NOT NULL,
  HoraPedido TIME NOT NULL,
  ProdutoKey UUID NOT NULL,
  EnderecoKey UUID NOT NULL,
  ClienteKey UUID NOT NULL,
  CalendarioKey UUID NOT NULL,
  PRIMARY KEY (IDPedido),
  FOREIGN KEY (ProdutoKey) REFERENCES Medicamento(ProdutoKey),
  FOREIGN KEY (EnderecoKey) REFERENCES Endereco(EnderecoKey),
  FOREIGN KEY (ClienteKey) REFERENCES Cliente(ClienteKey),
  FOREIGN KEY (CalendarioKey) REFERENCES Calendario(CalendarioKey)
);

-- Categoria Dimension
CREATE TABLE Categoria
(
  CategoriaID INT NOT NULL,
  NomeCategoria VARCHAR(255) NOT NULL,
  PRIMARY KEY (CategoriaID)
);

-- ProdCateg Bridge Table
CREATE TABLE ProdCateg
(
  ProdutoKey UUID NOT NULL,
  CategoriaID INT NOT NULL,
  PRIMARY KEY (ProdutoKey, CategoriaID),
  FOREIGN KEY (ProdutoKey) REFERENCES Medicamento(ProdutoKey),
  FOREIGN KEY (CategoriaID) REFERENCES Categoria(CategoriaID)
);
