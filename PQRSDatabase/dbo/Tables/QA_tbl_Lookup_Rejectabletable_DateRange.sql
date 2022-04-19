CREATE TABLE [dbo].[QA_tbl_Lookup_Rejectabletable_DateRange] (
    [Rejectabletable_Age_ID]     INT          IDENTITY (1, 1) NOT NULL,
    [Measure_ID]                 INT          NULL,
    [Measure_Num]                VARCHAR (50) NULL,
    [CMSYear]                    INT          NOT NULL,
    [Rejectabletable_date_start] DATETIME     NULL,
    [Rejectabletable_date_end]   DATETIME     NULL
);

