CREATE TYPE [dbo].[tbl_CI_Submissions_MSet_Data_Type] AS TABLE (
    [SubmissionUniqueKey] VARCHAR (50)  NULL,
    [MSet_UniqueKey_Id]   VARCHAR (50)  NULL,
    [Category]            VARCHAR (10)  NULL,
    [PerformanceStart]    VARCHAR (50)  NULL,
    [PerformanceEnd]      VARCHAR (50)  NULL,
    [Measure_Id]          VARCHAR (50)  NULL,
    [Measure_Name]        VARCHAR (50)  NULL,
    [value]               VARCHAR (MAX) NULL,
    [CreatedDate]         DATETIME      NULL,
    [CreatedBy]           VARCHAR (50)  NULL);

