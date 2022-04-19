﻿CREATE TABLE [dbo].[tbl_Physician_Aggregation_For_226] (
    [Agg_Id]                      INT           IDENTITY (1, 1) NOT NULL,
    [Physician_NPI]               VARCHAR (50)  NULL,
    [Exam_TIN]                    VARCHAR (10)  NULL,
    [Patient_ID]                  VARCHAR (500) NULL,
    [Exam_Date]                   DATETIME      NULL,
    [CMS_Submission_Year]         INT           NULL,
    [Measure_ID]                  INT           NULL,
    [Measure_Num]                 VARCHAR (50)  NULL,
    [Denominator_proc_code]       VARCHAR (50)  NULL,
    [Numerator_Code]              VARCHAR (100) NULL,
    [Created_Date]                DATETIME      NULL,
    [Created_By]                  VARCHAR (50)  NULL,
    [Criteria]                    VARCHAR (20)  NULL,
    [CPT_Code_Validation]         BIT           NULL,
    [CPT_Code_Validation_Message] VARCHAR (MAX) NULL,
    [Is_Most_Recent_Exam]         BIT           NULL,
    [Criteria_Validation]         BIT           NULL,
    [Criteria_Validation_Message] VARCHAR (MAX) NULL,
    [Performance_Met]             BIT           NULL,
    [Performance_NotMet]          BIT           NULL,
    [Denominator_Exception]       BIT           NULL,
    [Is_TobaccoUser]              BIT           NULL,
    [Is_EligiblePopulation]       BIT           NULL,
    CONSTRAINT [PK_tbl_Physician_Aggregation_For_226] PRIMARY KEY CLUSTERED ([Agg_Id] ASC)
);

