CREATE TABLE [dbo].[tbl_MultipleFileUpload_History_bckp04Dec201713_06_59] (
    [FILE_NAME]              VARCHAR (256) NOT NULL,
    [NPI]                    VARCHAR (50)  NOT NULL,
    [UserID]                 INT           NOT NULL,
    [TIN]                    VARCHAR (50)  NOT NULL,
    [UPLOAD_START_DATE_TIME] DATETIME      NULL,
    [UPLOAD_END_DATE_TIME]   DATETIME      NULL,
    [FacilityID]             VARCHAR (50)  NULL
);

