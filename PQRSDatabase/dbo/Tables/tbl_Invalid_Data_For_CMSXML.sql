CREATE TABLE [dbo].[tbl_Invalid_Data_For_CMSXML] (
    [Record_ID]           INT             IDENTITY (1, 1) NOT NULL,
    [NPI]                 VARCHAR (50)    NOT NULL,
    [TIN]                 VARCHAR (10)    NOT NULL,
    [Measure_Number]      VARCHAR (50)    NOT NULL,
    [Reporting_Rate]      DECIMAL (18, 2) NULL,
    [Performance_Rate]    DECIMAL (18, 2) NULL,
    [CMS_Submission_Year] INT             NOT NULL,
    [createdate]          DATETIME        NULL,
    [Sum_Four_Fields]     DECIMAL (18, 4) NULL,
    [eligiblePopulation]  DECIMAL (18, 4) NULL,
    [UserId]              INT             NULL,
    [ReasonforRejection]  VARCHAR (MAX)   NULL,
    CONSTRAINT [PK_tbl_Invalid_Data_For_CMSXML] PRIMARY KEY CLUSTERED ([NPI] ASC, [TIN] ASC, [Measure_Number] ASC, [CMS_Submission_Year] ASC)
);

