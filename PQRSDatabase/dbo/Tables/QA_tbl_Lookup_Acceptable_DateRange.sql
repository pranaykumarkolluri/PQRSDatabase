CREATE TABLE [dbo].[QA_tbl_Lookup_Acceptable_DateRange] (
    [Acceptable_Age_ID]     INT          IDENTITY (1, 1) NOT NULL,
    [Measure_ID]            INT          NULL,
    [Measure_Num]           VARCHAR (50) NULL,
    [CMSYear]               INT          NOT NULL,
    [acceptable_date_start] DATETIME     NULL,
    [acceptable_date_end]   DATETIME     NULL
);

