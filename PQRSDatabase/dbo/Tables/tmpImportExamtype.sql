CREATE TABLE [dbo].[tmpImportExamtype] (
    [Import_ExamId]                       VARCHAR (500) NULL,
    [Import_Exam_DateTime]                VARCHAR (50)  NULL,
    [Import_Exam_Unique_ID]               VARCHAR (500) NULL,
    [Import_First_Name]                   VARCHAR (50)  NULL,
    [Import_Last_Name]                    VARCHAR (50)  NULL,
    [Import_Physician_NPI]                VARCHAR (50)  NULL,
    [Import_Physician_Group_TIN]          VARCHAR (50)  NULL,
    [Import_Num_of_Measures_Included]     VARCHAR (50)  NULL,
    [Import_Patient_Age]                  VARCHAR (50)  NULL,
    [Import_Patient_Gender]               VARCHAR (50)  NULL,
    [Import_Patient_ID]                   VARCHAR (500) NULL,
    [isEncrypt]                           BIT           NULL,
    [Import_Patient_Medicare_Beneficiary] VARCHAR (50)  NULL,
    [Import_Patient_Medicare_Advantage]   VARCHAR (50)  NULL
);

