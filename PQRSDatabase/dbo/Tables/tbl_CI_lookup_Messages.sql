CREATE TABLE [dbo].[tbl_CI_lookup_Messages] (
    [Id]          INT           IDENTITY (1, 1) NOT NULL,
    [Message]     VARCHAR (100) NULL,
    [Description] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_tbl_CI_lookup_Messages] PRIMARY KEY CLUSTERED ([Id] ASC)
);

