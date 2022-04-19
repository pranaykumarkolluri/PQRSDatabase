CREATE TABLE [dbo].[tbl_Non_PQRS_TIN_Aggregation_Year_bkp_feb_17_2020] (
    [Aggregation_Id]           INT             IDENTITY (1, 1) NOT NULL,
    [CMS_Submission_Year]      INT             NOT NULL,
    [Exam_TIN]                 VARCHAR (10)    NOT NULL,
    [Total_Num_Exam_Submitted] INT             NULL,
    [Encounter_From_Date]      DATETIME        NULL,
    [Encounter_To_Date]        DATETIME        NULL,
    [Measure_Num]              VARCHAR (50)    NULL,
    [Strata_num]               INT             NULL,
    [Reporting_Numerator]      INT             NULL,
    [Performance_denominator]  INT             NOT NULL,
    [Performance_Numerator]    DECIMAL (18, 2) NULL,
    [Denominator_Exceptions]   INT             NULL,
    [Denominator_Exclusions]   INT             NULL,
    [Performance_Not_Met]      INT             NOT NULL,
    [Performance_Met]          INT             NOT NULL,
    [Performance_rate]         DECIMAL (18, 4) NULL,
    [Updated_date]             DATETIME        NULL,
    [Benchmark_met]            NVARCHAR (1)    NULL,
    [GPRO]                     BIT             NOT NULL,
    [Is_90Days]                BIT             NULL,
    [Decile_val]               NVARCHAR (50)   NULL
);

