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

GO

CREATE TRIGGER UTR_PEDIDO_INSERT
ON PEDIDO
FOR INSERT
AS
	ROLLBACK
GO

CREATE TRIGGER UTR_ITEM_PEDIDO_INSERT
ON ITEM_PEDIDO
FOR INSERT
AS
	ROLLBACK
GO

INSERT PEDIDO
VALUES (3, GETDATE())

INSERT ITEM_PEDIDO
VALUES (3, 10, 20, 2)

DROP TRIGGER UTR_PEDIDO_INSERT, UTR_ITEM_PEDIDO_INSERT

GO

CREATE TRIGGER UTR_PEDIDO_INSERT_PRINT
ON PEDIDO
FOR INSERT
AS
	PRINT 'INSERI NA PEDIDO'
GO

CREATE TRIGGER UTR_PEDIDO_INSERT_OUTRO_PRINT
ON PEDIDO
FOR INSERT
AS
	PRINT 'INSERI NA PEDIDO - OUTRO'
GO

CREATE TRIGGER UTR_PEDIDO_INSERT_MAIS_UM_PRINT
ON PEDIDO
FOR INSERT
AS
	PRINT 'INSERI NA PEDIDO - MAIS UM'
GO

INSERT PEDIDO 
VALUES (3, GETDATE())

DROP TRIGGER UTR_PEDIDO_INSERT_PRINT, 
	UTR_PEDIDO_INSERT_OUTRO_PRINT, 
	UTR_PEDIDO_INSERT_MAIS_UM_PRINT 

INSERT PEDIDO 
VALUES (4, GETDATE())

DELETE PEDIDO

GO

CREATE TRIGGER UTR_PEDIDO_INSERT
ON PEDIDO
FOR INSERT
AS
	SELECT *
	FROM INSERTED
GO

INSERT PEDIDO
VALUES (1, GETDATE())

INSERT PEDIDO
VALUES (2, GETDATE()), 
	(3, GETDATE())

GO

CREATE TABLE PEDIDO_LOG
(
	ACAO CHAR(1), 
    COD_PEDIDO INT,
    DATA_PEDIDO_INS DATE,
    DATA_PEDIDO_DEL DATE
)

GO

CREATE TRIGGER UTR_PEDIDO_INSERT_LOG
ON PEDIDO
FOR INSERT
AS 
	INSERT PEDIDO_LOG(ACAO, COD_PEDIDO, DATA_PEDIDO_INS)
	SELECT 'I', *
	FROM INSERTED
GO

INSERT PEDIDO
VALUES (100, GETDATE())

SELECT * 
FROM PEDIDO_LOG

EXEC sp_helptrigger 'PEDIDO'

ALTER TABLE PEDIDO
DISABLE TRIGGER ALL

INSERT PEDIDO
VALUES (101, GETDATE()-10)

SELECT * 
FROM PEDIDO_LOG

GO

CREATE TRIGGER UTR_PEDIDO_UPDATE
ON PEDIDO
FOR UPDATE
AS
	INSERT PEDIDO_LOG
	SELECT 'U',
		I.COD_PEDIDO, 
		D.DATA_PEDIDO, 
		I.DATA_PEDIDO
	FROM INSERTED I 
	JOIN DELETED D
		ON I.COD_PEDIDO = D.COD_PEDIDO
	WHERE I.DATA_PEDIDO <> D.DATA_PEDIDO
GO

SELECT TABLE_NAME, 
	COLUMN_NAME,
    COLUMNPROPERTY(OBJECT_ID(TABLE_SCHEMA + '.' + TABLE_NAME), COLUMN_NAME, 'ColumnID') AS COLUMN_ID
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'PEDIDO';

UPDATE PEDIDO 
SET DATA_PEDIDO = DATEADD(MM, 1, DATA_PEDIDO)

SELECT *
FROM PEDIDO_LOG

DROP TRIGGER UTR_PEDIDO_UPDATE, UTR_PEDIDO_INSERT, UTR_PEDIDO_INSERT_LOG

GO

CREATE TRIGGER UTR_PEDIDO_DELETE
ON PEDIDO
FOR DELETE
AS
	INSERT PEDIDO_LOG(ACAO, COD_PEDIDO, DATA_PEDIDO_DEL)
	SELECT 'D', 
		*
	FROM DELETED
GO

DELETE FROM PEDIDO

SELECT * 
FROM PEDIDO_LOG

DROP TRIGGER UTR_PEDIDO_DELETE

EXEC sp_helptrigger	'PEDIDO'

CREATE TABLE CLIENTE
(
	COD_CLIENTE INT, 
	NOME_CLIENTE VARCHAR(50), 
	COD_FILIAL INT
)

GO

