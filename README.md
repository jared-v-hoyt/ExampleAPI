# ExampleAPI

This `README` contains all necessary steps to create a containerized API that connects to a SQL Server local database. This is to be used as a guide in setting up the final project for CSCE-361 at the University of Nebraska-Lincoln.

## Known Bugs

- This project does not run properly on any Apple chip running ARM

## Steps To Recreate The Project

1. Use the links to download the following:

   - [Visual Studio Code](https://code.visualstudio.com/docs/setup/setup-overview)
     - **(Mac only):** Ensure that VS Code is installed in your `PATH`
   - [Docker](https://www.docker.com/)
   - [Postman](https://www.postman.com/)

2. Open up a new terminal (Mac) or Powershell (Windows) instance and run the following commands:

```bash
cd Desktop
mkdir ExampleAPI
code --install-extension ms-vscode-remote.remote-containers
code ExampleAPI
```

3.  Open up the command palette in Visual Studio Code and do the following:

    - Run the command `Dev Containers: Add Dev Configuration Files...`
    - Search for the `C# (.NET) and MS SQL` template
    - Use the default .NET version
    - You do not need to install any additional features

    You will notice that there are multiple spots in the created files that specify a default password of `P@ssw0rd`. I _highly_ recommend keeping this default password.

**NOTE: you will need to have Docker running before doing the following step.**

4.  Run the container by opening the command palette and running the `Reopen in Container` command (it might take a bit for the images to be downloaded).

5.  On the left-hand-side of VS Code you should see a tab called **SQL Server**. Open up the tab and connect to the _mssql-container_ using the default database password. When prompted, select **Enable Trust Server Certificate**.

6.  On the left-hand-side of VS Code you should see a tab called **Database Projects**. Open up the tab and follow these steps:

    - Click the `Create new` button
    - Select `SQL Server Database`
    - Provide a name for the project (I called mine `Database`)
    - Choose the default location to store the project
    - Choose the default version of SQL Server
    - Select `Yes (Recommended)`

7.  We'll now create the necessary tables for the project. Right-click the `Database` folder, select `Add Item — Table`, and name the file `Tables`.

8.  Update the file to look like the following:

```sql
USE ApplicationDB;
@@ -90,15 +106,16 @@ VALUES (1, 1, 19.99, 2),
       (10, 6, 20.00, 4);
```

9. Execute the entire file by clicking the green play button in the upper-right-hand-side of the file (you can also execute the queries one at a time by highlighting each query and clicking the green play button).

**NOTE:** when prompted, choose the `mssql-container` option and provide your database password to be able to execute these queries.

10. Create a new folder called `Stored Procedures` at the root of the `Database` database project by right clicking on the `Database` database project and clicking `Add Folder`.

11. Right click the `Stored Procedures` folder we just created and click `Add Item — Stored Procedure`. Name the stored procedure `GetProducts`.

12. Replace the `GetProducts.sql` file with the following contents:

```sql
CREATE PROCEDURE [dbo].[GetProducts]
AS
@@ -110,15 +127,17 @@ BEGIN
END
```

13. We now need to execute the contents of the `Database/Stored Procedures/GetProducts.sql` file. To do this:

    - Click on the `SQL Server` tab on the left-hand-side of VS Code
    - Expand the `Databases` folder
    - Right-click `ApplicationDB`, and select `New Query`
    - Paste the code from `Database/Stored Procedures/GetProducts.sql` into this file and execute the query

    After execution, you can close the file without saving.

14. We now need to create the backend application that will connect to our database. Open up a new terminal in the `ExampleAPI` directory and run the following command in the terminal:

```bash
dotnet new webapi \
	--no-https \
@@ -128,18 +147,22 @@ dotnet new webapi \
	--name Backend
```

**NOTE:** you might need to refresh your solution expolorer after running these commands.

**NOTE:** you can safely delete the `WeatherForecast.cs` file that is created by default.

**NOTE:** at some point, you might be prompted to download Mono to your project. This is unnecessary, as the project will automatically download it.

15. We now have to provide a connection string to be able to connect to the database. To do this, go to your `Backend/appsettings.json` file and add the following JSON:

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

16. We now need to add an endpoint to our API that calls the stored procedure using the connection string we just created. Update `Backend/Program.cs` to look like the following:

```c#
using System.Data;
using System.Data.SqlClient;
@@ -211,7 +234,8 @@ public class Product
}
```

17. To be able to use the code in `Backend/Program.cs` we need to install the `System.Data.SqlClient` package. We can do this manually by updating our `Backend/Backend.csproj` file to look like the following:

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">

@@ -220,22 +244,23 @@ public class Product
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="System.Data.SqlClient" Version="4.8.2" />
  </ItemGroup>

</Project>
```

18. We can run the project by opening a new terminal and running the following commands:

```bash
cd Backend
dotnet run
```

19. To test if the project is working, open Postman and send a `GET` request to the following URL: `http://localhost:<port_number>/products` where `<port_number>` is the forwarded port of the project.

**NOTE:** You can find this port in VS Code by selecting the `PORTS` tab that is located directly to the right of the `TERMINAL` tab when you open up a new terminal in VS Code.

20. Finally, to send the request from your application's frontend, open up the `code` section on the right side panel in Postman and select the appropriate request library that your application uses. Paste the code into your frontend application.
