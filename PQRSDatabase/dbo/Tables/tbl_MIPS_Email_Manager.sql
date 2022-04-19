CREATE TABLE [dbo].[tbl_MIPS_Email_Manager] (
    [Id]          INT           IDENTITY (1, 1) NOT NULL,
    [FromAddress] VARCHAR (250) NULL,
    [ToAddress]   VARCHAR (900) NULL,
    [Subject]     VARCHAR (900) NULL,
    [Body]        VARCHAR (MAX) NULL,
    [Category]    VARCHAR (500) NULL,
    [CreatedBy]   INT           NULL,
    [CreatedDate] DATETIME      NULL,
    [UpdatedBy]   INT           NULL,
    [UpdatedDate] DATETIME      NULL,
    CONSTRAINT [PK_tbl_MIPS_Email_Manager] PRIMARY KEY CLUSTERED ([Id] ASC)
);

