CREATE TABLE [dbo].[tbl_CI_LookUpTablesUpdateHistory] (
    [FileId]              INT            IDENTITY (1, 1) NOT NULL,
    [FileName]            VARCHAR (5000) NULL,
    [CategoryName]        INT            NULL,
    [ValidExcelRecords]   INT            NULL,
    [InvalidExcelRecords] INT            NULL,
    [TotalExcelRecords]   INT            NULL,
    [CreatedDate]         DATETIME       NULL,
    [CreatedBy]           INT            NOT NULL,
    [CmsYear]             INT            NULL,
    [Status]              INT            NULL,
    CONSTRAINT [PK_tbl_CI_LookUpTablesUpdateHistory] PRIMARY KEY CLUSTERED ([FileId] ASC)
);

