CREATE TABLE [dbo].[tbl_ApiRequstedFilesList] (
    [Id]                    INT      IDENTITY (1, 1) NOT NULL,
    [ReqId]                 INT      NULL,
    [FileId]                INT      NOT NULL,
    [ProcessedRecords]      INT      NULL,
    [CountUpdateOn]         DATETIME NULL,
    [Status_CnstID]         INT      NULL,
    [isValidationState]     BIT      NULL,
    [Validation_StartDate]  DATETIME NULL,
    [Validation_UpdateDate] DATETIME NULL,
    CONSTRAINT [PK_tbl_ApiRequstedFilesList] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tbl_ApiRequstedFilesList_tbl_ApiRequestFileProcessHistory] FOREIGN KEY ([ReqId]) REFERENCES [dbo].[tbl_ApiRequestFileProcessHistory] ([ReqId]),
    CONSTRAINT [FK_tbl_ApiRequstedFilesList_tbl_PQRS_FILE_UPLOAD_HISTORY] FOREIGN KEY ([FileId]) REFERENCES [dbo].[tbl_PQRS_FILE_UPLOAD_HISTORY] ([ID])
);

