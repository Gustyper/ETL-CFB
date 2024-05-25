Drop schema if exists dw_cfb cascade;
create schema dw_cfb;

set search_path=dw_cfb;

CREATE TABLE Cliente
(
  ClienteID INT NOT NULL,
  NomeCliente VARCHAR(255) NOT NULL,
  EmailCliente VARCHAR(255) NOT NULL,
  Telefone VARCHAR(20) NOT NULL,
  ClienteKey INT NOT NULL,
  PRIMARY KEY (ClienteKey)
);

CREATE TABLE Endereco
(
  EnderecoID INT NOT NULL,
  Bairro VARCHAR(255) NOT NULL,
  RuaCliente VARCHAR(255) NOT NULL,
  Municipio VARCHAR(255) NOT NULL,
  UF CHAR(2) NOT NULL,
  EnderecoKey INT NOT NULL ,
  PRIMARY KEY (EnderecoKey)
);

CREATE TABLE Medicamento
(
  ProdutoID INT NOT NULL,
  PrecVenda DECIMAL(10,2) NOT NULL,
  NomeProduto VARCHAR(255) NOT NULL,
  DtValidade DATE NOT NULL,
  DescrProd TEXT NOT NULL,
  Categoria VARCHAR(255) NOT NULL,
  ProdutoKey INT NOT NULL ,
  PRIMARY KEY (ProdutoKey)
);

CREATE TABLE Calendario
(
  DataCompleta DATE NOT NULL,
  DiaSemana VARCHAR(10) NOT NULL,
  Dia INT NOT NULL,
  Mes INT NOT NULL,
  Ano INT NOT NULL,
  Trimestre INT NOT NULL,
  CalendarioKey INT NOT NULL ,
  PRIMARY KEY (CalendarioKey)
);

CREATE TABLE Receita
(
  ReceitaID INT NOT NULL ,
  ValorReceita DECIMAL(10,2) NOT NULL,
  QuantMedicamentos INT NOT NULL,
  ProdutoKey INT NOT NULL,
  EnderecoKey INT NOT NULL,
  CalendarioKey INT NOT NULL,
  ClienteKey INT NOT NULL,
  PRIMARY KEY (ReceitaID),
  FOREIGN KEY (ProdutoKey) REFERENCES Medicamento(ProdutoKey),
  FOREIGN KEY (EnderecoKey) REFERENCES Endereco(EnderecoKey),
  FOREIGN KEY (CalendarioKey) REFERENCES Calendario(CalendarioKey),
  FOREIGN KEY (ClienteKey) REFERENCES Cliente(ClienteKey)
);

CREATE TABLE ReceitaDetalhada
(
  IDPedido INT NOT NULL,
  ValorReceita DECIMAL(10,2) NOT NULL,
  QuantMedicamentos INT NOT NULL,
  HoraPedido TIME NOT NULL,
  ProdutoKey INT NOT NULL,
  EnderecoKey INT NOT NULL,
  ClienteKey INT NOT NULL,
  CalendarioKey INT NOT NULL,
  PRIMARY KEY (IDPedido),
  FOREIGN KEY (ProdutoKey) REFERENCES Medicamento(ProdutoKey),
  FOREIGN KEY (EnderecoKey) REFERENCES Endereco(EnderecoKey),
  FOREIGN KEY (ClienteKey) REFERENCES Cliente(ClienteKey),
  FOREIGN KEY (CalendarioKey) REFERENCES Calendario(CalendarioKey)
);