CREATE TRIGGER UTR_CLIENTE_INSERT
ON CLIENTE 
FOR INSERT
AS
	--CONSIDERANDO INSERT DE UM �NICO REGISTRO!!!
	DECLARE @COD_CLIENTE INT

	SELECT @COD_CLIENTE = ISNULL(MAX(CLIENTE.COD_CLIENTE), 0) + 1
	FROM CLIENTE 
	JOIN INSERTED 
		ON INSERTED.COD_FILIAL = CLIENTE.COD_FILIAL

	UPDATE CLIENTE 
	SET COD_CLIENTE = @COD_CLIENTE 
	WHERE COD_CLIENTE IS NULL
GO

INSERT CLIENTE (NOME_CLIENTE, COD_FILIAL)
VALUES ('ADAO', 1)

INSERT CLIENTE (NOME_CLIENTE, COD_FILIAL)
VALUES ('EVA', 1)

INSERT CLIENTE (NOME_CLIENTE, COD_FILIAL)
VALUES ('CAIM', 2)

SELECT *
FROM CLIENTE

--INSERT CLIENTE (NOME_CLIENTE, COD_FILIAL)
--VALUES ('EPAMINONDAS', 1), 
--	('CHICO', 1)

--SELECT * 
--FROM CLIENTE

GO

EXEC SP_TABLES

--AFTER -> DEPOIS DO COMANDO

--INSTEAD OF -> EM VEZ DO COMANDO -> NO LUGAR DO COMANDO

GO

CREATE TRIGGER UTR_PEDIDO_INSERT
ON PEDIDO
INSTEAD OF INSERT
AS
	SELECT * 
	FROM INSERTED
GO

INSERT PEDIDO
VALUES (1, GETDATE())

SELECT *
FROM PEDIDO

CREATE TABLE PAI
(
	COD_PAI INT IDENTITY,
	NOME_PAI VARCHAR(50)
)

CREATE TABLE FILHO
(
	COD_FILHO INT IDENTITY,
	NOME_FILHO VARCHAR(50), 
	COD_PAI INT
)

GO

CREATE VIEW UV_PAI_FILHO
AS
	SELECT NOME_PAI, 
		NOME_FILHO
	FROM PAI 
	JOIN FILHO 
		ON PAI.COD_PAI = FILHO.COD_PAI
GO

INSERT UV_PAI_FILHO(NOME_PAI)
VALUES ('ADAO')

SELECT * 
FROM PAI

SELECT * 
FROM FILHO

INSERT UV_PAI_FILHO(NOME_FILHO)
VALUES ('CAIM')

SELECT * 
FROM FILHO

GO

CREATE TRIGGER UTR_UV_PAI_FILHO_INSERT
ON UV_PAI_FILHO
INSTEAD OF INSERT
AS
	--CONSIDERANDO INS DE UM REGISTRO!!!

	DECLARE @COD_PAI INT 
	DECLARE @NOME_PAI VARCHAR(50)
	DECLARE @NOME_FILHO VARCHAR(50)

	SELECT @NOME_PAI = NOME_PAI, 
		@NOME_FILHO = NOME_FILHO 
	FROM INSERTED

	IF NOT EXISTS(SELECT * FROM PAI WHERE NOME_PAI = @NOME_PAI)
		INSERT PAI 
		VALUES (@NOME_PAI)

	SELECT @COD_PAI = COD_PAI 
	FROM PAI
	WHERE NOME_PAI = @NOME_PAI

	INSERT FILHO 
	VALUES (@NOME_FILHO, @COD_PAI)
GO

INSERT UV_PAI_FILHO
VALUES ('AGNALDO', 'NETINHO')

SELECT * 
FROM UV_PAI_FILHO

SELECT *
FROM PAI

SELECT *
FROM FILHO

GO

ALTER TRIGGER UTR_UV_PAI_FILHO_INSERT
ON UV_PAI_FILHO
INSTEAD OF INSERT
AS
	SET NOCOUNT ON

	--CONSIDERANDO INS DE UM REGISTRO!!!

	DECLARE @COD_PAI INT 
	DECLARE @NOME_PAI VARCHAR(50)
	DECLARE @NOME_FILHO VARCHAR(50)

	SELECT @NOME_PAI = NOME_PAI, 
		@NOME_FILHO = NOME_FILHO 
	FROM INSERTED

	IF NOT EXISTS(SELECT * FROM PAI WHERE NOME_PAI = @NOME_PAI)
		INSERT PAI 
		VALUES (@NOME_PAI)

	SELECT @COD_PAI = COD_PAI 
	FROM PAI
	WHERE NOME_PAI = @NOME_PAI

	INSERT FILHO 
	VALUES (@NOME_FILHO, @COD_PAI)
GO

INSERT UV_PAI_FILHO
VALUES ('PAAAAI', 'INRI CRISTO')

GO

