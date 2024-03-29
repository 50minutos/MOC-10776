USE master

IF EXISTS (SELECT * FROM SYS.databases WHERE name = 'DB')
BEGIN
	ALTER DATABASE DB
	SET SINGLE_USER
	WITH ROLLBACK IMMEDIATE

	DROP DATABASE DB
END

CREATE DATABASE DB
GO

USE DB

CREATE TABLE PESSOA
(
	COD_PESSOA INT IDENTITY, 
	NOME_PESSOA VARCHAR(50), 
	SEXO_PESSOA CHAR(1) CHECK (SEXO_PESSOA IN ('M', 'F'))
)

SELECT *
FROM PESSOA
WHERE SEXO_PESSOA = 'M'

SELECT *
FROM PESSOA
WHERE SEXO_PESSOA = 'X'

CREATE TABLE DOLAR
(
	DATA_DOLAR DATE, 
	VALOR_DOLAR DEC(9, 2)
)

CREATE TABLE VENDA
(
	COD_VENDA INT IDENTITY, 
	DATA_VENDA DATE, 
	VALOR_VENDA DEC(9, 2)
)

INSERT DOLAR
VALUES ('20130807', 2.30), 
	('20130806', 2.29)

GO

CREATE TRIGGER UTR_VENDA_INSERT_CONVERTER_PARA_DOLAR
ON VENDA
FOR INSERT
AS
	UPDATE VENDA
	SET VALOR_VENDA = VENDA.VALOR_VENDA/VALOR_DOLAR
	FROM VENDA
	JOIN INSERTED ON VENDA.COD_VENDA = INSERTED.COD_VENDA
	JOIN DOLAR ON DOLAR.DATA_DOLAR = VENDA.DATA_VENDA

	IF @@ROWCOUNT = 0 
		ROLLBACK
GO

INSERT VENDA 
VALUES ('20130806', 100)

SELECT * 
FROM VENDA

INSERT VENDA 
VALUES ('20130809', 100)

SELECT *
FROM VENDA

CREATE TABLE FUNCIONARIO
(
	COD_FUNCIONARIO INT IDENTITY, 
	NOME_FUNCIONARIO VARCHAR(50), 
	SALARIO_FUNCIONARIO DEC(9, 2) DEFAULT 0, 
	ADMISSAO_FUNCIONARIO DATE DEFAULT GETDATE() 
)

INSERT FUNCIONARIO (NOME_FUNCIONARIO)
VALUES ('ADAO')

INSERT FUNCIONARIO
VALUES ('EVA', DEFAULT, DEFAULT)

INSERT FUNCIONARIO
VALUES ('CAIM', 10, '00010101')

INSERT FUNCIONARIO
VALUES ('CAIM', NULL, '00010101')

SELECT *
FROM FUNCIONARIO

CREATE TABLE NOTA_ALUNO
(
	COD_ALUNO INT /*REFERENCES ALUNO*/, 
	COD_PROVA INT /*REFERENCES PROVA--, PROVA -> ...*/, 
	NOTA_ALUNO DEC(4, 2) CHECK (NOTA_ALUNO BETWEEN 0 AND 10) DEFAULT 0 NULL, 

	UNIQUE(COD_ALUNO, COD_PROVA)
)

INSERT NOTA_ALUNO
VALUES (1, 2, 10)

INSERT NOTA_ALUNO
VALUES (2, 2, 1.23456)

INSERT NOTA_ALUNO
VALUES(3, 2, 14)

SELECT *
FROM NOTA_ALUNO

SELECT * 
FROM SYS.TABLES

DROP TABLE PESSOA
DROP TABLE DOLAR
DROP TABLE VENDA
DROP TABLE FUNCIONARIO
DROP TABLE NOTA_ALUNO

CREATE TABLE TIPO_PRODUTO
(
	COD_TIPO_PRODUTO INT IDENTITY, 
	NOME_TIPO_PRODUTO VARCHAR(50)
)

ALTER TABLE TIPO_PRODUTO
ADD CONSTRAINT PK_TIPO_PRODUTO PRIMARY KEY (COD_TIPO_PRODUTO)

CREATE TABLE PRODUTO
(
	COD_PRODUTO INT IDENTITY /*CONSTRAINT PK_PRODUTO*/ PRIMARY KEY, 
	NOME_PRODUTO VARCHAR(50), 
	COD_TIPO_PRODUTO INT

	--CONSTRAINT PK_PRODUTO PRIMARY KEY (COD_PRODUTO)

	--PRIMARY KEY (COD_PRODUTO)
)

