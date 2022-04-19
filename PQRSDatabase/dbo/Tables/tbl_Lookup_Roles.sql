CREATE TABLE [dbo].[tbl_Lookup_Roles] (
    [Role_ID]   INT          IDENTITY (1, 1) NOT NULL,
    [Role_Name] VARCHAR (50) NULL,
    [IsActive]  BIT          NULL,
    CONSTRAINT [PK_tbl_Lookup_Roles] PRIMARY KEY CLUSTERED ([Role_ID] ASC)
);

