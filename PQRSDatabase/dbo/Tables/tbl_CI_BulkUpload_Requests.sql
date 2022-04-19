CREATE TABLE [dbo].[tbl_CI_BulkUpload_Requests] (
    [Id]             INT           IDENTITY (1, 1) NOT NULL,
    [FileGroupId]    INT           NULL,
    [FileId]         INT           NULL,
    [CategoryId]     INT           NULL,
    [Tin]            VARCHAR (9)   NULL,
    [Npi]            VARCHAR (10)  NULL,
    [Request_Id]     INT           NULL,
    [Status]         INT           NULL,
    [StartDate]      DATETIME      NULL,
    [EndDate]        DATETIME      NULL,
    [ErroMessage]    VARCHAR (MAX) NULL,
    [FileLevelReqId] INT           NULL,
    CONSTRAINT [PK_tbl_CI_BulkUpload_Requests] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tbl_CI_BulkUpload_Requests_tbl_CI_BulkFileUpload_History] FOREIGN KEY ([FileId]) REFERENCES [dbo].[tbl_CI_BulkFileUpload_History] ([FileId]),
    CONSTRAINT [FK_tbl_CI_BulkUpload_Requests_tbl_CI_BulkUpload_FilesProceedDetails] FOREIGN KEY ([FileLevelReqId]) REFERENCES [dbo].[tbl_CI_BulkUpload_FilesRequestDetails] ([Id]),
    CONSTRAINT [FK_tbl_CI_BulkUpload_Requests_tbl_CI_RequestData] FOREIGN KEY ([Request_Id]) REFERENCES [dbo].[tbl_CI_RequestData] ([Request_Id]),
    CONSTRAINT [FK_tbl_CI_BulkUpload_Requests_tbl_CI_Shedule_FileGroupRequestDetails] FOREIGN KEY ([FileGroupId]) REFERENCES [dbo].[tbl_CI_BulkUpload_FileGroupRequestDetails] ([FileGroupReqId])
);

