# ExampleAPI

This project uses the following technologies:

- [Visual Studio Code](https://code.visualstudio.com/)
- The [.devcontainer](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension from Microsoft
- [Docker](https://www.docker.com/)
- [Postman](https://www.postman.com/)

## Steps To Recreate The Project

1. Create the directory in which you want to store the project. In this example I named mine `ExampleAPI`.

2. Open up the command palette in Visual Studio Code and do the following:

   - Run the command "Dev Containers: Add Dev Configuration Files..."
   - Search for the "C# (.NET) and MS SQL" file
   - Use the default .NET version
   - You do not need to install any additional features

   You will notice that there are multiple spots in the created files that specify a default password of `P@ssw0rd`. I _highly_ recommend keeping this default password.

**NOTE: you will need to have Docker running before doing the following step.**

3.  Run the container by opening the command palette and running the "Reopen in Container" command (it might take a bit for the images to be downloaded).

4.  On the left-hand-side of VS Code you should see a tab called `SQL Server`. Open up the tab and connect to the `mssql-container` using the default database password. If prompted, select `Enable Trust Server Certificate`.

5.  On the left-hand-side of VS Code you should see a tab called `Database Projects`. Open up the tab and follow these steps:

    - Click the `Create new` button
    - Select `SQL Server Database`
    - Provide a name for the project (I called mine `Database`)
    - Choose the default location to store the project
    - Choose the default version of SQL Server
    - Select `Yes (Recommended)`

6.  We'll now create the necessary tables for the project. Right-click the `Database` folder, select `Add Item — Table`, and name the file `Tables`.

7.  Update the file to look like the following:

```sql
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
```

8. Execute the entire file by clicking the green play button in the upper-right-hand-side of the file (you can also execute the queries one at a time by highlighting each query and clicking the green play button).

**NOTE:** when prompted, choose the `mssql-container` option and provide your database password to be able to execute these queries.

9. Create a new folder called `Stored Procedures` at the root of the `Database` database project by right clicking on the `Database` database project and clicking `Add Folder`.

10. Right click the `Stored Procedures` folder we just created and click `Add Item — Stored Procedure`. Name the stored procedure `GetProducts`.

11. Replace the `GetProducts.sql` file with the following contents:

```sql
CREATE PROCEDURE [dbo].[GetProducts]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ProductId, ProductName
	FROM [ApplicationDB].[dbo].[PRODUCT];
END
```

12. We now need to execute the contents of the `Database/Stored Procedures/GetProducts.sql` file. To do this:

    - Click on the `SQL Server` tab on the left-hand-side of VS Code
    - Expand the `Databases` folder
    - Right-click `ApplicationDB`, and select `New Query`
    - Paste the code from `Database/Stored Procedures/GetProducts.sql` into this file and execute the query

    After execution, you can close the file without saving.

13. We now need to create the backend application that will connect to our database. Open up a new terminal in the `ExampleAPI` directory and run the following command in the terminal:

```bash
dotnet new webapi \
	--no-https \
	--no-openapi \
	--use-minimal-apis \
	--use-program-main \
	--name Backend
```

**NOTE:** you can safely delete the `WeatherForecast.cs` file that is created by default.

**NOTE:** at some point, you might be prompted to download Mono to your project. This is unnecessary, as the project will automatically download it.

14. We now have to provide a connection string to be able to connect to the database. To do this, go to your `Backend/appsettings.json` file and replace the existing code with the following:

```json
{
	"Logging": {
		"LogLevel": {
			"Default": "Information",
			"Microsoft.AspNetCore": "Warning"
		}
	},
	"AllowedHosts": "*",
	"ConnectionStrings": {
		"local_database": "Server=localhost;Database=ApplicationDB;User Id=sa;Password=P@ssw0rd;"
	}
}
```

15. We now need to add an endpoint to our API that calls the stored procedure using the connection string we just created. Update `Backend/Program.cs` to look like the following:

```c#
using System.Data;
using System.Data.SqlClient;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;

namespace ExampleAPI;

public class Program
{
    public static void Main(string[] args)
    {
        var MyAllowSpecificOrigins = "_MyAllowSubdomainPolicy";

        var builder = WebApplication.CreateBuilder(args);

        builder.Services.AddCors(options =>
        {
            options.AddPolicy(name: MyAllowSpecificOrigins,
                policy =>
                {
                    policy.WithOrigins("http://localhost:3000") // TODO: change to the port number that the frontend application runs on
                        .AllowAnyHeader()
                        .AllowAnyMethod();
                });
        });

        var app = builder.Build();

        app.UseCors(MyAllowSpecificOrigins);

        app.MapGet("/products", async (HttpContext httpContext) =>
        {
            string connectionString = builder.Configuration.GetConnectionString("local_database");

            List<Product> products = new List<Product>();

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand("GetProducts", connection);
                command.CommandType = CommandType.StoredProcedure;

                await connection.OpenAsync();

                using (SqlDataReader reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        Product product = new Product();
                        product.ProductId = reader.GetInt32(0);
                        product.ProductName = reader.GetString(1);

                        products.Add(product);
                    }
                }
            }

            return products;
        });

        app.Run();
    }
}

public class Product
{
    public int ProductId { get; set; }
    public string? ProductName { get; set; }
}
```

16. To be able to use the code in `Backend/Program.cs` we need to install the `System.Data.SqlClient` package. We can do this manually by updating our `Backend/Backend.csproj` file to look like the following:

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net7.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="System.Data.SqlClient" Version="4.8.2" />
  </ItemGroup>

</Project>
```

17. We can run the project by opening a new terminal and running the following commands:

```bash
cd Backend
dotnet run
```

18. To test if the project is working, open Postman and send a `GET` request to the following URL: `http://localhost:<port_number>/products` where `<port_number>` is the forwarded port of the project.

**NOTE:** You can find this port in VS Code by selecting the `PORTS` tab that is located directly to the right of the `TERMINAL` tab when you open up a new terminal in VS Code.

19. Finally, to send the request from your application's frontend, open up the `code` section on the right side panel in Postman and select the appropriate request library that your application uses. Paste the code into your frontend application.
