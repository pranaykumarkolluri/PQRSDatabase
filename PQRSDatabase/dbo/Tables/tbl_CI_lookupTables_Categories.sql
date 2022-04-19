CREATE TABLE [dbo].[tbl_CI_lookupTables_Categories] (
    [Category_Id]   INT           IDENTITY (1, 1) NOT NULL,
    [Category_Name] VARCHAR (500) NULL,
    CONSTRAINT [PK_tbl_CI_lookupTables_Categories] PRIMARY KEY CLUSTERED ([Category_Id] ASC)
);

