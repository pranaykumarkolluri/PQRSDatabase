CREATE TABLE [dbo].[tbl_ReportingRateGreaterThan100] (
    [Exam_TIN]                       VARCHAR (10)    NOT NULL,
    [Physician_NPI]                  VARCHAR (50)    NOT NULL,
    [Measure_Num]                    VARCHAR (50)    NULL,
    [Original_Reporting_Denominator] INT             NULL,
    [Original_Reporting_Numerator]   INT             NULL,
    [Original_Reporting_Rate]        DECIMAL (18, 4) NULL,
    [Reporting_Denominator]          INT             NULL,
    [Reporting_Numerator]            INT             NULL,
    [Reporting_Rate]                 DECIMAL (18, 4) NULL
);

