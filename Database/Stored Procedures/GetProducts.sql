CREATE PROCEDURE [dbo].[GetProducts]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ProductId, ProductName
	FROM [ApplicationDB].[dbo].[PRODUCT];
END