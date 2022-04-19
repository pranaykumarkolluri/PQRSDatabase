CREATE TABLE [dbo].[tbl_CI_BulkUpload_FilesRequestDetails] (
    [Id]                     INT          IDENTITY (1, 1) NOT NULL,
    [FileId]                 INT          NULL,
    [NoofSubmissions]        SMALLINT     NULL,
    [NoofSuccessSubmissions] SMALLINT     NULL,
    [NoofFailureSubmissions] SMALLINT     NULL,
    [CreatedBy]              VARCHAR (50) NULL,
    [CreatedDate]            DATETIME     NULL,
    [UpdatedBy]              VARCHAR (50) NULL,
    [UpdatedDate]            DATETIME     NULL,
    [FileGroupId]            INT          NULL,
    [ProcessStatus]          SMALLINT     NULL,
    [IsLatest]               BIT          CONSTRAINT [DF_tbl_CI_BulkUpload_FilesProceedDetails_IsLatest] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tbl_CI_BulkUpload_FilesProceedDetails] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tbl_CI_BulkUpload_FilesProceedDetails_tbl_CI_BulkFileUpload_History] FOREIGN KEY ([FileId]) REFERENCES [dbo].[tbl_CI_BulkFileUpload_History] ([FileId]),
    CONSTRAINT [FK_tbl_CI_BulkUpload_FilesProceedDetails_tbl_CI_Shedule_FileGroupRequestDetails] FOREIGN KEY ([FileGroupId]) REFERENCES [dbo].[tbl_CI_BulkUpload_FileGroupRequestDetails] ([FileGroupReqId])
);

