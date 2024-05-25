Drop schema if exists oper_cfb cascade;
create schema oper_cfb;

set search_path=oper_cfb;

CREATE TABLE Estoque
(
  Quantidade INT NOT NULL,
  IDEstoque INT NOT NULL,
  Prateleira VARCHAR(255) NOT NULL,
  PRIMARY KEY (IDEstoque)
);

CREATE TABLE Fornecedor
(
  CNPJ VARCHAR(25) NOT NULL,
  NomeFornecedor VARCHAR(255) NOT NULL,
  IDForncecedor INT NOT NULL,
  PRIMARY KEY (IDForncecedor)
);

CREATE TABLE Categoria
(
  IDCategoria INT NOT NULL,
  NomeCategoria VARCHAR(255) NOT NULL,
  PRIMARY KEY (IDCategoria)
);

CREATE TABLE Enfermidades
(
  IDEnfermidade INT NOT NULL,
  NomeEnferm VARCHAR(255) NOT NULL,
  DescrEnferm VARCHAR(500) NOT NULL,
  PRIMARY KEY (IDEnfermidade)
);

CREATE TABLE FornEstoque
(
  PrecoCompra FLOAT NOT NULL,
  IDForncecedor INT NOT NULL,
  IDEstoque INT NOT NULL,
  PRIMARY KEY (IDForncecedor, IDEstoque),
  FOREIGN KEY (IDForncecedor) REFERENCES Fornecedor(IDForncecedor),
  FOREIGN KEY (IDEstoque) REFERENCES Estoque(IDEstoque)
);

CREATE TABLE Fornecedor_Telefone
(
  Telefone INT NOT NULL,
  IDForncecedor INT NOT NULL,
  PRIMARY KEY (Telefone, IDForncecedor),
  FOREIGN KEY (IDForncecedor) REFERENCES Fornecedor(IDForncecedor)
);

CREATE TABLE UF
(
  IDUF CHAR(2) NOT NULL,
  NomeUF VARCHAR(100) NOT NULL,
  PRIMARY KEY (IDUF)
);

CREATE TABLE Municipio
(
  IDMunicipio INT NOT NULL,
  NomeMunicipio VARCHAR(255) NOT NULL,
  IDUF CHAR(2) NOT NULL,
  PRIMARY KEY (IDMunicipio, IDUF),
  FOREIGN KEY (IDUF) REFERENCES UF(IDUF)
);

CREATE TABLE Cliente
(
  Bairro VARCHAR(255) NOT NULL,
  Rua VARCHAR(255) NOT NULL,
  NomeCliente VARCHAR(255) NOT NULL,
  Senha VARCHAR(20) NOT NULL,
  IDCliente INT NOT NULL,
  EmailCliente VARCHAR(200) NOT NULL,
  IDMunicipio INT NOT NULL,
  IDUF CHAR(2) NOT NULL,
  PRIMARY KEY (IDCliente),
  FOREIGN KEY (IDMunicipio, IDUF) REFERENCES Municipio(IDMunicipio, IDUF),
  UNIQUE (EmailCliente)
);

CREATE TABLE Produto
(
  IDProduto INT NOT NULL,
  PrecVenda FLOAT NOT NULL,
  NomeProduto VARCHAR(255) NOT NULL,
  DescrProd VARCHAR(500) NOT NULL,
  DtValidade DATE NOT NULL,
  IDEstoque INT NOT NULL,
  IDCliente INT NOT NULL,
  PRIMARY KEY (IDProduto),
  FOREIGN KEY (IDEstoque) REFERENCES Estoque(IDEstoque),
  FOREIGN KEY (IDCliente) REFERENCES Cliente(IDCliente)
);

CREATE TABLE Medicamento
(
  Indicacao VARCHAR(255) NOT NULL,
  Contraindicacao VARCHAR(255) NOT NULL,
  IDProduto INT NOT NULL,
  PRIMARY KEY (IDProduto),
  FOREIGN KEY (IDProduto) REFERENCES Produto(IDProduto)
);

CREATE TABLE Vacina
(
  FabricanteVac VARCHAR(255) NOT NULL,
  IDProduto INT NOT NULL,
  IDCliente INT NOT NULL,
  PRIMARY KEY (IDProduto),
  FOREIGN KEY (IDProduto) REFERENCES Produto(IDProduto),
  FOREIGN KEY (IDCliente) REFERENCES Cliente(IDCliente)
);

CREATE TABLE CliCompraProd
(
  Quantidade INT NOT NULL,
  IDCompra INT NOT NULL,
  DataCompra DATE NOT NULL,
  IDCliente INT NOT NULL,
  IDProduto INT NOT NULL,
  PRIMARY KEY (IDCompra),
  FOREIGN KEY (IDCliente) REFERENCES Cliente(IDCliente),
  FOREIGN KEY (IDProduto) REFERENCES Produto(IDProduto)
);

CREATE TABLE ProdCateg
(
  IDProduto INT NOT NULL,
  IDCategoria INT NOT NULL,
  PRIMARY KEY (IDProduto, IDCategoria),
  FOREIGN KEY (IDProduto) REFERENCES Produto(IDProduto),
  FOREIGN KEY (IDCategoria) REFERENCES Categoria(IDCategoria)
);

CREATE TABLE CliEnferm
(
  DtCadEnferm DATE NOT NULL,
  IDCliente INT NOT NULL,
  IDEnfermidade INT NOT NULL,
  PRIMARY KEY (IDCliente, IDEnfermidade),
  FOREIGN KEY (IDCliente) REFERENCES Cliente(IDCliente),
  FOREIGN KEY (IDEnfermidade) REFERENCES Enfermidades(IDEnfermidade)
);

CREATE TABLE Cliente_TelefoneCliente
(
  TelefoneCliente INT NOT NULL,
  IDCliente INT NOT NULL,
  PRIMARY KEY (TelefoneCliente, IDCliente),
  FOREIGN KEY (IDCliente) REFERENCES Cliente(IDCliente)
);

CREATE TABLE InteracaoMedicamentosa
(
  DescrInteracaoMedicam VARCHAR(255) NOT NULL,
  IDProdutoX INT NOT NULL,
  IDProdutoY INT NOT NULL,
  PRIMARY KEY (IDProdutoX, IDProdutoY),
  FOREIGN KEY (IDProdutoX) REFERENCES Medicamento(IDProduto),
  FOREIGN KEY (IDProdutoY) REFERENCES Medicamento(IDProduto)
);