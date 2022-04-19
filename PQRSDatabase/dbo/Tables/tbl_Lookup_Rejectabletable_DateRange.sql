CREATE TABLE [dbo].[tbl_Lookup_Rejectabletable_DateRange] (
    [Rejectabletable_Age_ID]     INT          IDENTITY (1, 1) NOT NULL,
    [Measure_ID]                 INT          NULL,
    [Measure_Num]                VARCHAR (50) NULL,
    [CMSYear]                    INT          NOT NULL,
    [Rejectabletable_date_start] DATETIME     NULL,
    [Rejectabletable_date_end]   DATETIME     NULL,
    CONSTRAINT [PK_tbl_Lookup_Rejectabletable_Age] PRIMARY KEY CLUSTERED ([Rejectabletable_Age_ID] ASC),
    CONSTRAINT [FK_tbl_Lookup_Rejectabletable_Age_tbl_Lookup_Measure] FOREIGN KEY ([Measure_ID]) REFERENCES [dbo].[tbl_Lookup_Measure] ([Measure_ID])
);

