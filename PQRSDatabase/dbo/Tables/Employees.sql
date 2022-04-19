CREATE TABLE [dbo].[Employees] (
    [code]         NVARCHAR (50)   NOT NULL,
    [name]         NVARCHAR (50)   NULL,
    [gender]       NVARCHAR (50)   NULL,
    [annualSalary] DECIMAL (18, 3) NULL,
    [dateOfBirth]  NVARCHAR (50)   NULL,
    PRIMARY KEY CLUSTERED ([code] ASC)
);

