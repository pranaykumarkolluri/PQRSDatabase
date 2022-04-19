CREATE TABLE [dbo].[tbl_CI_BulkTINNPI_CMSSubmission] (
    [Bulk_ID]       INT           IDENTITY (1, 1) NOT NULL,
    [TIN]           VARCHAR (9)   NULL,
    [NPI]           VARCHAR (10)  NULL,
    [CMSYear]       INT           NULL,
    [Category_ID]   INT           NULL,
    [IsSubmittoCMS] BIT           NULL,
    [Request_ID]    INT           NULL,
    [CMSStatus]     VARCHAR (50)  NULL,
    [Created_By]    VARCHAR (50)  NULL,
    [Created_Date]  DATETIME      NULL,
    [Updated_By]    VARCHAR (50)  NULL,
    [Updated_Date]  DATETIME      NULL,
    [Notes]         VARCHAR (MAX) NULL,
    CONSTRAINT [PK_tbl_CI_BulkTINNPI_CMSSubmission] PRIMARY KEY CLUSTERED ([Bulk_ID] ASC),
    CONSTRAINT [FK_tbl_CI_BulkTINNPI_CMSSubmission_tbl_CI_RequestData] FOREIGN KEY ([Request_ID]) REFERENCES [dbo].[tbl_CI_RequestData] ([Request_Id]),
    CONSTRAINT [FK_tbl_CI_BulkTINNPI_CMSSubmission_tbl_lookup_Categories] FOREIGN KEY ([Category_ID]) REFERENCES [dbo].[tbl_CI_lookup_Categories] ([Category_Id])
);

