CREATE TYPE [dbo].[tbl_ExamMeasureType] AS TABLE (
    [Exam_Measure_UniqueId]    UNIQUEIDENTIFIER NOT NULL,
    [Denominator_proc_code]    VARCHAR (50)     NULL,
    [Denominator_Diag_code]    VARCHAR (50)     NULL,
    [Numerator_response_value] VARCHAR (50)     NULL,
    [Status]                   VARCHAR (50)     NULL,
    [Created_Date]             VARCHAR (50)     NULL,
    [Created_By]               VARCHAR (50)     NULL,
    [Last_Mod_Date]            VARCHAR (50)     NULL,
    [Last_Mod_By]              VARCHAR (50)     NULL,
    [CMS_Submission_Year]      INT              NULL,
    [Aggregation_Id]           VARCHAR (50)     NULL,
    [Criteria]                 VARCHAR (20)     NULL,
    [Numerator_Code]           VARCHAR (100)    NULL,
    PRIMARY KEY CLUSTERED ([Exam_Measure_UniqueId] ASC));

