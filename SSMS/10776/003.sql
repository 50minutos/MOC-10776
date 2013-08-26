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

CREATE TABLE CLIENTE
(
	COD_CLIENTE INT PRIMARY KEY, 
	NOME_CLIENTE VARCHAR(50), 
	SOBRENOME_CLIENTE VARCHAR(100),
	
	--CONSTRAINT PK_CLIENTE PRIMARY KEY(COD_CLIENTE), 
	--CONSTRAINT UQ_CLIENTE_NOME_CLIENTE_SOBRENOME_CLIENTE UNIQUE(NOME_CLIENTE, SOBRENOME_CLIENTE)
	UNIQUE(NOME_CLIENTE, SOBRENOME_CLIENTE)
)

EXEC sp_helpconstraint CLIENTE

INSERT CLIENTE
VALUES (1, 'AD�O', 'DA SILVA')

INSERT CLIENTE
VALUES (1, 'EVA', 'DA SILVA')
	
SELECT * 
FROM CLIENTE

INSERT CLIENTE
VALUES (2, 'AD�O', 'DA SILVA')

SELECT *
FROM CLIENTE

CREATE TABLE FILHO
(
	COD_FILHO INT IDENTITY PRIMARY KEY, 
	NOME_FILHO VARCHAR(50), 
	COD_CLIENTE INT REFERENCES CLIENTE
	
	--CONSTRAINT FK_FILHO_COD_CLIENTE FOREIGN KEY (COD_CLIENTE) REFERENCES CLIENTE(COD_CLIENTE)
	--FOREIGN KEY (COD_CLIENTE) REFERENCES CLIENTE(COD_CLIENTE)
	--FOREIGN KEY (COD_CLIENTE) REFERENCES CLIENTE
)

INSERT FILHO
VALUES ('CHICO', 3)

INSERT FILHO
VALUES ('CAIM', 1)

INSERT FILHO
VALUES ('EPAMINONDAS', NULL)

EXEC sp_MSforeachtable 'DROP TABLE ?'
EXEC sp_MSforeachtable 'DROP TABLE ?'

CREATE TABLE FUNCIONARIO
(
	COD_FUNCIONARIO INT IDENTITY PRIMARY KEY, 
	NOME_FUNCIONARIO VARCHAR(50), 
	COD_SUPERIOR INT REFERENCES FUNCIONARIO
)

INSERT FUNCIONARIO
VALUES ('DIRETOR X', NULL)

INSERT FUNCIONARIO
VALUES ('ASSISTENTE DO DIRETOR X', 1)

INSERT FUNCIONARIO
VALUES ('AUXILIAR X', 2)

INSERT FUNCIONARIO
VALUES ('AUXILIAR Y', 2)

INSERT FUNCIONARIO
VALUES ('AUXILIAR ERRO', 24523)

CREATE TABLE PEDIDO
(
	COD_PEDIDO INT PRIMARY KEY, 
	DATA_PEDIDO DATE
)

CREATE TABLE ITEM_PEDIDO
(
	COD_ITEM_PEDIDO INT PRIMARY KEY IDENTITY, 
	COD_PRODUTO INT, 
	PRECO_PRODUTO DEC(9,2), 
	QTD_PRODUTO INT, 
	COD_PEDIDO INT REFERENCES PEDIDO 
		ON UPDATE CASCADE 
		ON DELETE CASCADE
)

INSERT PEDIDO
VALUES (1, GETDATE())

INSERT ITEM_PEDIDO
VALUES (1, 10, 2, 1)

INSERT PEDIDO
VALUES (2, GETDATE())

INSERT ITEM_PEDIDO
VALUES (1, 10, 20, 2)

DELETE PEDIDO
WHERE COD_PEDIDO = 1

SELECT * 
FROM PEDIDO

SELECT * 
FROM ITEM_PEDIDO

UPDATE PEDIDO
SET COD_PEDIDO = 10
WHERE COD_PEDIDO = 2

