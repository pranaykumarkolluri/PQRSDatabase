CREATE TABLE [dbo].[tbl_CI_BulkFileUpload_History] (
    [FileId]                       INT           IDENTITY (1, 1) NOT NULL,
    [FileName]                     VARCHAR (100) NULL,
    [IsGpro]                       BIT           NOT NULL,
    [CategoryId]                   INT           NOT NULL,
    [TotalEditedExcelRecordsCount] INT           NULL,
    [ValidExcelRecords]            INT           NULL,
    [InvalidExcelRecords]          INT           NULL,
    [TotalExcelRecords]            INT           NULL,
    [CreatedDate]                  DATETIME      NULL,
    [CreatedBy]                    INT           NOT NULL,
    [CmsYear]                      INT           NULL,
    [ErrorMessage]                 VARCHAR (MAX) NULL,
    [CompleteDate]                 DATETIME      NULL,
    [Status]                       INT           NULL,
    [IsPartiallyValidation]        BIT           CONSTRAINT [DF_tbl_CI_BulkFileUpload_History_IsPartiallyValidation] DEFAULT ((0)) NOT NULL,
    [IsPartiallyPosted]            BIT           CONSTRAINT [DF_tbl_CI_BulkFileUpload_History_IsPartiallyPosted] DEFAULT ((0)) NOT NULL,
    [IsPartallyCMSSumitted]        BIT           CONSTRAINT [DF_tbl_CI_BulkFileUpload_History_IsPartallyCMSSumitted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tbl_CI_BulkFileUpload_History] PRIMARY KEY CLUSTERED ([FileId] ASC)
);

