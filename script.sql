Create database TodoDb;
use TodoDb;

Create Table Todo
(
	Id INT IDENTITY(1,1) NOT NULL,
	[Text] NVARCHAR(MAX),
	[Status] VARCHAR(100)
)