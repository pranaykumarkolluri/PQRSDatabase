﻿CREATE TABLE [dbo].[tbl_physician_aggregation_year_bak_ACRData_Dec3ed] (
    [Aggregation_Id]           INT             IDENTITY (1, 1) NOT NULL,
    [CMS_Submission_Year]      INT             NOT NULL,
    [CMS_Submission_Date]      DATETIME        NULL,
    [Physician_NPI]            VARCHAR (50)    NOT NULL,
    [Exam_TIN]                 VARCHAR (10)    NOT NULL,
    [Measure_Num]              VARCHAR (50)    NULL,
    [Strata_num]               INT             NULL,
    [SelectedForCMSSubmission] BIT             NULL,
    [Init_Patient_Population]  INT             NULL,
    [Reporting_Denominator]    INT             NULL,
    [Reporting_Numerator]      INT             NULL,
    [Exclusion]                INT             NOT NULL,
    [Performance_denominator]  INT             NOT NULL,
    [Performance_Numerator]    INT             NULL,
    [Denominator_Exceptions]   INT             NULL,
    [Denominator_Exclusions]   INT             NULL,
    [Performance_Not_Met]      INT             NULL,
    [Performance_Met]          INT             NULL,
    [Reporting_Rate]           DECIMAL (18, 4) NULL,
    [Performance_rate]         DECIMAL (18, 4) NULL,
    [Created_Date]             DATETIME        NOT NULL,
    [Created_By]               INT             NOT NULL,
    [Last_Mod_Date]            DATETIME        NULL,
    [Last_Mod_By]              INT             NULL,
    [Encounter_From_Date]      DATETIME        NULL,
    [Encounter_To_Date]        DATETIME        NULL,
    [Benchmark_met]            NVARCHAR (1)    NULL,
    [GPRO]                     BIT             NULL,
    [Decile_Val]               VARCHAR (50)    NULL,
    [Is_90Days]                BIT             NULL,
    [TotalExamsCount]          INT             NULL,
    [Stratum_Id]               INT             NULL
);
