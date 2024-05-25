--- versão 23/09/2022
Drop schema if exists oper_zagi cascade;
create schema oper_zagi;

set search_path=oper_zagi;

CREATE TABLE Fornecedor
(
  FornID INT NOT NULL,
  FornNome VARCHAR(100) NOT NULL,
  PRIMARY KEY (FornID)
);

CREATE TABLE Cliente
(
  ClienteID INT NOT NULL,
  ClienteNome VARCHAR(255) NOT NULL,
  ClienteCEP VARCHAR(8) NOT NULL,
  PRIMARY KEY (ClienteID)
);

CREATE TABLE Regiao
(
  RegiaoID INT NOT NULL,
  RegiaoNome VARCHAR(100) NOT NULL,
  PRIMARY KEY (RegiaoID)
);

CREATE TABLE Categoria
(
  CategID INT NOT NULL,
  CategNome VARCHAR(100) NOT NULL,
  PRIMARY KEY (CategID)
);

CREATE TABLE Produto
(
  ProdID INT NOT NULL,
  ProdNome VARCHAR(100) NOT NULL,
  ProdPreco money NOT NULL,
  FornID INT NOT NULL,
  CategID INT NOT NULL,
  PRIMARY KEY (ProdID),
  FOREIGN KEY (FornID) REFERENCES Fornecedor(FornID),
  FOREIGN KEY (CategID) REFERENCES Categoria(CategID)
);

CREATE TABLE Loja
(
  LojaID INT NOT NULL,
  LojaCEP VARCHAR(8) NOT NULL,
  RegiaoID INT NOT NULL,
  PRIMARY KEY (LojaID),
  FOREIGN KEY (RegiaoID) REFERENCES Regiao(RegiaoID)
);

CREATE TABLE Trans_de_Venda
(
  TRNVendaID INT NOT NULL,
  TRNVendaData DATE NOT NULL,
  LojaID INT NOT NULL,
  ClienteID INT NOT NULL,
  PRIMARY KEY (TRNVendaID),
  FOREIGN KEY (LojaID) REFERENCES Loja(LojaID),
  FOREIGN KEY (ClienteID) REFERENCES Cliente(ClienteID)
);

CREATE TABLE Incluido_em
(
  QTDProdTransV INT NOT NULL,
  ProdID INT NOT NULL,
  TRNVendaID INT NOT NULL,
  PRIMARY KEY (ProdID, TRNVendaID),
  FOREIGN KEY (ProdID) REFERENCES Produto(ProdID),
  FOREIGN KEY (TRNVendaID) REFERENCES Trans_de_Venda(TRNVendaID)
);

------------------------------------- lab

CREATE TABLE Atendente (
    AtendenteID int  NOT NULL,
    AtendNome varchar(255)  NOT NULL,
    LojaID int  NOT NULL,
    CONSTRAINT Atendente_pk PRIMARY KEY (AtendenteID)
);

COMMENT ON TABLE Atendente IS 'Atendente de caixa';

ALTER TABLE Trans_de_Venda ADD COLUMN Avaliacao int NULL;
ALTER TABLE Trans_de_Venda ADD COLUMN AtendenteID int NULL;

COMMENT ON COLUMN Trans_de_Venda.Avaliacao IS '0-5 estrelas';

ALTER TABLE Atendente ADD CONSTRAINT Atendente_Loja
    FOREIGN KEY (LojaID)
    REFERENCES Loja (LojaID)
;

ALTER TABLE Trans_de_Venda ADD CONSTRAINT Trans_de_Venda_Atendente
    FOREIGN KEY (AtendenteID)
    REFERENCES Atendente (AtendenteID)  