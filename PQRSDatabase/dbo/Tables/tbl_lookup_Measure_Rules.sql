CREATE TABLE [dbo].[tbl_lookup_Measure_Rules] (
    [Rule_Id]     INT           IDENTITY (1, 1) NOT NULL,
    [RuleName]    VARCHAR (100) NULL,
    [Description] VARCHAR (MAX) NULL,
    [CategoryId]  INT           NULL,
    [TableName]   VARCHAR (50)  NULL,
    [ColumnName]  VARCHAR (50)  NULL
);