SELECT * 
FROM PEDIDO

SELECT * 
FROM ITEM_PEDIDO

GO

EXEC sp_MSforeachtable 'DROP TABLE ?'
EXEC sp_MSforeachtable 'DROP TABLE ?'

GO

CREATE SCHEMA PRODUCAO
GO

CREATE TABLE PRODUCAO.TIPO_PRODUTO
(
	COD_TIPO_PRODUTO INT IDENTITY PRIMARY KEY,
	NOME_TIPO_PRODUTO VARCHAR(50), 
)

CREATE TABLE PRODUCAO.PRODUTO
(
	COD_PRODUTO INT IDENTITY PRIMARY KEY,
	NOME_PRODUTO VARCHAR(50), 
	PRECO_PRODUTO DEC(9, 2), 
	COD_TIPO_PRODUTO INT REFERENCES PRODUCAO.TIPO_PRODUTO
)

GRANT SELECT, INSERT, UPDATE, DELETE, VIEW DEFINITION, EXECUTE
ON SCHEMA::PRODUCAO 
TO ZE

ALTER SCHEMA DBO TRANSFER OBJECT::PRODUCAO.PRODUTO
ALTER SCHEMA DBO TRANSFER OBJECT::PRODUCAO.TIPO_PRODUTO

DROP SCHEMA PRODUCAO

CREATE TABLE TIPO_PRODUTO
(
	COD_TIPO_PRODUTO INT IDENTITY PRIMARY KEY,
	NOME_TIPO_PRODUTO VARCHAR(50), 
)

CREATE TABLE PRODUTO
(
	COD_PRODUTO INT IDENTITY PRIMARY KEY,
	NOME_PRODUTO VARCHAR(50), 
	PRECO_PRODUTO DEC(9, 2), 
	COD_TIPO_PRODUTO INT REFERENCES TIPO_PRODUTO
)

EXEC SP_TABLES

DROP TABLE PRODUTO, TIPO_PRODUTO

CREATE TABLE PRODUTO
(
	COD_PRODUTO INT IDENTITY,
	NOME_PRODUTO VARCHAR(50), 
	PRECO_PRODUTO DEC(9, 2)
)

ALTER TABLE PRODUTO
ADD PRECO_CUSTO_PRODUTO DEC(9, 2)

SELECT * 
FROM SYS.COLUMNS
WHERE OBJECT_ID = OBJECT_ID('PRODUTO')

ALTER TABLE PRODUTO
DROP COLUMN PRECO_CUSTO_PRODUTO

INSERT PRODUTO
VALUES ('MARTELO', 10)

ALTER TABLE PRODUTO
ADD PRECO_CUSTO_PRODUTO INT

UPDATE PRODUTO
SET PRECO_CUSTO_PRODUTO = 0.75 * PRECO_PRODUTO 

SELECT *
FROM PRODUTO

ALTER TABLE PRODUTO
ALTER COLUMN PRECO_CUSTO_PRODUTO DEC(9, 2)

SELECT * 
FROM PRODUTO

ALTER TABLE PRODUTO
ALTER COLUMN PRECO_CUSTO_PRODUTO DEC(9, 2) NOT NULL

ALTER TABLE PRODUTO 
ADD CONSTRAINT PK_PRODUTO PRIMARY KEY (COD_PRODUTO)

EXEC sp_helpindex PRODUTO

EXEC sp_helpconstraint PRODUTO

ALTER TABLE PRODUTO
ADD CONSTRAINT UQ_PRODUTO_NOME_PRODUTO UNIQUE(NOME_PRODUTO)

ALTER TABLE PRODUTO
ADD CONSTRAINT CK_PRODUTO_PRECO_PRODUTO CHECK(PRECO_PRODUTO >= 0)

EXEC sp_helpindex PRODUTO

EXEC sp_helpconstraint PRODUTO

CREATE TABLE #TMP
(
	DATA DATE, 
	QTD INT
)

