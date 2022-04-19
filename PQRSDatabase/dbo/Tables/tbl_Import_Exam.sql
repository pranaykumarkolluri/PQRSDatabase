CREATE TABLE [dbo].[tbl_Import_Exam] (
    [Import_examID]                             INT           IDENTITY (1, 1) NOT NULL,
    [Import_ExamsID]                            INT           NULL,
    [Import_Physician_Group_TIN]                VARCHAR (50)  NULL,
    [Import_Exam_Unique_ID]                     VARCHAR (500) NULL,
    [Import_Exam_DateTime]                      VARCHAR (50)  NULL,
    [Import_Physician_NPI]                      VARCHAR (50)  NULL,
    [Import_First_Name]                         VARCHAR (50)  NULL,
    [Import_Last_Name]                          VARCHAR (50)  NULL,
    [Import_Patient_ID]                         VARCHAR (500) NULL,
    [Import_Patient_Age]                        VARCHAR (50)  NULL,
    [Import_Patient_Gender]                     VARCHAR (50)  NULL,
    [Import_Patient_Medicare_Beneficiary]       VARCHAR (50)  NULL,
    [Import_Patient_Medicare_Advantage]         VARCHAR (50)  NULL,
    [Import_Num_of_Measures_Included]           VARCHAR (50)  NULL,
    [Error_Codes_Desc]                          VARCHAR (MAX) NULL,
    [Correct_Measure_DataCount]                 INT           NULL,
    [Incorrect_Measure_DataCount]               INT           NULL,
    [Status]                                    INT           NULL,
    [No_of_Errors]                              INT           NULL,
    [Error_Codes_JSON]                          VARCHAR (MAX) NULL,
    [isEncrypt]                                 BIT           CONSTRAINT [DF__tbl_Impor__isEnc__7D8391DF] DEFAULT ((0)) NOT NULL,
    [Correct_Measure_DataWith_WarningCount]     INT           NULL,
    [InCorrect_Measure_DataWith_ExclusionCount] INT           NULL,
    [Decrypt_Patient_ID]                        VARCHAR (500) NULL,
    CONSTRAINT [PK_tbl_Import_Exam] PRIMARY KEY CLUSTERED ([Import_examID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20190612-183723]
    ON [dbo].[tbl_Import_Exam]([Status] ASC);


GO
CREATE NONCLUSTERED INDEX [tbl_import_exam_examsID_idx]
    ON [dbo].[tbl_Import_Exam]([Import_ExamsID] ASC);

