CREATE TABLE [dbo].[tbl_Import_Exam_Measure_Data] (
    [Import_Exam_MeasureID]     INT           IDENTITY (1, 1) NOT NULL,
    [Import_ExamID]             INT           NULL,
    [Import_Measure_num]        VARCHAR (50)  NULL,
    [Import_CPT_Code]           VARCHAR (50)  NULL,
    [Import_Diagnosis_code]     VARCHAR (50)  NULL,
    [Import_Numerator_code]     VARCHAR (50)  NULL,
    [Error_Codes_Desc]          VARCHAR (MAX) NULL,
    [Correct_Data_Extensions]   INT           NULL,
    [InCorrect_Data_Extensions] INT           NULL,
    [Status]                    INT           NULL,
    [No_of_Errors]              INT           NULL,
    [Error_Codes_JSON]          VARCHAR (MAX) NULL,
    [Warning_Codes_Desc]        VARCHAR (MAX) NULL,
    [No_of_Warnings]            INT           NULL,
    [Exclusion_Codes_Desc]      VARCHAR (MAX) NULL,
    [No_of_Exclusions]          INT           NULL,
    [Exam_Record_Status]        VARCHAR (50)  NULL,
    CONSTRAINT [PK_tbl_Import_Exam_Measure_Data] PRIMARY KEY CLUSTERED ([Import_Exam_MeasureID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20190611-174552]
    ON [dbo].[tbl_Import_Exam_Measure_Data]([Import_ExamID] ASC);

