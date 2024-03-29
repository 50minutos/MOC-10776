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

CREATE TABLE dbo.PEDIDO
(
    COD_PEDIDO INT IDENTITY PRIMARY KEY,
    DATA_PEDIDO DATE
)

INSERT PEDIDO 
VALUES ('20130101'), 
	('20130202'), 
	('20130303'), 
	('20130404') 

SET IMPLICIT_TRANSACTIONS ON
 
SELECT @@TRANCOUNT

UPDATE PEDIDO SET DATA_PEDIDO = DATEADD(DD, 1, DATA_PEDIDO)

SELECT @@TRANCOUNT

COMMIT

SELECT @@TRANCOUNT

SET IMPLICIT_TRANSACTIONS OFF

BEGIN TRAN

INSERT PEDIDO
VALUES (GETDATE())

COMMIT

SELECT @@TRANCOUNT

EXEC sp_addlinkedserver 'JOKER\SQL2012'

BEGIN DISTRIBUTED TRAN

INSERT PEDIDO 
VALUES ('20130101')

INSERT [JOKER\SQL2012].DB.DBO.TIPO_PRODUTO(NOME_TIPO_PRODUTO)
VALUES ('FERRAMENTA')

SELECT @@TRANCOUNT

SELECT * 
FROM PEDIDO

SET XACT_ABORT ON

BEGIN DISTRIBUTED TRAN

INSERT PEDIDO 
VALUES ('20130101')

INSERT [JOKER\SQL2012].DB.DBO.TIPO_PRODUTO(NOME_TIPO_PRODUTO)
VALUES ('MATERIAL DE ESCRITÓRIO')

SELECT @@TRANCOUNT

COMMIT

SELECT * 
FROM PEDIDO

SET XACT_ABORT ON

BEGIN DISTRIBUTED TRAN

INSERT PEDIDO 
VALUES ('20130101')

INSERT [JOKER\SQL2012].DB.DBO.TIPO_PRODUTO(NOME_TIPO_PRODUTO)
VALUES ('MATERIAL DE ESCRITÓRIO')

SELECT @@TRANCOUNT

SELECT * 
FROM PEDIDO

BEGIN TRAN

UPDATE PEDIDO 
SET DATA_PEDIDO = DATA_PEDIDO

--EM OUTRA JANELA

SET LOCK_TIMEOUT 1000

SELECT *
FROM PEDIDO

SET LOCK_TIMEOUT -1

SELECT *
FROM PEDIDO
WITH (NOLOCK)

--VOLTAR A ESSA JANELA

EXEC SP_LOCK

--6 - X - KEY 

ROLLBACK

BEGIN TRAN

UPDATE PEDIDO 
WITH (TABLOCK)
SET DATA_PEDIDO = DATA_PEDIDO

EXEC SP_LOCK

--1 - X - TAB

ROLLBACK

BEGIN TRAN

UPDATE PEDIDO 
WITH (PAGLOCK)
SET DATA_PEDIDO = DATA_PEDIDO

EXEC SP_LOCK

--1 - X - PAG

SELECT *
FROM SYS.dm_tran_locks

SELECT *
FROM SYS.dm_tran_active_transactions

SELECT *
FROM SYS.dm_tran_session_transactions

SELECT *
FROM SYS.dm_tran_current_transaction	

ROLLBACK

--MOSTRAR PROFILER CAPTURANDO LOCKS

BEGIN TRAN

UPDATE PEDIDO 
WITH (PAGLOCK)
SET DATA_PEDIDO = DATA_PEDIDO


EXEC SP_LOCK

COMMIT