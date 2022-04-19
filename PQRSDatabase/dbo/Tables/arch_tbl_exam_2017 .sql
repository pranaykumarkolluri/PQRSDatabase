﻿CREATE TABLE [dbo].[arch_tbl_exam_2017 ] (
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
    [Exam_Unique_ID]               VARCHAR (50)    NULL,
    [PartnerID]                    VARCHAR (50)    NULL,
    [AppID]                        VARCHAR (50)    NULL,
    [Transaction_ID]               VARCHAR (50)    NULL,
    [DataSource_Id]                INT             NULL,
    [CMS_Submission_Year]          INT             NULL,
    [IsEncrypt]                    BIT             CONSTRAINT [DF__arch_tbl_exam_2017__IsEncr__7E77B618] DEFAULT ((0)) NOT NULL,
    [File_ID]                      INT             NULL,
    [Decrypt_Patient_ID]           VARCHAR (500)   NULL,
    CONSTRAINT [PK_arch_tbl_exam_2017] PRIMARY KEY CLUSTERED ([Exam_Id] ASC)
);
