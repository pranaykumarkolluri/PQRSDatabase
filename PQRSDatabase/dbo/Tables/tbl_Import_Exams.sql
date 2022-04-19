CREATE TABLE [dbo].[tbl_Import_Exams] (
    [ExamsID]                           INT           IDENTITY (1, 1) NOT NULL,
    [Transaction_ID]                    VARCHAR (50)  NULL,
    [Transaction_DateTime]              VARCHAR (50)  NULL,
    [Num_of_exams_Included]             VARCHAR (50)  NULL,
    [PartnerId]                         VARCHAR (50)  NULL,
    [Appid]                             VARCHAR (50)  NULL,
    [Facility_Id]                       VARCHAR (50)  NULL,
    [Prev_Transction_ID]                VARCHAR (50)  NULL,
    [RawData_Id]                        VARCHAR (50)  NULL,
    [Import_Status]                     INT           NULL,
    [Error_Codes_Desc]                  VARCHAR (MAX) NULL,
    [Correct_ExamCount]                 INT           NULL,
    [InCorrect_ExamCount]               INT           NULL,
    [No_of_Errors]                      INT           NULL,
    [Error_Codes_JSON]                  VARCHAR (MAX) NULL,
    [Correct_ExamWith_WarningCount]     INT           NULL,
    [InCorrect_ExamWith_ExclusionCount] INT           NULL,
    CONSTRAINT [PK_tbl_Import_Exams] PRIMARY KEY CLUSTERED ([ExamsID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [tbl_Import_Exams_RawData_ID_IDX]
    ON [dbo].[tbl_Import_Exams]([RawData_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [Idx_tbl_import_exams_tranID_appID_PartnerID_examID]
    ON [dbo].[tbl_Import_Exams]([ExamsID] ASC, [Transaction_ID] ASC, [PartnerId] ASC, [Appid] ASC);

