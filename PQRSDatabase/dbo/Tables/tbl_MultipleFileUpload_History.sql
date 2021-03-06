CREATE TABLE [dbo].[tbl_MultipleFileUpload_History] (
    [FILE_NAME]              VARCHAR (256) NOT NULL,
    [NPI]                    VARCHAR (50)  NOT NULL,
    [UserID]                 INT           NOT NULL,
    [TIN]                    VARCHAR (50)  NOT NULL,
    [UPLOAD_START_DATE_TIME] DATETIME      NULL,
    [UPLOAD_END_DATE_TIME]   DATETIME      NULL,
    [FacilityID]             VARCHAR (50)  NULL,
    [FileId]                 INT           NULL,
    CONSTRAINT [PK_tbl_FacilityAdmin_FileUpload_History] PRIMARY KEY CLUSTERED ([FILE_NAME] ASC, [NPI] ASC, [UserID] ASC, [TIN] ASC)
);

