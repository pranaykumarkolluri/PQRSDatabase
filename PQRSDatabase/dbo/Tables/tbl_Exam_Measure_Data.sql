CREATE TABLE [dbo].[tbl_Exam_Measure_Data] (
    [Exam_Measure_Id]          INT           IDENTITY (1, 1) NOT NULL,
    [Exam_Id]                  INT           NULL,
    [Measure_ID]               INT           NOT NULL,
    [Denominator]              SMALLINT      NULL,
    [Denominator_proc_code]    VARCHAR (50)  NULL,
    [Denominator_Diag_code]    VARCHAR (50)  NULL,
    [Numerator_response_value] SMALLINT      NULL,
    [Status]                   INT           NULL,
    [CMS_Submission_Status]    VARCHAR (50)  NULL,
    [Created_Date]             DATETIME      NULL,
    [Created_By]               VARCHAR (50)  NULL,
    [Last_Mod_Date]            DATETIME      NULL,
    [Last_Mod_By]              VARCHAR (50)  NULL,
    [CMS_Submission_Date]      DATETIME      NULL,
    [CMS_Submission_Year]      INT           NULL,
    [Aggregation_Id]           INT           NULL,
    [Criteria]                 VARCHAR (20)  NULL,
    [Numerator_Code]           VARCHAR (100) NULL,
    CONSTRAINT [PK_tbl_Exam_Measure_Data] PRIMARY KEY CLUSTERED ([Exam_Measure_Id] ASC),
    CONSTRAINT [FK_tbl_Exam_Measure_Data_tbl_Exam] FOREIGN KEY ([Exam_Id]) REFERENCES [dbo].[tbl_Exam] ([Exam_Id]),
    CONSTRAINT [FK_tbl_Exam_Measure_Data_tbl_Lookup_Measure] FOREIGN KEY ([Measure_ID]) REFERENCES [dbo].[tbl_Lookup_Measure] ([Measure_ID]),
    CONSTRAINT [FK_tbl_Exam_Measure_Data_tbl_Status] FOREIGN KEY ([Status]) REFERENCES [dbo].[tbl_Lookup_Measure_Status] ([Status_ID])
);


GO
CREATE NONCLUSTERED INDEX [Idx_tbl_exam_Measure_data_Exam_id]
    ON [dbo].[tbl_Exam_Measure_Data]([Exam_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20190614-132829]
    ON [dbo].[tbl_Exam_Measure_Data]([Denominator_proc_code] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20190614-131932]
    ON [dbo].[tbl_Exam_Measure_Data]([Exam_Id] ASC, [CMS_Submission_Year] ASC, [Denominator_proc_code] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_tbl_Exam_Measure_Data_Status]
    ON [dbo].[tbl_Exam_Measure_Data]([Status] ASC, [Exam_Measure_Id] ASC, [Exam_Id] ASC, [Measure_ID] ASC, [Numerator_response_value] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-Raju]
    ON [dbo].[tbl_Exam_Measure_Data]([Measure_ID] ASC, [Status] ASC, [Exam_Id] ASC, [Denominator_proc_code] ASC, [Criteria] ASC, [Numerator_Code] ASC);

