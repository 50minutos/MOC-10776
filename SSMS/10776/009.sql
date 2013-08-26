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

CREATE TABLE TIPO_PRODUTO
(
	COD_TIPO_PRODUTO INT IDENTITY PRIMARY KEY, 
	NOME_TIPO_PRODUTO VARCHAR(50)
)

CREATE TABLE PRODUTO
(
	COD_PRODUTO INT IDENTITY PRIMARY KEY, 
	NOME_PRODUTO VARCHAR(50), 
	PRECO_PRODUTO DEC(9, 2), 
	COD_TIPO_PRODUTO INT REFERENCES TIPO_PRODUTO
)

SELECT *
FROM SYS.tables

SELECT OBJECT_NAME(object_id) AS NAME, 
	*
FROM SYS.columns
WHERE object_id = OBJECT_ID('TIPO_PRODUTO')
	OR object_id = OBJECT_ID('PRODUTO')

GO

CREATE VIEW UV_TIPO_PRODUTO_PRODUTO
AS
	SELECT TP.*, 
		P.COD_PRODUTO, 
		P.NOME_PRODUTO, 
		P.PRECO_PRODUTO
	FROM TIPO_PRODUTO TP
	JOIN PRODUTO P 
		ON TP.COD_TIPO_PRODUTO = P.COD_TIPO_PRODUTO
GO

SELECT *
FROM SYS.views

SELECT OBJECT_NAME(object_id) AS NAME, 
	*
FROM SYS.columns
WHERE object_id = OBJECT_ID('UV_TIPO_PRODUTO_PRODUTO')

EXEC sp_spaceused 'TIPO_PRODUTO'
EXEC sp_spaceused 'PRODUTO'
EXEC sp_spaceused 'UV_TIPO_PRODUTO_PRODUTO'

SELECT *
FROM SYS.system_views

SELECT * 
FROM SYS.dm_exec_connections

EXEC sp_who2

SELECT *
FROM SYS.dm_exec_sessions

SELECT *
FROM SYS.dm_exec_requests

SELECT *
FROM SYS.dm_exec_sql_text(0x02000000D41C032844760602269985AE5DADEAE4CC1587D30000000000000000000000000000000000000000)

SELECT * 
FROM SYS.dm_exec_sql_text(0x0600080037C1CB3020FCCC610200000001000000000000000000000000000000000000000000000000000000)

SELECT *
FROM SYS.dm_exec_query_plan(0x0600080037C1CB3020FCCC610200000001000000000000000000000000000000000000000000000000000000)

SELECT *
FROM SYS.dm_exec_query_stats

SELECT ST.TEXT, 
	QS.MAX_PHYSICAL_READS, 
	QS.MAX_LOGICAL_READS
FROM  SYS.DM_EXEC_QUERY_STATS QS
CROSS APPLY SYS.DM_EXEC_SQL_TEXT(QS.SQL_HANDLE) ST
ORDER BY QS.MAX_LOGICAL_READS DESC

GO

CREATE VIEW UV_PRODUTOS_TOP_10_PRECO_PRODUTO
AS
	SELECT TOP 10 *
	FROM PRODUTO
	ORDER BY PRECO_PRODUTO DESC
GO

SELECT * 
FROM UV_PRODUTOS_TOP_10_PRECO_PRODUTO

EXEC sp_spaceused 'TIPO_PRODUTO'
EXEC sp_spaceused 'PRODUTO'
EXEC sp_spaceused 'UV_TIPO_PRODUTO_PRODUTO'

INSERT TIPO_PRODUTO
VALUES ('FERRAMENTA'), 
	('MATERIAL DE ESCRIT�RIO')

INSERT PRODUTO
VALUES ('MARTELO', 10, 1), 
	('MARRETA', 20, 1), 
	('SERROTE', 30, 1)

SELECT * 
FROM UV_TIPO_PRODUTO_PRODUTO

DROP TABLE PRODUTO, TIPO_PRODUTO

SELECT * 
FROM UV_TIPO_PRODUTO_PRODUTO

CREATE TABLE TIPO_PRODUTO
(
	COD_TIPO_PRODUTO INT IDENTITY PRIMARY KEY, 
	NOME_TIPO_PRODUTO VARCHAR(50)
)

CREATE TABLE PRODUTO
(
	COD_PRODUTO INT IDENTITY PRIMARY KEY, 
	NOME_PRODUTO VARCHAR(50), 
	PRECO_PRODUTO DEC(9, 2), 
	COD_TIPO_PRODUTO INT REFERENCES TIPO_PRODUTO
)

INSERT TIPO_PRODUTO
VALUES ('FERRAMENTA'), 
	('MATERIAL DE ESCRIT�RIO')

INSERT PRODUTO
VALUES ('MARTELO', 10, 1), 
	('MARRETA', 20, 1), 
	('SERROTE', 30, 1)