INSERT INTO #TMP 
SELECT GETDATE(), 
	COUNT(*) 
FROM PRODUTO

SELECT *
FROM #TMP

SELECT *
FROM TEMPDB.SYS.OBJECTS 
WHERE NAME LIKE '#TMP%'

GO

CREATE PROC USP_PROCESSA
AS
	SET NOCOUNT ON 

	IF EXISTS(SELECT * FROM TEMPDB.SYS.OBJECTS WHERE NAME = '##BLOCK')
	BEGIN
		RAISERROR('OUTRO PROCESSO J� EST� EM EXECU��O', 16, 1)
	
		RETURN
	END
	
	CREATE TABLE ##BLOCK
	(
		DATA DATETIME2 DEFAULT SYSDATETIME()
	)

	PRINT 'PROCESSANDO A BAGA�A - INI'

	INSERT ##BLOCK
	VALUES(DEFAULT)

	WAITFOR DELAY '00:01' --1 MINUTO

	PRINT 'PROCESSANDO A BAGA�A - FIM'

	DROP TABLE ##BLOCK
GO

EXEC USP_PROCESSA

--S� POR GARANTIA!!!
--JOB COM UM STEP DE SQL COMMAND PARA APAGAR A ##BLOCK (EXECUTAR A CADA 1 MINUTO)
IF EXISTS(SELECT * FROM TEMPDB.SYS.OBJECTS WHERE NAME = '##BLOCK')
	IF EXISTS ( SELECT * FROM ##BLOCK WHERE DATEDIFF(MM, DATA, GETDATE() ) >= 5)
		DROP TABLE ##BLOCK

DECLARE @TABELA TABLE (CAMPO1 INT IDENTITY, CAMPO2 DATE)

INSERT @TABELA 
VALUES (GETDATE())

INSERT @TABELA 
VALUES (GETDATE())

SELECT * 
FROM @TABELA

DROP TABLE PRODUTO

CREATE TABLE PESSOA
(
	COD_PESSOA INT IDENTITY, 
	NOME_PESSOA VARCHAR(20),  
	SOBRENOME_PESSOA VARCHAR(30), 
	NOME_COMPLETO_PESSOA AS CONCAT(NOME_PESSOA, ' ', SOBRENOME_PESSOA)
)

INSERT PESSOA
VALUES ('Z�', 'DITO'), 
	('Z�', 'RUELA'), 
	('Z�', 'DEND�GUA'), 
	('Z�', 'DAS COUVES'), 
	('Z�', 'MAN�') 

SELECT * 
FROM PESSOA

CREATE NONCLUSTERED INDEX IDX1 
ON PESSOA(NOME_COMPLETO_PESSOA)

SELECT NOME_COMPLETO_PESSOA 
FROM PESSOA

SELECT NOME_COMPLETO_PESSOA
FROM PESSOA 
WHERE NOME_COMPLETO_PESSOA = 'Z� ROIA'

DROP TABLE PESSOA

CREATE TABLE PESSOA
(
	COD_PESSOA INT IDENTITY, 
	NOME_PESSOA VARCHAR(20),  
	SOBRENOME_PESSOA VARCHAR(30), 
	NOME_COMPLETO_PESSOA AS CONCAT(NOME_PESSOA, ' ', SOBRENOME_PESSOA) PERSISTED
)

INSERT PESSOA
VALUES ('Z�', 'DITO'), 
	('Z�', 'RUELA'), 
	('Z�', 'DEND�GUA'), 
	('Z�', 'DAS COUVES'), 
	('Z�', 'MAN�') 

SELECT * 
FROM PESSOA

CREATE NONCLUSTERED INDEX IDX1 
ON PESSOA(NOME_COMPLETO_PESSOA)

SELECT NOME_COMPLETO_PESSOA 
FROM PESSOA

SELECT NOME_COMPLETO_PESSOA
FROM PESSOA 
WHERE NOME_COMPLETO_PESSOA = 'Z� ROIA'
