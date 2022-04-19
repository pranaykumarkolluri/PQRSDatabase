CREATE TABLE [dbo].[tbl_lookup_File_Signatures] (
    [Id]                    INT           IDENTITY (1, 1) NOT NULL,
    [Extension]             VARCHAR (10)  NULL,
    [Signature]             VARCHAR (250) NULL,
    [Description]           VARCHAR (500) NULL,
    [Full_Length_Signature] VARCHAR (250) NULL,
    CONSTRAINT [PK_tbl_lookup_File_Signatures] PRIMARY KEY CLUSTERED ([Id] ASC)
);

