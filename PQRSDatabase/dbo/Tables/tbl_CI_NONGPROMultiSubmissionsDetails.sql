CREATE TABLE [dbo].[tbl_CI_NONGPROMultiSubmissionsDetails] (
    [Id]          INT           IDENTITY (1, 1) NOT NULL,
    [ReqId]       INT           NULL,
    [NPI]         VARCHAR (10)  NULL,
    [Status]      VARCHAR (20)  NULL,
    [Message]     VARCHAR (MAX) NULL,
    [CreatedDate] DATETIME      NULL,
    [UpdatedDate] DATETIME      NULL,
    CONSTRAINT [PK_tbl_CI_NONGPROMultiSubmissionsDetails] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tbl_CI_NONGPROMultiSubmissionsDetails_tbl_CI_NONGPROMultiSubmissionsRequestHistory] FOREIGN KEY ([ReqId]) REFERENCES [dbo].[tbl_CI_NONGPROMultiSubmissionsRequestHistory] ([ReqId])
);

