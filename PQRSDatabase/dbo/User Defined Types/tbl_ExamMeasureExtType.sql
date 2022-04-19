CREATE TYPE [dbo].[tbl_ExamMeasureExtType] AS TABLE (
    [Exam_MeasureExt_UniqueId] UNIQUEIDENTIFIER NOT NULL,
    [Other_Question_num]       VARCHAR (50)     NULL,
    [Response_Value]           VARCHAR (50)     NULL,
    [Created_by]               VARCHAR (50)     NULL,
    [Created_Date]             VARCHAR (50)     NULL,
    [Last_Modified_Date]       VARCHAR (50)     NULL,
    [Last_Modified_By]         VARCHAR (50)     NULL,
    PRIMARY KEY CLUSTERED ([Exam_MeasureExt_UniqueId] ASC));