ALTER TRIGGER UTR_UV_PAI_FILHO_INSERT
ON UV_PAI_FILHO
INSTEAD OF INSERT
AS
	SET NOCOUNT ON

	--CONSIDERANDO INS DE UM REGISTRO!!!

	DECLARE @COD_PAI INT 
	DECLARE @NOME_PAI VARCHAR(50)
	DECLARE @NOME_FILHO VARCHAR(50)

	SELECT @NOME_PAI = NOME_PAI, 
		@NOME_FILHO = NOME_FILHO 
	FROM INSERTED

	IF NOT EXISTS(SELECT * FROM PAI WHERE NOME_PAI = @NOME_PAI)
		INSERT PAI 
		VALUES (@NOME_PAI)

	SELECT @COD_PAI = COD_PAI 
	FROM PAI
	WHERE NOME_PAI = @NOME_PAI

	INSERT FILHO 
	VALUES (@NOME_FILHO, @COD_PAI)

	--NAO FAZER!!!!!!!!!!
	SELECT IDENT_CURRENT('PAI') AS 'COD_PAI', IDENT_CURRENT('FILHO') AS 'COD_FILHO' 
GO

INSERT UV_PAI_FILHO
VALUES ('ODIN', 'THOR')

EXEC SP_CONFIGURE 'show advanced options', 1
GO
RECONFIGURE

EXEC SP_CONFIGURE 

EXEC SP_CONFIGURE 'disallow results from triggers', 1
GO
RECONFIGURE

EXEC SP_CONFIGURE 'show advanced options', 0
GO
RECONFIGURE

INSERT UV_PAI_FILHO
VALUES ('ODIN', 'LOKI') --N�O �, MESMO!!!

CREATE TABLE T1
(
	CAMPO INT
)

CREATE TABLE T2
(
	CAMPO INT
)

CREATE TABLE T3
(
	CAMPO INT
)

GO

CREATE TRIGGER UTR_T1_INS
ON T1
FOR INSERT
AS
	INSERT T2
	SELECT *
	FROM INSERTED
GO

CREATE TRIGGER UTR_T2_INS
ON T2
FOR INSERT
AS
	INSERT T3
	SELECT *
	FROM INSERTED
GO

INSERT T2
VALUES(1)

SELECT * 
FROM T3

SELECT *
FROM T2

INSERT T1
VALUES (11)

SELECT * 
FROM T1

SELECT * 
FROM T2

SELECT * 
FROM T3

DROP TABLE T3
DROP TRIGGER UTR_T2_INS

GO

CREATE TRIGGER UTR_T2_INS
ON T2
FOR INSERT
AS
	INSERT T1
	SELECT *
	FROM INSERTED
GO

INSERT T1 
VALUES (100)

SELECT * 
FROM T1

SELECT * 
FROM T2

DROP TRIGGER UTR_T1_INS, UTR_T2_INS

GO

CREATE TRIGGER UTR_T1_INS
ON T1
FOR INSERT
AS
	IF @@NESTLEVEL = 32 RETURN
	
	INSERT T2
	SELECT *
	FROM INSERTED
GO

CREATE TRIGGER UTR_T2_INS
ON T2
FOR INSERT
AS
	IF @@NESTLEVEL = 32 RETURN
	
	INSERT T1
	SELECT *
	FROM INSERTED
GO

INSERT T1 
VALUES (100)

SELECT * 
FROM T1

SELECT * 
FROM T2

DROP TRIGGER UTR_T1_INS, UTR_T2_INS

GO

CREATE TRIGGER UTR_T1_UPDATE
ON T1
FOR UPDATE
AS
	SELECT CASE WHEN UPDATE(CAMPO) THEN 'ALTEROU' ELSE 'NEM' END AS 'CAMPO ALTERADO?'
GO

EXEC SP_CONFIGURE 'show advanced options', 1
GO
RECONFIGURE

EXEC SP_CONFIGURE 'disallow results from triggers', 0
GO
RECONFIGURE

EXEC SP_CONFIGURE 'show advanced options', 0
GO
RECONFIGURE

UPDATE T1 
SET CAMPO = CAMPO + 1

UPDATE T1 
SET CAMPO = CAMPO

--TENHO Y Z X B C A
--QUERO X Y Z A B C
EXEC sp_settriggerorder 'UTR_B', 'LAST', 'INSERT'
--Y Z X A C B
EXEC sp_settriggerorder 'UTR_C', 'LAST', 'INSERT'
--Y Z X A B C
EXEC sp_settriggerorder 'UTR_X', 'FIRST', 'INSERT'
--X Y Z A B C

EXEC SP_HELPTEXT SP_HELPTEXT

EXEC SP_HELPTEXT XP_CMDSHELL

EXEC SP_HELP SP_HELPTEXT

EXEC SP_HELP XP_CMDSHELL