EXEC SP_HELPCONSTRAINT PRODUTO

CREATE TABLE PESSOA
(
	COD_PESSOA INT IDENTITY PRIMARY KEY, 
	NOME_PESSOA VARCHAR(50) /*CONSTRAINT UQ_PESSOA_NOME_PESSOA*/ UNIQUE

	--CONSTRAINT UQ_PESSOA_NOME_PESSOA UNIQUE(NOME_PESSOA)
	--UNIQUE(NOME_PESSOA)
)

EXEC SP_HELPCONSTRAINT PESSOA

CREATE TABLE FUNCIONARIO 
(
	COD_FUNCIONARIO INT IDENTITY PRIMARY KEY, 
	NOME_FUNCIONARIO VARCHAR(50) UNIQUE, 
	COD_SUPERIOR INT /*CONSTRAINT FK_FUNCIONARIO_FUNCIONARIO*/ /*FOREIGN KEY (COD_SUPERIOR)*/ REFERENCES FUNCIONARIO/*(COD_FUNCIONARIO)*/

	--CONSTRAINT FK_FUNCIONARIO_FUNCIONARIO FOREIGN KEY (COD_SUPERIOR) REFERENCES FUNCIONARIO(COD_FUNCIONARIO)
	--FOREIGN KEY (COD_SUPERIOR) REFERENCES FUNCIONARIO(COD_FUNCIONARIO)
	--FOREIGN KEY (COD_SUPERIOR) REFERENCES FUNCIONARIO
)

EXEC SP_HELPINDEX FUNCIONARIO

ALTER TABLE FUNCIONARIO 
DROP CONSTRAINT UQ__FUNCIONA__EE987BEBA43B339E

EXEC SP_HELPINDEX FUNCIONARIO

EXEC SP_HELPCONSTRAINT FUNCIONARIO

ALTER TABLE FUNCIONARIO 
DROP CONSTRAINT FK__FUNCIONAR__COD_S__4AB81AF0

EXEC SP_HELPINDEX FUNCIONARIO

EXEC SP_HELPCONSTRAINT FUNCIONARIO

INSERT FUNCIONARIO
VALUES ('GERENT�O', NULL)

INSERT FUNCIONARIO
VALUES ('ASSISTENTE', 1)

INSERT FUNCIONARIO
VALUES ('OUTRO ASSISTENTE', 1000)

SELECT * 
FROM FUNCIONARIO

ALTER TABLE FUNCIONARIO
ADD CONSTRAINT FK_FUNCIONARIO_FUNCIONARIO FOREIGN KEY (COD_SUPERIOR) REFERENCES FUNCIONARIO(COD_FUNCIONARIO)

SELECT COD_SUPERIOR
FROM FUNCIONARIO
WHERE COD_SUPERIOR IS NOT NULL
EXCEPT
SELECT COD_FUNCIONARIO
FROM FUNCIONARIO

ALTER TABLE FUNCIONARIO
WITH NOCHECK
ADD CONSTRAINT FK_FUNCIONARIO_FUNCIONARIO FOREIGN KEY (COD_SUPERIOR) REFERENCES FUNCIONARIO(COD_FUNCIONARIO) 

EXEC SP_HELPCONSTRAINT FUNCIONARIO

EXEC SP_HELPINDEX FUNCIONARIO

EXEC sp_MSforeachtable 'DROP TABLE ?'

CREATE TABLE PAI
(
	COD_PAI INT PRIMARY KEY,
	NOME_PAI VARCHAR(50) 
)

CREATE TABLE FILHO
(
	COD_FILHO INT IDENTITY PRIMARY KEY, 
	NOME_FILHO VARCHAR(50), 
	COD_PAI INT REFERENCES PAI
)

INSERT PAI
VALUES (1, 'ADAO'), 
	(2, 'EPAMINONDAS')

INSERT FILHO 
VALUES ('CAIM', 1), 
	('ABEL', 1) 

SELECT * 
FROM PAI

SELECT *
FROM FILHO 

DELETE PAI
WHERE COD_PAI = 2

DELETE PAI
WHERE COD_PAI = 1

DROP TABLE FILHO, PAI

CREATE TABLE PAI
(
	COD_PAI INT PRIMARY KEY,
	NOME_PAI VARCHAR(50) 
)

CREATE TABLE FILHO
(
	COD_FILHO INT IDENTITY PRIMARY KEY, 
	NOME_FILHO VARCHAR(50), 
	COD_PAI INT REFERENCES PAI 
		ON UPDATE SET NULL 
		ON DELETE SET NULL
)

