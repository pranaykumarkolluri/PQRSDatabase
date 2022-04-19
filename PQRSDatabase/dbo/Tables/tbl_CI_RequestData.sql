CREATE TABLE [dbo].[tbl_CI_RequestData] (
    [Request_Id]      INT           IDENTITY (1, 1) NOT NULL,
    [Category_Id]     INT           NULL,
    [Request_Data]    VARCHAR (MAX) NULL,
    [Tin]             VARCHAR (9)   NULL,
    [Npi]             VARCHAR (10)  NULL,
    [CmsYear]         INT           NULL,
    [CreatedDate]     DATETIME      NOT NULL,
    [CreatedBy]       VARCHAR (50)  NULL,
    [IsScoreRequired] BIT           NULL,
    CONSTRAINT [PK_tbl_CI_RequestData] PRIMARY KEY CLUSTERED ([Request_Id] ASC),
    CONSTRAINT [FK_tbl_CI_RequestData_tbl_lookup_Categories] FOREIGN KEY ([Category_Id]) REFERENCES [dbo].[tbl_CI_lookup_Categories] ([Category_Id])
);

