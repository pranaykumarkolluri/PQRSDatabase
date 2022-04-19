CREATE TABLE [dbo].[tbl_CI_lookup_Integration_Type] (
    [Method_Id]  INT           IDENTITY (1, 1) NOT NULL,
    [MethodName] VARCHAR (100) NULL,
    CONSTRAINT [PK_tbl_CI_lookup_Integration_Type] PRIMARY KEY CLUSTERED ([Method_Id] ASC)
);

