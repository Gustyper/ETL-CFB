Drop schema if exists dw_zagi cascade;
create schema dw_zagi;

set search_path=dw_zagi;


CREATE TABLE Produto
(
  ChaveProduto VARCHAR NOT NULL,
  IDProduto INT NOT NULL,
  NomeProduto VARCHAR NOT NULL,
  PrecoProduto money NOT NULL,
  NomeFornecedorProduto VARCHAR NOT NULL,
  NomeCategoriaProduto VARCHAR NOT NULL,
  PRIMARY KEY (ChaveProduto)
);

CREATE TABLE Cliente
(
  ChaveCliente VARCHAR NOT NULL,
  IDCliente INT NOT NULL,
  NomeCliente VARCHAR NOT NULL,
  CEPCliente VARCHAR NOT NULL,
  GeneroCliente CHAR(1) NOT NULL,
  EstadoMaritalCliente VARCHAR NOT NULL,
  NivelEducacionalCliente VARCHAR NOT NULL,
  CreditoPracaCliente INT NOT NULL,
  PRIMARY KEY (ChaveCliente)
);

CREATE TABLE Calendario
(
  ChaveCalendario VARCHAR NOT NULL,
  DataCompleta DATE NOT NULL,
  DiaSemana VARCHAR NOT NULL,
  DiaMes INT NOT NULL,
  Mes VARCHAR NOT NULL,
  Trimestre INT NOT NULL,
  Ano INT NOT NULL,
  PRIMARY KEY (ChaveCalendario)
);

CREATE TABLE Loja
(
  ChaveLoja VARCHAR NOT NULL,
  IDLoja INT NOT NULL,
  CEPLoja VARCHAR NOT NULL,
  NomeRegiaoLoja VARCHAR NOT NULL,
  TamanhoLoja VARCHAR NOT NULL,
  CheckoutLoja VARCHAR NOT NULL,
  LayoutLoja VARCHAR NOT NULL,
  PRIMARY KEY (ChaveLoja)
);

CREATE TABLE Vendas
(
  TID INT NOT NULL,
  Hora DATE NOT NULL,
  ReaisVendidos money NOT NULL,
  UnidadesVendidas INT NOT NULL,
  ChaveProduto VARCHAR NOT NULL,
  ChaveCliente VARCHAR NOT NULL,
  ChaveCalendario VARCHAR NOT NULL,
  ChaveLoja VARCHAR NOT NULL,
  PRIMARY KEY (TID, ChaveProduto),
  FOREIGN KEY (ChaveProduto) REFERENCES Produto(ChaveProduto),
  FOREIGN KEY (ChaveCliente) REFERENCES Cliente(ChaveCliente),
  FOREIGN KEY (ChaveCalendario) REFERENCES Calendario(ChaveCalendario),
  FOREIGN KEY (ChaveLoja) REFERENCES Loja(ChaveLoja)
);

------------------------------------------- lab

CREATE TABLE Atendente (
    ChaveAtendente varchar  NOT NULL,
    IDAtendente int  NOT NULL,
    NomeAtendente varchar(255)  NOT NULL,
    CONSTRAINT Atendente_pk PRIMARY KEY (ChaveAtendente)
);

ALTER TABLE VENDAS ADD COLUMN Avaliacao int NULL;
ALTER TABLE VENDAS ADD COLUMN ChaveAtendente varchar NULL;

ALTER TABLE Vendas ADD CONSTRAINT Vendas_Atendente
    FOREIGN KEY (ChaveAtendente)
    REFERENCES Atendente (ChaveAtendente)  
;