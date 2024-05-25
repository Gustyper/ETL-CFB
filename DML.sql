set search_path=oper_cfb;

INSERT INTO Estoque (Quantidade, IDEstoque, Prateleira) VALUES (100, 1, 'A1');
INSERT INTO Estoque (Quantidade, IDEstoque, Prateleira) VALUES (150, 2, 'B2');
INSERT INTO Estoque (Quantidade, IDEstoque, Prateleira) VALUES (125, 3, 'C3');
INSERT INTO Estoque (Quantidade, IDEstoque, Prateleira) VALUES (200, 4, 'D4');
INSERT INTO Estoque (Quantidade, IDEstoque, Prateleira) VALUES (100, 5, 'E5');


INSERT INTO Fornecedor (CNPJ, NomeFornecedor, IDForncecedor) VALUES ('123456789', 'Fornecedor ABC', 1);
INSERT INTO Fornecedor (CNPJ, NomeFornecedor, IDForncecedor) VALUES ('987654321', 'Fornecedor XYZ', 2);
INSERT INTO Fornecedor (CNPJ, NomeFornecedor, IDForncecedor) VALUES ('555444333', 'Fornecedor XXX', 3);
INSERT INTO Fornecedor (CNPJ, NomeFornecedor, IDForncecedor) VALUES ('222333444', 'Fornecedor ZZZ', 4);


INSERT INTO Categoria (IDCategoria, NomeCategoria) VALUES (1, 'Analgésico');
INSERT INTO Categoria (IDCategoria, NomeCategoria) VALUES (2, 'Antibiótico');
INSERT INTO Categoria (IDCategoria, NomeCategoria) VALUES (3, 'Anti-inflamatório');
INSERT INTO Categoria (IDCategoria, NomeCategoria) VALUES (4, 'Vacina Viral');
INSERT INTO Categoria (IDCategoria, NomeCategoria) VALUES (5, 'Vacina Bacteriana');


INSERT INTO Enfermidades (IDEnfermidade, NomeEnferm, DescrEnferm) VALUES (1, 'Dor de Cabeça', 'Dor na região da cabeça.');
INSERT INTO Enfermidades (IDEnfermidade, NomeEnferm, DescrEnferm) VALUES (2, 'Gripe', 'Infecção viral comum.');
INSERT INTO Enfermidades (IDEnfermidade, NomeEnferm, DescrEnferm) VALUES (3, 'Dor nas Costas', 'Desconforto ou dor na região das costas.');
INSERT INTO Enfermidades (IDEnfermidade, NomeEnferm, DescrEnferm) VALUES (4, 'Rinite Alérgica', 'Inflamação nasal causada por alergias a substâncias como pólen, poeira ou pelos de animais.');
INSERT INTO Enfermidades (IDEnfermidade, NomeEnferm, DescrEnferm) VALUES (5, 'Gastrite', 'Inflamação da mucosa do estômago, muitas vezes causada por infecção bacteriana por H. pylori ou uso excessivo de álcool.');
INSERT INTO Enfermidades (IDEnfermidade, NomeEnferm, DescrEnferm) VALUES (6, 'Pneumonia', 'Infecção dos pulmões geralmente causada por bactérias, vírus ou fungos.');


INSERT INTO FornEstoque (PrecoCompra, IDForncecedor, IDEstoque) VALUES (5000, 1, 1);
INSERT INTO FornEstoque (PrecoCompra, IDForncecedor, IDEstoque) VALUES (7000, 1, 2);
INSERT INTO FornEstoque (PrecoCompra, IDForncecedor, IDEstoque) VALUES (2500, 2, 3);
INSERT INTO FornEstoque (PrecoCompra, IDForncecedor, IDEstoque) VALUES (2000, 3, 4);
INSERT INTO FornEstoque (PrecoCompra, IDForncecedor, IDEstoque) VALUES (3500, 4, 5);


INSERT INTO Fornecedor_Telefone (Telefone, IDForncecedor) VALUES (123456789, 1);
INSERT INTO Fornecedor_Telefone (Telefone, IDForncecedor) VALUES (111222333, 2);
INSERT INTO Fornecedor_Telefone (Telefone, IDForncecedor) VALUES (777888999, 3);
INSERT INTO Fornecedor_Telefone (Telefone, IDForncecedor) VALUES (888999000, 4);


