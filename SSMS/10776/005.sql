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

CREATE TABLE PRODUTO
(
	COD_PRODUTO UNIQUEIDENTIFIER DEFAULT NEWID(), 
	NOME_PRODUTO VARCHAR(50)
)

DECLARE @X INT = 1

WHILE @X <= 3000
BEGIN
	INSERT PRODUTO (NOME_PRODUTO) 
	VALUES (NEWID())
	
	SET @X += 1
END

SELECT * 
FROM SYS.DM_DB_INDEX_PHYSICAL_STATS(DB_ID(), OBJECT_ID('TABELA'), DEFAULT, DEFAULT, DEFAULT)

GO

DROP TABLE PRODUTO

CREATE TABLE PRODUTO
(
	COD_PRODUTO UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY, 
	NOME_PRODUTO VARCHAR(50)
)

DECLARE @X INT = 1

WHILE @X <= 3000
BEGIN
	INSERT PRODUTO (NOME_PRODUTO) 
	VALUES (NEWID())
	
	SET @X += 1
END

SELECT * 
FROM SYS.DM_DB_INDEX_PHYSICAL_STATS(DB_ID(), OBJECT_ID('TABELA'), DEFAULT, DEFAULT, DEFAULT)

DBCC SHOWCONTIG('PRODUTO')

ALTER INDEX ALL ON PRODUTO REBUILD

DBCC SHOWCONTIG('PRODUTO')

DBCC DBREINDEX('PRODUTO')

DBCC SHOWCONTIG('PRODUTO')

CREATE TABLE PESSOA
(
	COD_PESSOA INT IDENTITY, 
	NOME_PESSOA VARCHAR(50),
	NOME_CIDADE VARCHAR(50), 
	SIGLA_ESTADO CHAR(2)
)

INSERT PESSOA
VALUES ('ADAO', 'SPO', 'SP'), 
	 ('EVA', 'RIO', 'RJ'), 
	 ('EPAMINONDAS', 'SPO', 'SP')

SELECT *
FROM PESSOA

CREATE INDEX IDX_PESSOA_NOME_CIDADE_UF 
ON PESSOA(NOME_PESSOA, NOME_CIDADE, SIGLA_ESTADO)

SELECT NOME_PESSOA, 
	NOME_CIDADE, 
	SIGLA_ESTADO
FROM PESSOA

SELECT NOME_PESSOA, 
	NOME_CIDADE, 
	SIGLA_ESTADO
FROM PESSOA
WHERE NOME_PESSOA = 'ZE'

SELECT NOME_PESSOA, 
	NOME_CIDADE, 
	SIGLA_ESTADO
FROM PESSOA
WHERE NOME_CIDADE = 'SPO'

SELECT NOME_PESSOA, 
	NOME_CIDADE, 
	SIGLA_ESTADO
FROM PESSOA
WHERE NOME_PESSOA = 'ZE' 
	AND NOME_CIDADE = 'SPO'

SELECT NOME_PESSOA, 
	NOME_CIDADE, 
	SIGLA_ESTADO
FROM PESSOA
WHERE NOME_CIDADE = 'SPO'
	AND NOME_PESSOA = 'ZE' 

CREATE INDEX IDX_PESSOA_UF_CIDADE_NOME
ON PESSOA(SIGLA_ESTADO, NOME_CIDADE, NOME_PESSOA)

SELECT NOME_PESSOA, 
	NOME_CIDADE, 
	SIGLA_ESTADO
FROM PESSOA

SELECT NOME_PESSOA, 
	NOME_CIDADE, 
	SIGLA_ESTADO
FROM PESSOA
WHERE NOME_PESSOA = 'ZE'

SELECT NOME_PESSOA, 
	NOME_CIDADE, 
	SIGLA_ESTADO
FROM PESSOA
WHERE NOME_CIDADE = 'SPO'

SELECT NOME_PESSOA, 
	NOME_CIDADE, 
	SIGLA_ESTADO
FROM PESSOA
WHERE NOME_PESSOA = 'ZE' 
	AND NOME_CIDADE = 'SPO'

SELECT NOME_PESSOA, 
	NOME_CIDADE, 
	SIGLA_ESTADO
FROM PESSOA
WHERE NOME_CIDADE = 'SPO'
	AND NOME_PESSOA = 'ZE' 

SELECT NOME_PESSOA, 
	NOME_CIDADE, 
	SIGLA_ESTADO
FROM PESSOA
WHERE SIGLA_ESTADO = 'SP' 
	AND NOME_CIDADE = 'SPO'
	AND NOME_PESSOA = 'ZE' 

SELECT *
FROM SYS.stats 
WHERE OBJECT_ID = OBJECT_ID('PESSOA')

CREATE STATISTICS STA_PESSOA ON PESSOA (NOME_PESSOA)
WITH FULLSCAN

SELECT *
FROM SYS.stats 
WHERE OBJECT_ID = OBJECT_ID('PESSOA')

DBCC SHOW_STATISTICS('PESSOA', STA_PESSOA)

DBCC SHOW_STATISTICS('PESSOA', IDX_PESSOA_NOME_CIDADE_UF)

DBCC SHOW_STATISTICS('PESSOA', IDX_PESSOA_UF_CIDADE_NOME)

EXEC SP_MSFOREACHTABLE 'DROP TABLE ?'

CREATE TABLE PRODUTO
(
	COD_PRODUTO INT IDENTITY, 
	NOME_PRODUTO VARCHAR(50), 
	PRECO_PRODUTO DEC(9, 2)
)

INSERT PRODUTO 
VALUES ('MARRETA', 1), 
('MARTELO', 2), 
('SERROTE', 3) 

SELECT *
FROM PRODUTO

DELETE PRODUTO 
WHERE COD_PRODUTO = 2

INSERT PRODUTO
VALUES ('OUTRO MARTELO', 4)

SELECT * 
FROM PRODUTO

ALTER TABLE PRODUTO REBUILD

EXEC SP_HELPINDEX PRODUTO

SELECT * 
FROM SYS.indexes
WHERE OBJECT_ID = OBJECT_ID('PRODUTO')

GO
