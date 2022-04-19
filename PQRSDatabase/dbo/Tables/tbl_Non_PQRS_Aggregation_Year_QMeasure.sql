CREATE TABLE [dbo].[tbl_Non_PQRS_Aggregation_Year_QMeasure] (
    [Aggregation_Id]           INT             IDENTITY (1, 1) NOT NULL,
    [CMS_Submission_Year]      INT             NOT NULL,
    [Physician_NPI]            VARCHAR (50)    NOT NULL,
    [Exam_TIN]                 VARCHAR (10)    NULL,
    [Total_Num_Exam_Submitted] INT             NULL,
    [Encounter_From_Date]      DATETIME        NULL,
    [Encounter_To_Date]        DATETIME        NULL,
    [Measure_Num]              VARCHAR (50)    NULL,
    [Strata_num]               INT             NULL,
    [Reporting_Numerator]      INT             NULL,
    [Performance_denominator]  INT             NOT NULL,
    [Performance_Numerator]    INT             NULL,
    [Denominator_Exceptions]   INT             NULL,
    [Denominator_Exclusions]   INT             NULL,
    [Performance_Not_Met]      INT             NOT NULL,
    [Performance_Met]          INT             NOT NULL,
    [Performance_rate]         DECIMAL (18, 2) NULL,
    [Updated_date]             DATETIME        NULL,
    [Benchmark_met]            VARCHAR (1)     NULL,
    [Is_90Days]                BIT             NULL,
    [Decile_Val]               VARCHAR (50)    NULL
);