INSERT INTO UF (IDUF, NomeUF) VALUES ('SP', 'São Paulo');
INSERT INTO UF (IDUF, NomeUF) VALUES ('RJ', 'Rio de Janeiro');
INSERT INTO UF (IDUF, NomeUF) VALUES ('MG', 'Minas Gerais');
INSERT INTO UF (IDUF, NomeUF) VALUES ('BA', 'Bahia');


INSERT INTO Municipio (IDMunicipio, NomeMunicipio, IDUF) VALUES (1, 'São Paulo', 'SP');
INSERT INTO Municipio (IDMunicipio, NomeMunicipio, IDUF) VALUES (2, 'Rio de Janeiro', 'RJ');
INSERT INTO Municipio (IDMunicipio, NomeMunicipio, IDUF) VALUES (3, 'Belo Horizonte', 'MG');
INSERT INTO Municipio (IDMunicipio, NomeMunicipio, IDUF) VALUES (4, 'Salvador', 'BA');
INSERT INTO Municipio (IDMunicipio, NomeMunicipio, IDUF) VALUES (5, 'Niterói', 'RJ');
INSERT INTO Municipio (IDMunicipio, NomeMunicipio, IDUF) VALUES (6, 'Guarujá', 'SP');


INSERT INTO Cliente (Bairro, Rua, NomeCliente, Senha, IDCliente, EmailCliente, IDMunicipio, IDUF) VALUES ('Centro', 'Rua A', 'João Silva', 'senha123', 1, 'joao@gmail.com', 1, 'SP');
INSERT INTO Cliente (Bairro, Rua, NomeCliente, Senha, IDCliente, EmailCliente, IDMunicipio, IDUF) VALUES ('Copacabana', 'Avenida X', 'Maria Santos', 'senha456', 2, 'maria@gmail.com', 2, 'RJ');
INSERT INTO Cliente (Bairro, Rua, NomeCliente, Senha, IDCliente, EmailCliente, IDMunicipio, IDUF) VALUES ('Centro', 'Rua B', 'Pedro Oliveira', 'senha789', 3, 'pedro@gmail.com', 3, 'MG');
INSERT INTO Cliente (Bairro, Rua, NomeCliente, Senha, IDCliente, EmailCliente, IDMunicipio, IDUF) VALUES ('Barra', 'Avenida Y', 'Ana Oliveira', 'senha987', 4, 'ana@gmail.com', 4, 'BA');
INSERT INTO Cliente (Bairro, Rua, NomeCliente, Senha, IDCliente, EmailCliente, IDMunicipio, IDUF) VALUES ('Vila Mariana', 'Rua C', 'Carlos Souza', 'senha321', 5, 'carlos@gmail.com', 5, 'RJ');
INSERT INTO Cliente (Bairro, Rua, NomeCliente, Senha, IDCliente, EmailCliente, IDMunicipio, IDUF) VALUES ('Ipanema', 'Avenida Z', 'Ana Paula', 'senha654', 6, 'anapaula@gmail.com', 2, 'RJ');
INSERT INTO Cliente (Bairro, Rua, NomeCliente, Senha, IDCliente, EmailCliente, IDMunicipio, IDUF) VALUES ('Vila Nova', 'Rua D', 'Luiz Fernandes', 'senha012', 7, 'luiz@gmail.com', 6, 'SP');
INSERT INTO Cliente (Bairro, Rua, NomeCliente, Senha, IDCliente, EmailCliente, IDMunicipio, IDUF) VALUES ('Itapuã', 'Avenida W', 'Mariana Silva', 'senha789', 8, 'mariana@gmail.com', 4, 'BA');