SELECT * 
FROM UV_TIPO_PRODUTO_PRODUTO

GO

CREATE SCHEMA VENDAS
GO

CREATE VIEW VENDAS.UV_PRODUTO_TIPO_PRODUTO
AS
	SELECT TP.NOME_TIPO_PRODUTO, 
		P.COD_PRODUTO, 
		P.NOME_PRODUTO, 
		P.PRECO_PRODUTO
	FROM DBO.PRODUTO P 
	JOIN DBO.TIPO_PRODUTO TP
		ON TP.COD_TIPO_PRODUTO = P.COD_TIPO_PRODUTO	
GO

CREATE VIEW VENDAS.UV_PRODUTO_ROWNUMBER
AS
	SELECT TP.NOME_TIPO_PRODUTO, 
		ROW_NUMBER() OVER(PARTITION BY TP.COD_TIPO_PRODUTO ORDER BY TP.COD_TIPO_PRODUTO, P.COD_PRODUTO) AS 'ITEM',
		P.COD_PRODUTO, 
		P.NOME_PRODUTO, 
		P.PRECO_PRODUTO
	FROM DBO.PRODUTO P 
	JOIN DBO.TIPO_PRODUTO TP
		ON TP.COD_TIPO_PRODUTO = P.COD_TIPO_PRODUTO	
GO

SELECT *
FROM VENDAS.UV_PRODUTO_ROWNUMBER

INSERT PRODUTO
VALUES ('AGENDA 2030', 10, 2)

SELECT *
FROM VENDAS.UV_PRODUTO_ROWNUMBER

INSERT PRODUTO
VALUES ('GRAMPEADOR', 10, 2)

INSERT PRODUTO
VALUES ('R�GUA', 5, 2)

SELECT *
FROM VENDAS.UV_PRODUTO_ROWNUMBER

GO

CREATE VIEW VENDAS.UV_PRODUTO_TOP_POR_CATEGORIA
AS
	SELECT NOME_TIPO_PRODUTO, 
		COD_PRODUTO, 
		NOME_PRODUTO, 
		PRECO_PRODUTO
	FROM (
		SELECT TP.NOME_TIPO_PRODUTO, 
			RANK() OVER(PARTITION BY TP.COD_TIPO_PRODUTO ORDER BY P.PRECO_PRODUTO DESC) AS 'ITEM',
			P.COD_PRODUTO, 
			P.NOME_PRODUTO, 
			P.PRECO_PRODUTO
		FROM DBO.PRODUTO P 
		JOIN DBO.TIPO_PRODUTO TP
			ON TP.COD_TIPO_PRODUTO = P.COD_TIPO_PRODUTO	
		) X
	WHERE X.ITEM = 1
GO

SELECT * 
FROM VENDAS.UV_PRODUTO_TOP_POR_CATEGORIA

GO

CREATE VIEW VENDAS.UV_PRODUTO
AS 
	SELECT *
	FROM PRODUTO
GO

ALTER VIEW VENDAS.UV_PRODUTO
AS 
	SELECT COD_PRODUTO, 
		NOME_PRODUTO
	FROM PRODUTO
GO

SELECT * 
FROM VENDAS.UV_PRODUTO

GO

CREATE VIEW DBO.UV_PRODUTO
AS 
	SELECT *
	FROM PRODUTO
GO

SELECT *
FROM UV_PRODUTO

SELECT * 
FROM SYS.views

SELECT OBJECT_DEFINITION(OBJECT_ID('UV_PRODUTO'))

SELECT OBJECT_NAME(REFERENCING_ID), 
	REFERENCED_ENTITY_NAME
FROM SYS.SQL_EXPRESSION_DEPENDENCIES
ORDER BY REFERENCING_ID

CREATE TABLE PESSOA
(
	COD_PESSOA INT IDENTITY PRIMARY KEY, 
	NOME_PESSOA VARCHAR(50), 
	SEXO_PESSOA CHAR(1)
)

GO

CREATE VIEW UV_MULHERES
AS
	SELECT *
	FROM PESSOA
	WHERE SEXO_PESSOA = 'F'
GO

INSERT PESSOA
VALUES ('AD�O', 'M'), 
	('EVA', 'F')

SELECT *
FROM UV_MULHERES

INSERT UV_MULHERES
VALUES('CHICA', 'F')

SELECT *
FROM UV_MULHERES

INSERT UV_MULHERES
VALUES('CAIM', 'M')

SELECT *
FROM UV_MULHERES

SELECT *
FROM PESSOA

GO

ALTER VIEW UV_MULHERES
AS
	SELECT *
	FROM PESSOA
	WHERE SEXO_PESSOA = 'F'
	WITH CHECK OPTION
GO

INSERT UV_MULHERES 
VALUES ('ABEL', 'M')

