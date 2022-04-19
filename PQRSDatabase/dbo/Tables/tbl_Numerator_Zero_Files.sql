CREATE TABLE [dbo].[tbl_Numerator_Zero_Files] (
    [ID]                     INT           IDENTITY (1, 1) NOT NULL,
    [FileId]                 INT           NOT NULL,
    [FILE_NAME]              VARCHAR (256) NOT NULL,
    [STATUS]                 VARCHAR (256) NOT NULL,
    [Extension]              VARCHAR (50)  NULL,
    [IsFile_Encrypted]       BIT           NOT NULL,
    [Encryption_Type]        VARCHAR (50)  NULL,
    [Load_Data_STATUS]       VARCHAR (256) NOT NULL,
    [UPLOAD_START_DATE_TIME] DATETIME      NULL,
    [TOTAL_RECORDS_COUNT]    BIGINT        NULL,
    CONSTRAINT [PK_tbl_Numerator_Zero_Files] PRIMARY KEY CLUSTERED ([ID] ASC)
);

