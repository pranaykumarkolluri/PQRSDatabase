CREATE TABLE [dbo].[tbl_MIPS_Email_History] (
    [Id]               INT            IDENTITY (1, 1) NOT NULL,
    [Email_Manager_Id] INT            NULL,
    [EmailSubject]     VARCHAR (5000) NULL,
    [EmailBody]        VARCHAR (MAX)  NULL,
    [Email_Status]     BIT            NULL,
    [CreatedBy]        INT            NULL,
    [CreatedDate]      DATETIME       NULL,
    [TIN]              VARCHAR (9)    NULL,
    [NPI]              VARCHAR (10)   NULL,
    [CMSYear]          INT            NULL,
    [ToAddress]        VARCHAR (1000) NULL,
    CONSTRAINT [PK_tbl_MIPS_Email_History] PRIMARY KEY CLUSTERED ([Id] ASC)
);

