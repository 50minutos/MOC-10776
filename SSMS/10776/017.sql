DECLARE @X XMLUSE master

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


SET @X = 'OI'
SELECT @X

GO

DECLARE @X XML
SET @X = '<NOME>AGNALDO</NOME>'
SELECT @X

GO

DECLARE @X XML
SET @X = '<NOME>AGNALDO</NOME><NOME>NETINHO</NOME><NOME>PEDRO</NOME>'
SELECT @X

GO

--DECLARE @X XML
--SET @X = '<NOME>AGNALDO'
--SELECT @X

GO

CREATE TABLE PRODUTO
(
	COD_PRODUTO INT IDENTITY PRIMARY KEY, 
	NOME_PRODUTO VARCHAR(50), 
	ESPECIFICACAO_PRODUTO XML --ESPECIFICACAO -> FABRICANTE, PESO, DETALHES
)

INSERT PRODUTO
VALUES ('MARTELO DE CINZELAR', '<ESPECIFICACAO><FABRICANTE>TRAMONTINA</FABRICANTE><PESO>120GR</PESO><DETALHES>BL�-BL�-BL�</DETALHES></ESPECIFICACAO>'), 
	('MARRETA', 'SBLURBES')

SELECT * 
FROM PRODUTO

GO

--www.w3schools.com
--www.devguru.com

CREATE XML SCHEMA COLLECTION SCHEMA_ESPECIFICACAO_PRODUTO
AS
'<schema xmlns="http://www.w3.org/2001/XMLSchema">
	<element name="ESPECIFICACAO">
		<complexType>
			<sequence>
				<element name="FABRICANTE" type="string"/>
				<element name="PESO" type="int"/>
				<element name="DETALHES" type="string"/>
			</sequence>
		</complexType>
	</element>	
</schema>'
GO

DROP TABLE PRODUTO

CREATE TABLE PRODUTO
(
	COD_PRODUTO INT IDENTITY PRIMARY KEY, 
	NOME_PRODUTO VARCHAR(50), 
	ESPECIFICACAO_PRODUTO XML(SCHEMA_ESPECIFICACAO_PRODUTO)
)

INSERT PRODUTO
VALUES ('MARTELO DE CINZELAR', '<ESPECIFICACAO><FABRICANTE>TRAMONTINA</FABRICANTE><PESO>120</PESO><DETALHES>BL�-BL�-BL�</DETALHES></ESPECIFICACAO>')

INSERT PRODUTO
VALUES ('MARRETA', 'SBLURBES')

SELECT * 
FROM PRODUTO

DECLARE @X XML(SCHEMA_ESPECIFICACAO_PRODUTO) = '<ESPECIFICACAO><FABRICANTE>TRAMONTINA</FABRICANTE><PESO>120</PESO><DETALHES>BL�-BL�-BL�</DETALHES></ESPECIFICACAO>'
PRINT CAST(@X AS VARCHAR(MAX))

SELECT * 
FROM SYS.xml_schema_collections

SELECT *
FROM SYS.xml_schema_elements

SELECT *
FROM SYS.xml_schema_components

SELECT *
FROM SYS.xml_schema_component_placements

DROP TABLE PRODUTO

CREATE TABLE PRODUTO
(
	COD_PRODUTO INT IDENTITY PRIMARY KEY, 
	NOME_PRODUTO VARCHAR(50), 
	ESPECIFICACAO_PRODUTO XML(CONTENT SCHEMA_ESPECIFICACAO_PRODUTO)
)

INSERT PRODUTO
VALUES ('MARTELO DE CINZELAR', '<ESPECIFICACAO><FABRICANTE>TRAMONTINA</FABRICANTE><PESO>120</PESO><DETALHES>BL�-BL�-BL�</DETALHES></ESPECIFICACAO>')

INSERT PRODUTO
VALUES ('OUTRO MARTELO DE CINZELAR', '<ESPECIFICACAO><FABRICANTE>TRAMONTINA</FABRICANTE><PESO>120</PESO><DETALHES>BL�-BL�-BL�</DETALHES></ESPECIFICACAO><ESPECIFICACAO><FABRICANTE>TRAMONTINA</FABRICANTE><PESO>120</PESO><DETALHES>BL�-BL�-BL�</DETALHES></ESPECIFICACAO>')

SELECT * 
FROM PRODUTO

DROP TABLE PRODUTO

CREATE TABLE PRODUTO
(
	COD_PRODUTO INT IDENTITY PRIMARY KEY, 
	NOME_PRODUTO VARCHAR(50), 
	ESPECIFICACAO_PRODUTO XML(DOCUMENT SCHEMA_ESPECIFICACAO_PRODUTO)
)

INSERT PRODUTO
VALUES ('MARTELO DE CINZELAR', '<ESPECIFICACAO><FABRICANTE>TRAMONTINA</FABRICANTE><PESO>120</PESO><DETALHES>BL�-BL�-BL�</DETALHES></ESPECIFICACAO>')

INSERT PRODUTO
VALUES ('OUTRO MARTELO DE CINZELAR', '<ESPECIFICACAO><FABRICANTE>TRAMONTINA</FABRICANTE><PESO>120</PESO><DETALHES>BL�-BL�-BL�</DETALHES></ESPECIFICACAO><ESPECIFICACAO><FABRICANTE>TRAMONTINA</FABRICANTE><PESO>120</PESO><DETALHES>BL�-BL�-BL�</DETALHES></ESPECIFICACAO>')

SELECT *
FROM PRODUTO

EXEC sp_helpindex PRODUTO

CREATE PRIMARY XML INDEX IDX_XML_PRODUTO_ESPECIFICACAO_PRODUTO
ON PRODUTO(ESPECIFICACAO_PRODUTO)

CREATE XML INDEX IDX_XML_PRODUTO_PROP
ON PRODUTO(ESPECIFICACAO_PRODUTO)
USING XML INDEX IDX_XML_PRODUTO_ESPECIFICACAO_PRODUTO
FOR PROPERTY

CREATE XML INDEX IDX_XML_PRODUTO_PATH
ON PRODUTO(ESPECIFICACAO_PRODUTO)
USING XML INDEX IDX_XML_PRODUTO_ESPECIFICACAO_PRODUTO
FOR PATH

CREATE XML INDEX IDX_XML_PRODUTO_VALUE
ON PRODUTO(ESPECIFICACAO_PRODUTO)
USING XML INDEX IDX_XML_PRODUTO_ESPECIFICACAO_PRODUTO
FOR VALUE

SELECT *
FROM SYS.indexes
WHERE OBJECT_ID = OBJECT_ID('PRODUTO')

SELECT *
FROM SYS.xml_indexes
WHERE OBJECT_ID = OBJECT_ID('PRODUTO')

USE DB

DROP TABLE PRODUTO