INSERT PAI
VALUES (1, 'ADAO'), 
	(2, 'EPAMINONDAS')

INSERT FILHO 
VALUES ('CAIM', 1), 
	('ABEL', 1) 

SELECT * 
FROM PAI

SELECT *
FROM FILHO 

UPDATE PAI 
SET COD_PAI = 10
WHERE COD_PAI = 1

SELECT *
FROM FILHO

DELETE PAI

SELECT *
FROM FILHO

DROP TABLE FILHO, PAI

CREATE TABLE PAI
(
	COD_PAI INT PRIMARY KEY,
	NOME_PAI VARCHAR(50) 
)

CREATE TABLE FILHO
(
	COD_FILHO INT IDENTITY PRIMARY KEY, 
	NOME_FILHO VARCHAR(50), 
	COD_PAI INT REFERENCES PAI 
		ON UPDATE CASCADE
		ON DELETE CASCADE
)

INSERT PAI
VALUES (1, 'ADAO'), 
	(2, 'EPAMINONDAS')

INSERT FILHO 
VALUES ('CAIM', 1), 
	('ABEL', 1) 

SELECT * 
FROM PAI

SELECT *
FROM FILHO 

UPDATE PAI 
SET COD_PAI = 10
WHERE COD_PAI = 1

SELECT *
FROM FILHO

DELETE PAI

SELECT *
FROM FILHO

EXEC sp_helpconstraint FILHO

ALTER TABLE FILHO
NOCHECK CONSTRAINT FK__FILHO__COD_PAI__5AEE82B9

INSERT FILHO
VALUES ('CHIQUINHA', 23482)

ALTER TABLE FILHO
CHECK CONSTRAINT FK__FILHO__COD_PAI__5AEE82B9

INSERT FILHO
VALUES ('CHAVES', 23482)

DROP TABLE FILHO, PAI

CREATE TABLE LIVRO
(
	COD_LIVRO INT IDENTITY/*(1, 1)*/, 
	TITULO_LIVRO VARCHAR(50)
)

INSERT LIVRO 
VALUES ('ABC DO TRUCO'), 
	('PALITINHO SEM MESTRE'), 
	('SQL � BICO'), 
	('C# EM 21 DIAS')

DELETE LIVRO 
WHERE COD_LIVRO = 2

SELECT *
FROM LIVRO

SET IDENTITY_INSERT LIVRO ON 

INSERT LIVRO (COD_LIVRO, TITULO_LIVRO)
VALUES (2, 'EU PODIA T� MATANO, EU PODIA T� ROBANO, ...')

SET IDENTITY_INSERT LIVRO OFF

SELECT *
FROM LIVRO

SELECT @@IDENTITY, IDENT_CURRENT('LIVRO'), SCOPE_IDENTITY()

CREATE TABLE PAI
(
	COD_PAI INT IDENTITY PRIMARY KEY,
	NOME_PAI VARCHAR(50) 
)

CREATE TABLE FILHO
(
	COD_FILHO INT IDENTITY PRIMARY KEY, 
	NOME_FILHO VARCHAR(50), 
	COD_PAI INT REFERENCES PAI 
		ON UPDATE CASCADE
		ON DELETE CASCADE
)

INSERT PAI
VALUES ('ADAO')

DECLARE @COD_PAI INT = IDENT_CURRENT('PAI')

INSERT FILHO 
VALUES ('CAIM', @COD_PAI), 
	('ABEL', @COD_PAI) 

SELECT *
FROM PAI

SELECT * 
FROM FILHO

--DELETE -> N�O RESETA O IDENTITY
--TRUNCATE -> RESETA

DELETE FILHO

DBCC CHECKIDENT(FILHO, RESEED, 0)

GO

DECLARE @COD_PAI INT = IDENT_CURRENT('PAI')

INSERT FILHO 
VALUES ('CAIM', @COD_PAI), 
	('ABEL', @COD_PAI) 

SELECT * 
FROM FILHO

SELECT NAME, IDENT_SEED(NAME) AS 'SEED', IDENT_INCR(NAME) AS 'INCR', IDENT_CURRENT(NAME) AS 'CURR'
FROM SYS.TABLES

GO

CREATE SEQUENCE SEQ_PRODUTO AS INT

GO

CREATE TABLE PRODUTO
(
	COD_PRODUTO INT DEFAULT (NEXT VALUE FOR SEQ_PRODUTO),
	NOME_PRODUTO VARCHAR(50) 
)

INSERT PRODUTO(NOME_PRODUTO)
VALUES('MARTELO')

ALTER SEQUENCE SEQ_PRODUTO
RESTART WITH 1

