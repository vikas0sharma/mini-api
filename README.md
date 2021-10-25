# mini-api
Mini CRUD API, created using a single file. No class, no startup just top level statements.

## Steps to run
 - Install .Net 6 SDK
 - Run scripts.sql to generate database and schema
 - Run command `dotnet restore` to restore the Nuget packages
 - Run command `dotnet build` to build the app
 - Run comand `dotnet run` to run the app
 - Go to https://localhost:5001/swagger/index.html to see the swagger of the app
 
## Complete code in Program.cs
```cs
using Dapper;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Dapper.Contrib.Extensions;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<GetConnection>(sp => 
    async () => {
        string connectionString = sp.GetService<IConfiguration>()["ConnectionString"];
        var connection = new SqlConnection(connectionString);
        await connection.OpenAsync();
        return connection;
});

var app = builder.Build();
app.UseSwagger();
app.UseSwaggerUI();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

app.MapGet("/", () => "Mini TODO API");
app.MapGet("/todos", async (GetConnection connectionGetter) =>
{
    using var con = await connectionGetter();
    return con.GetAll<ToDo>().ToList();
});
app.MapGet("/todos/{id}", async (GetConnection connectionGetter, int id) =>
{
    using var con = await connectionGetter();
    return con.Get<ToDo>(id);
});
app.MapDelete("/todos/{id}", async (GetConnection connectionGetter, int id) =>
{
    using var con = await connectionGetter();
    con.Delete(new ToDo(id,"",""));
    return Results.NoContent();
});
app.MapPost("/todos", async (GetConnection connectionGetter, ToDo todo) =>
{
    using var con = await connectionGetter();
    var id = con.Insert(todo);
    return Results.Created($"/todos/{id}", todo);
});
app.MapPut("/todos", async (GetConnection connectionGetter, ToDo todo) =>
{
    using var con = await connectionGetter();
    var id = con.Update(todo);
    return Results.Ok();
});

app.Run();

[Table("Todo")]
public record ToDo(int Id, string Text, string Status);

public delegate Task<IDbConnection> GetConnection();

```
