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
FROM PRODUTO
WHERE COD_PRODUTO = 1

SELECT * 
FROM PRODUTO
WHERE COD_PRODUTO = 2

SELECT * FROM PRODUTO WHERE COD_PRODUTO = 2

SELECT CP.USECOUNTS, 
	CP.cacheobjtype, 
	CP.objtype, 
	ST.text
FROM SYS.dm_exec_cached_plans CP
CROSS APPLY SYS.dm_exec_SQL_text(PLAN_HANDLE) ST
WHERE DBID = DB_ID()
ORDER BY TEXT

GO

CREATE PROC USP_PRODUTO_SELECT
	@COD_PRODUTO INT
AS
	SET NOCOUNT ON

	SELECT * 
	FROM PRODUTO
	WHERE COD_PRODUTO = @COD_PRODUTO
GO

EXEC USP_PRODUTO_SELECT 1
EXEC USP_PRODUTO_SELECT 2
EXEC USP_PRODUTO_SELECT 3

SELECT CP.USECOUNTS, 
	CP.cacheobjtype, 
	CP.objtype, 
	ST.text
FROM SYS.dm_exec_cached_plans CP
CROSS APPLY SYS.dm_exec_SQL_text(PLAN_HANDLE) ST
WHERE DBID = DB_ID()
ORDER BY TEXT

GO

EXEC sp_depends 'USP_PRODUTO_SELECT'

GO

CREATE PROC USP_CHAMA
AS
	EXEC USP_PRODUTO_SELECT 1
	EXEC USP_PRODUTO_SELECT 11
	EXEC USP_PRODUTO_SELECT 111
	EXEC USP_PRODUTO_SELECT 1111
GO

EXEC sp_depends 'USP_PRODUTO_SELECT'

EXEC sp_depends 'USP_CHAMA'

SELECT * 
FROM SYS.sql_expression_dependencies
WHERE REFERENCING_ID = OBJECT_ID('USP_PRODUTO_SELECT')

DECLARE @OBJECTID INT = OBJECT_ID('DBO.USP_PRODUTO_SELECT', 'P')

SELECT * 
FROM SYS.DM_EXEC_DESCRIBE_FIRST_RESULT_SET_FOR_OBJECT(@OBJECTID, 1)

--SELECT TOP 0 * INTO @TMP FROM PRODUTO

CREATE TABLE #TMP 
(
	COD_PRODUTO INT, 
	NOME_PRODUTO VARCHAR(50), 
	PRECO_PRODUTO DEC(9,2), 
	COD_TIPO_PRODUTO INT
)

INSERT #TMP 
EXEC USP_PRODUTO_SELECT 1

SELECT *
FROM #TMP

DROP TABLE #TMP

EXEC USP_PRODUTO_SELECT 1
WITH RESULT SETS
(
	(
		COD INT, 
		NOME VARCHAR(50), 
		PRECO DEC(9,2), 
		COD INT
	)
)

GO

-----------------
--N�O USAR!!!!!!!!
-----------------
CREATE PROC USP_NAO_USAR
	@WHERE VARCHAR(MAX) = NULL
	WITH RECOMPILE
AS
	DECLARE @CMD VARCHAR(MAX) = 'SELECT * FROM PRODUTO'

	IF @WHERE IS NOT NULL
		SET @CMD += (' WHERE ' + @WHERE)

	EXECUTE(@CMD)
GO

EXEC USP_NAO_USAR

EXEC USP_NAO_USAR 'PRECO_PRODUTO >= 10'

EXEC USP_NAO_USAR 'COD_PRODUTO = 1'

---------------------------
--FINAL DO N�O USAR!!!!!!!!
---------------------------

DBCC FREEPROCCACHE

SELECT CP.USECOUNTS, 
	CP.cacheobjtype, 
	CP.objtype, 
	ST.text
FROM SYS.dm_exec_cached_plans CP
CROSS APPLY SYS.dm_exec_SQL_text(PLAN_HANDLE) ST
WHERE DBID = DB_ID()
ORDER BY TEXT

EXEC USP_NAO_USAR

EXEC USP_NAO_USAR 'PRECO_PRODUTO >= 10'

EXEC USP_NAO_USAR 'COD_PRODUTO = 1'

SELECT CP.USECOUNTS, 
	CP.cacheobjtype, 
	CP.objtype, 
	ST.text
FROM SYS.dm_exec_cached_plans CP
CROSS APPLY SYS.dm_exec_SQL_text(PLAN_HANDLE) ST
WHERE DBID = DB_ID()
ORDER BY TEXT

EXEC USP_PRODUTO_SELECT 100

SELECT CP.USECOUNTS, 
	CP.cacheobjtype, 
	CP.objtype, 
	ST.text
FROM SYS.dm_exec_cached_plans CP
CROSS APPLY SYS.dm_exec_SQL_text(PLAN_HANDLE) ST
WHERE DBID = DB_ID()
ORDER BY TEXT

SELECT @@NESTLEVEL

GO

CREATE PROC USP_A
AS
	SELECT @@NESTLEVEL
	EXEC USP_B
GO

CREATE PROC USP_B
AS
	SELECT @@NESTLEVEL
GO

EXEC USP_A

GO

CREATE PROC USP_FAZ_NADA
	WITH ENCRYPTION
AS
	PRINT 'FIZ NADA'
GO

EXEC USP_FAZ_NADA

EXEC SP_HELPTEXT USP_FAZ_NADA

