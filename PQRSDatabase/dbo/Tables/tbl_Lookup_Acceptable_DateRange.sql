CREATE TABLE [dbo].[tbl_Lookup_Acceptable_DateRange] (
    [Acceptable_Age_ID]     INT          IDENTITY (1, 1) NOT NULL,
    [Measure_ID]            INT          NULL,
    [Measure_Num]           VARCHAR (50) NULL,
    [CMSYear]               INT          NOT NULL,
    [acceptable_date_start] DATETIME     NULL,
    [acceptable_date_end]   DATETIME     NULL,
    CONSTRAINT [PK_tbl_Lookup_Acceptable_Age] PRIMARY KEY CLUSTERED ([Acceptable_Age_ID] ASC),
    CONSTRAINT [FK_tbl_Lookup_Acceptable_Age_tbl_Lookup_Measure] FOREIGN KEY ([Measure_ID]) REFERENCES [dbo].[tbl_Lookup_Measure] ([Measure_ID])
);