INSERT INTO Produto (IDProduto, PrecVenda, NomeProduto, DescrProd, DtValidade, IDEstoque, IDCliente) VALUES (1, 15.99, 'Paracetamol', 'Alívio temporário da febre e dor de cabeça.', '2024-12-31', 2, 1);
INSERT INTO Produto (IDProduto, PrecVenda, NomeProduto, DescrProd, DtValidade, IDEstoque, IDCliente) VALUES (2, 19.99, 'Ibuprofeno', 'Alívio temporário de dores leves a moderadas.', '2024-12-31', 3, 3);
INSERT INTO Produto (IDProduto, PrecVenda, NomeProduto, DescrProd, DtValidade, IDEstoque, IDCliente) VALUES (3, 10.99, 'Dipirona', 'Analgésico e antipirético.', '2024-12-31', 4, 4);
INSERT INTO Produto (IDProduto, PrecVenda, NomeProduto, DescrProd, DtValidade, IDEstoque, IDCliente) VALUES (4, 25.99, 'Nimesulida', 'Anti-inflamatório e analgésico.', '2024-12-31', 1, 5);
INSERT INTO Produto (IDProduto, PrecVenda, NomeProduto, DescrProd, DtValidade, IDEstoque, IDCliente) VALUES (5, 12.99, 'Aspirina', 'Analgésico, antipirético e anti-inflamatório.', '2024-12-31', 2, 6);
INSERT INTO Produto (IDProduto, PrecVenda, NomeProduto, DescrProd, DtValidade, IDEstoque, IDCliente) VALUES (6, 29.99, 'Diclofenaco', 'Anti-inflamatório não esteroide.', '2024-12-31', 3, 7);
INSERT INTO Produto (IDProduto, PrecVenda, NomeProduto, DescrProd, DtValidade, IDEstoque, IDCliente) VALUES (7, 22.99, 'Cetoprofeno', 'Anti-inflamatório e analgésico.', '2024-12-31', 1, 8);
INSERT INTO Produto (IDProduto, PrecVenda, NomeProduto, DescrProd, DtValidade, IDEstoque, IDCliente) VALUES (8, 18.99, 'Tramadol', 'Analgésico opioide.', '2024-12-31', 4, 2);
INSERT INTO Produto (IDProduto, PrecVenda, NomeProduto, DescrProd, DtValidade, IDEstoque, IDCliente) VALUES (9, 29.99, 'Vacina contra Influenza', 'Previne infecções causadas pelo vírus da influenza.', '2024-12-31', 3, 1);
INSERT INTO Produto (IDProduto, PrecVenda, NomeProduto, DescrProd, DtValidade, IDEstoque, IDCliente) VALUES (10, 39.99, 'Vacina contra Meningite B', 'Previne infecções causadas pela bactéria Neisseria meningitidis do tipo B.', '2024-12-31', 2, 1);


INSERT INTO Medicamento (Indicacao, Contraindicacao, IDProduto) VALUES ('Alívio temporário da febre e dor de cabeça.', 'Não utilizar em caso de alergia ao paracetamol, durante a gravidez ou amamentação.', 1);
INSERT INTO Medicamento (Indicacao, Contraindicacao, IDProduto) VALUES ('Alívio temporário da febre e dor de cabeça.', 'Não utilizar em caso de alergia ao paracetamol, durante a gravidez ou amamentação.', 2);
INSERT INTO Medicamento (Indicacao, Contraindicacao, IDProduto) VALUES ('Alívio temporário de dores leves a moderadas.', 'Não utilizar em caso de alergia ao ibuprofeno, durante a gravidez após o terceiro trimestre ou amamentação.', 3);
INSERT INTO Medicamento (Indicacao, Contraindicacao, IDProduto) VALUES ('Alívio temporário de febre e dor.', 'Não utilizar em caso de alergia à dipirona, durante a gravidez ou amamentação.', 4);
INSERT INTO Medicamento (Indicacao, Contraindicacao, IDProduto) VALUES ('Alívio temporário de dores leves a moderadas.', 'Não utilizar em caso de alergia à nimesulida, durante a gravidez ou amamentação.', 5);
INSERT INTO Medicamento (Indicacao, Contraindicacao, IDProduto) VALUES ('Alívio temporário de dores leves a moderadas.', 'Não utilizar em caso de alergia à aspirina, durante a gravidez ou amamentação.', 6);
INSERT INTO Medicamento (Indicacao, Contraindicacao, IDProduto) VALUES ('Alívio temporário de dores leves a moderadas.', 'Não utilizar em caso de alergia ao diclofenaco, durante a gravidez após o terceiro trimestre ou amamentação.', 7);
INSERT INTO Medicamento (Indicacao, Contraindicacao, IDProduto) VALUES ('Alívio temporário de dores leves a moderadas.', 'Não utilizar em caso de alergia ao cetoprofeno, durante a gravidez após o terceiro trimestre ou amamentação.', 8);


INSERT INTO Vacina (FabricanteVac, IDProduto, IDCliente) VALUES ('VacinaCorp', 9, 1);
INSERT INTO Vacina (FabricanteVac, IDProduto, IDCliente) VALUES ('VacinaCorp', 10, 5);


