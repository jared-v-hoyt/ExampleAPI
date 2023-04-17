USE ApplicationDB;

DROP TABLE IF EXISTS [dbo].[PRODUCT];
DROP TABLE IF EXISTS [dbo].[ORDERITEM];
DROP TABLE IF EXISTS [dbo].[ORDER];

CREATE TABLE [dbo].[ORDER]
(
	[OrderId] INT NOT NULL PRIMARY KEY
);

CREATE TABLE [dbo].[ORDERITEM]
(
	[OrderItemId] INT NOT NULL PRIMARY KEY,
	[OrderId] INT FOREIGN KEY REFERENCES [dbo].[ORDER](OrderId),
	[UnitPrice] DECIMAL(10, 2),
	[Quantity] INT
)

CREATE TABLE [dbo].[PRODUCT]
(
	[ProductId] INT NOT NULL PRIMARY KEY,
	[ProductName] NVARCHAR(255)
)

INSERT INTO [dbo].[ORDER] ([orderId])
VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10);

INSERT INTO [dbo].[PRODUCT] ([productId], [productName])
VALUES (1, 'Product A'),
       (2, 'Product B'),
       (3, 'Product C'),
       (4, 'Product D'),
       (5, 'Product E'),
       (6, 'Product F'),
       (7, 'Product G'),
       (8, 'Product H'),
       (9, 'Product I'),
       (10, 'Product J');

INSERT INTO [dbo].[ORDERITEM] ([orderItemId], [orderId], [unitPrice], [quantity])
VALUES (1, 1, 19.99, 2),
       (2, 1, 15.99, 1),
       (3, 2, 9.99, 3),
       (4, 2, 12.99, 2),
       (5, 3, 25.00, 1),
       (6, 3, 30.00, 2),
       (7, 4, 7.99, 5),
       (8, 5, 15.00, 3),
       (9, 6, 10.99, 2),
       (10, 6, 20.00, 4);