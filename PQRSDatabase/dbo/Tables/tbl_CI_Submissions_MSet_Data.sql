CREATE TABLE [dbo].[tbl_CI_Submissions_MSet_Data] (
    [CI_Mset_Id]          UNIQUEIDENTIFIER NOT NULL,
    [SubmissionUniqueKey] VARCHAR (50)     NULL,
    [MSet_UniqueKey_Id]   VARCHAR (50)     NULL,
    [Category]            VARCHAR (10)     NULL,
    [PerformanceStart]    VARCHAR (50)     NULL,
    [PerformanceEnd]      VARCHAR (50)     NULL,
    [Measure_Id]          VARCHAR (50)     NULL,
    [Measure_Name]        VARCHAR (50)     NULL,
    [value]               VARCHAR (MAX)    NULL,
    [CreatedDate]         DATETIME         NULL,
    [CreatedBy]           VARCHAR (50)     NULL,
    [ErrorMeassage]       VARCHAR (500)    NULL,
    CONSTRAINT [PK_tbl_CI_Submissions_MSet_Data] PRIMARY KEY CLUSTERED ([CI_Mset_Id] ASC)
);

