CREATE TABLE [dbo].[tbl_CI_BulkFileUploadCmsDataforIA] (
    [CmsDataId]             INT           IDENTITY (1, 1) NOT NULL,
    [FileId]                INT           NULL,
    [TIN]                   VARCHAR (9)   NULL,
    [Npi]                   VARCHAR (10)  NULL,
    [CmsYear]               INT           NULL,
    [Improvement_Activitiy] VARCHAR (100) NULL,
    [Attestation]           BIT           NULL,
    [Createdby]             VARCHAR (50)  NULL,
    [CreatedDate]           DATETIME      NULL,
    [First_Encounter_Date]  DATETIME      NULL,
    [Last_Encounter_Date]   DATETIME      NULL,
    [IsValidata]            BIT           NULL,
    [ErrorMessage]          VARCHAR (MAX) NULL,
    CONSTRAINT [PK__tbl_CI_B__C08907F80592D997] PRIMARY KEY CLUSTERED ([CmsDataId] ASC),
    CONSTRAINT [FK_tbl_CI_BulkFileUploadCmsDataforIA_tbl_CI_BulkFileUpload_History] FOREIGN KEY ([FileId]) REFERENCES [dbo].[tbl_CI_BulkFileUpload_History] ([FileId]) ON DELETE CASCADE
);

