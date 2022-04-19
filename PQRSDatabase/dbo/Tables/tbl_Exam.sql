CREATE TABLE [dbo].[tbl_Exam] (
    [Exam_Id]                      INT             IDENTITY (1, 1) NOT NULL,
    [Physician_NPI]                VARCHAR (50)    NULL,
    [Exam_TIN]                     VARCHAR (10)    NULL,
    [Patient_ID]                   VARCHAR (500)   NULL,
    [Patient_Age]                  DECIMAL (18, 2) NULL,
    [Patient_Gender]               VARCHAR (50)    NULL,
    [Patient_Medicare_Beneficiary] SMALLINT        NULL,
    [Patient_Medicare_Advantage]   SMALLINT        NULL,
    [Exam_Date]                    DATETIME        NULL,
    [Created_Date]                 DATETIME        NULL,
    [Created_By]                   VARCHAR (50)    NULL,
    [Last_Modified_Date]           DATETIME        NULL,
    [Last_Modified_By]             VARCHAR (50)    NULL,
    [Facility_ID]                  VARCHAR (50)    NULL,
    [Exam_Unique_ID]               VARCHAR (500)   NULL,
    [PartnerID]                    VARCHAR (50)    NULL,
    [AppID]                        VARCHAR (50)    NULL,
    [Transaction_ID]               VARCHAR (50)    NULL,
    [DataSource_Id]                INT             NULL,
    [CMS_Submission_Year]          INT             NULL,
    [IsEncrypt]                    BIT             CONSTRAINT [DF__tbl_Exam__IsEncr__7E77B618] DEFAULT ((0)) NOT NULL,
    [File_ID]                      INT             NULL,
    CONSTRAINT [PK_tbl_Exam] PRIMARY KEY CLUSTERED ([Exam_Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [idx_Exam_Id_Exam_TIN_Exam_Date_Patient_ID]
    ON [dbo].[tbl_Exam]([Exam_Id] ASC, [Exam_TIN] ASC, [Exam_Date] ASC, [Patient_ID] ASC)
    INCLUDE([Physician_NPI]);


GO
CREATE NONCLUSTERED INDEX [Idx_Exam_TIN_Date_Physician_NPI]
    ON [dbo].[tbl_Exam]([Physician_NPI] ASC, [Exam_TIN] ASC, [Exam_Date] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_CMS_Submission_Year_Exam_TIN_Last_M_Date]
    ON [dbo].[tbl_Exam]([Exam_TIN] ASC, [Physician_NPI] ASC, [CMS_Submission_Year] ASC);


GO
CREATE NONCLUSTERED INDEX [Idx_tbl_exam_transID_PartnerID_AppID]
    ON [dbo].[tbl_Exam]([PartnerID] ASC, [AppID] ASC, [Transaction_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [tbl_exam_patient_Idx]
    ON [dbo].[tbl_Exam]([Patient_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20191023-160527]
    ON [dbo].[tbl_Exam]([Physician_NPI] ASC, [CMS_Submission_Year] ASC);