SELECT *
FROM UV_MULHERES

DELETE UV_MULHERES
WHERE COD_PESSOA = 3

DELETE UV_MULHERES 
WHERE COD_PESSOA = 4

SELECT *
FROM UV_TIPO_PRODUTO_PRODUTO

INSERT UV_TIPO_PRODUTO_PRODUTO 
VALUES('MATERIAL PARA A�OUGUE')

INSERT UV_TIPO_PRODUTO_PRODUTO (NOME_TIPO_PRODUTO)
VALUES('MATERIAL PARA A�OUGUE')

SELECT * 
FROM TIPO_PRODUTO

GO

ALTER VIEW UV_MULHERES
	WITH ENCRYPTION
AS
	SELECT *
	FROM PESSOA
	WHERE SEXO_PESSOA = 'F'
	WITH CHECK OPTION
GO

SELECT OBJECT_DEFINITION(OBJECT_ID('UV_MULHERES'))

SELECT * 
FROM SYS.syscomments
WHERE id = OBJECT_ID('UV_MULHERES')

EXEC sp_helptext 'UV_MULHERES'

SELECT *
FROM UV_MULHERES
CROSS JOIN PESSOA 
WHERE PESSOA.SEXO_PESSOA = 'M'

SELECT *
FROM PESSOA
EXCEPT 
SELECT * 
FROM UV_MULHERES

SELECT * 
FROM PESSOA
UNION ALL
SELECT *
FROM UV_MULHERES

EXEC sp_addlinkedserver 'JOKER\SQL2012'

GO

CREATE VIEW UV_TABLES_E_VIEWS
AS
	SELECT @@SERVERNAME AS 'SERVER', 
		TABLE_CATALOG, 
		TABLE_SCHEMA,
		TABLE_NAME, 
		COLUMN_NAME
	FROM MASTER.INFORMATION_SCHEMA.COLUMNS
	UNION ALL
	SELECT 'JOKER\SQL2012', 	
		TABLE_CATALOG, 
		TABLE_SCHEMA,
		TABLE_NAME, 
		COLUMN_NAME
	FROM [JOKER\SQL2012].MASTER.INFORMATION_SCHEMA.COLUMNS
GO

SELECT * 
FROM UV_TABLES_E_VIEWS

EXEC SP_DROPSERVER 'JOKER\SQL2012'

GO

CREATE VIEW UV_VINCULADA
	WITH SCHEMABINDING
AS
	SELECT COD_PRODUTO, 
		NOME_PRODUTO, 
		PRECO_PRODUTO 
	FROM DBO.PRODUTO
GO

DROP TABLE PRODUTO

CREATE TABLE CLIENTE
(
	COD_CLIENTE INT IDENTITY PRIMARY KEY, 
	NOME_CLIENTE VARCHAR(50)
)

CREATE TABLE CONJUGE
(
	COD_CLIENTE INT REFERENCES CLIENTE PRIMARY KEY, 
	NOME_CONJUGE VARCHAR(50)
)

INSERT CLIENTE
VALUES ('AD�O'), 
	('CHICO')

INSERT CONJUGE
VALUES (1, 'EVA')

CREATE INDEX IDX_CONJUGE_NOME_CONJUGE
ON CONJUGE(NOME_CONJUGE)

SELECT C.*, 
	G.NOME_CONJUGE 
FROM CLIENTE C
JOIN CONJUGE G
	ON C.COD_CLIENTE = G.COD_CLIENTE
WHERE C.NOME_CLIENTE = 'AD�O'
	AND G.NOME_CONJUGE = 'EVA'

GO

CREATE ALTER VIEW UV_CLIENTE_CONJUGE
	WITH SCHEMABINDING
AS
	SELECT C.COD_CLIENTE, 
		C.NOME_CLIENTE, 
		G.NOME_CONJUGE 
	FROM DBO.CLIENTE C
	JOIN DBO.CONJUGE G
		ON C.COD_CLIENTE = G.COD_CLIENTE
GO

SELECT *
FROM UV_CLIENTE_CONJUGE
WHERE NOME_CLIENTE = 'AD�O'
	AND NOME_CONJUGE = 'EVA'

CREATE UNIQUE CLUSTERED INDEX IDX_UV_CLIENTE_CONJUGE
ON UV_CLIENTE_CONJUGE(NOME_CLIENTE, NOME_CONJUGE)

SELECT *
FROM UV_CLIENTE_CONJUGE

SELECT *
FROM UV_CLIENTE_CONJUGE
WHERE NOME_CLIENTE = 'AD�O'
	AND NOME_CONJUGE = 'EVA'

EXEC sp_spaceused 'CLIENTE'
EXEC sp_spaceused 'CONJUGE'
EXEC sp_spaceused 'UV_CLIENTE_CONJUGE'
