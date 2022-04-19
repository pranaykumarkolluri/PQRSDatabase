CREATE TABLE [dbo].[tbl_CI_lookup_Categories] (
    [Category_Id]   INT          IDENTITY (1, 1) NOT NULL,
    [Category_Name] VARCHAR (50) NULL,
    CONSTRAINT [PK_tbl_lookup_Categories] PRIMARY KEY CLUSTERED ([Category_Id] ASC)
);