INSERT INTO CliCompraProd (Quantidade, IDCompra, DataCompra, IDCliente, IDProduto) VALUES (1, 1, '2024-05-20', 2, 1);
INSERT INTO CliCompraProd (Quantidade, IDCompra, DataCompra, IDCliente, IDProduto) VALUES (2, 2, '2024-05-21', 3, 3);
INSERT INTO CliCompraProd (Quantidade, IDCompra, DataCompra, IDCliente, IDProduto) VALUES (1, 3, '2024-05-20', 2, 2);
INSERT INTO CliCompraProd (Quantidade, IDCompra, DataCompra, IDCliente, IDProduto) VALUES (3, 4, '2024-05-21', 3, 3);
INSERT INTO CliCompraProd (Quantidade, IDCompra, DataCompra, IDCliente, IDProduto) VALUES (2, 5, '2024-05-20', 1, 1);
INSERT INTO CliCompraProd (Quantidade, IDCompra, DataCompra, IDCliente, IDProduto) VALUES (2, 6, '2024-05-22', 4, 4);
INSERT INTO CliCompraProd (Quantidade, IDCompra, DataCompra, IDCliente, IDProduto) VALUES (5, 7, '2024-05-23', 4, 5);
INSERT INTO CliCompraProd (Quantidade, IDCompra, DataCompra, IDCliente, IDProduto) VALUES (1, 8, '2024-05-24', 6, 5);
INSERT INTO CliCompraProd (Quantidade, IDCompra, DataCompra, IDCliente, IDProduto) VALUES (6, 9, '2024-05-25', 5, 1);
INSERT INTO CliCompraProd (Quantidade, IDCompra, DataCompra, IDCliente, IDProduto) VALUES (3, 10, '2024-05-26', 1, 3);


INSERT INTO ProdCateg (IDProduto, IDCategoria) VALUES (1, 1); 
INSERT INTO ProdCateg (IDProduto, IDCategoria) VALUES (1, 3); 
INSERT INTO ProdCateg (IDProduto, IDCategoria) VALUES (2, 3);
INSERT INTO ProdCateg (IDProduto, IDCategoria) VALUES (3, 1); 
INSERT INTO ProdCateg (IDProduto, IDCategoria) VALUES (4, 3);
INSERT INTO ProdCateg (IDProduto, IDCategoria) VALUES (5, 1); 
INSERT INTO ProdCateg (IDProduto, IDCategoria) VALUES (5, 3); 
INSERT INTO ProdCateg (IDProduto, IDCategoria) VALUES (6, 3); 
INSERT INTO ProdCateg (IDProduto, IDCategoria) VALUES (7, 3);
INSERT INTO ProdCateg (IDProduto, IDCategoria) VALUES (8, 1);
INSERT INTO ProdCateg (IDProduto, IDCategoria) VALUES (9, 4); 
INSERT INTO ProdCateg (IDProduto, IDCategoria) VALUES (10, 5); 


INSERT INTO CliEnferm (DtCadEnferm, IDCliente, IDEnfermidade) VALUES ('2024-05-20', 1, 1);
INSERT INTO CliEnferm (DtCadEnferm, IDCliente, IDEnfermidade) VALUES ('2024-05-20', 2, 2);
INSERT INTO CliEnferm (DtCadEnferm, IDCliente, IDEnfermidade) VALUES ('2024-05-22', 4, 3);


INSERT INTO Cliente_TelefoneCliente (TelefoneCliente, IDCliente) VALUES (987654321, 1);
INSERT INTO Cliente_TelefoneCliente (TelefoneCliente, IDCliente) VALUES (977246462, 2);
INSERT INTO Cliente_TelefoneCliente (TelefoneCliente, IDCliente) VALUES (995243243, 3);
INSERT INTO Cliente_TelefoneCliente (TelefoneCliente, IDCliente) VALUES (999000111, 4);
INSERT INTO Cliente_TelefoneCliente (TelefoneCliente, IDCliente) VALUES (992525231, 5);
INSERT INTO Cliente_TelefoneCliente (TelefoneCliente, IDCliente) VALUES (992342145, 6);
INSERT INTO Cliente_TelefoneCliente (TelefoneCliente, IDCliente) VALUES (912424143, 7);
INSERT INTO Cliente_TelefoneCliente (TelefoneCliente, IDCliente) VALUES (981313123, 8);


INSERT INTO InteracaoMedicamentosa (DescrInteracaoMedicam, IDProdutoX, IDProdutoY) VALUES ('Possível interação', 1, 2);
INSERT INTO InteracaoMedicamentosa (DescrInteracaoMedicam, IDProdutoX, IDProdutoY) VALUES ('Possível interação', 2, 4);
INSERT INTO InteracaoMedicamentosa (DescrInteracaoMedicam, IDProdutoX, IDProdutoY) VALUES ('Possível interação', 4, 1);

