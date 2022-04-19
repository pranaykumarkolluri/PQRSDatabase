CREATE TABLE [dbo].[tbl_Tin_Invalid_Data_For_ACIXML] (
    [Record_ID]           INT          IDENTITY (1, 1) NOT NULL,
    [TIN]                 VARCHAR (10) NOT NULL,
    [MeasureId]           VARCHAR (50) NOT NULL,
    [CMS_Submission_Year] INT          NOT NULL,
    [createdate]          DATETIME     NULL,
    CONSTRAINT [PK_tbl_Tin_Invalid_Data_For_ACIXML] PRIMARY KEY CLUSTERED ([TIN] ASC, [MeasureId] ASC, [CMS_Submission_Year] ASC)
);

