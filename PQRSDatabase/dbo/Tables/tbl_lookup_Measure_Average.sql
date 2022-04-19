CREATE TABLE [dbo].[tbl_lookup_Measure_Average] (
    [ID]              INT            IDENTITY (1, 1) NOT NULL,
    [Measure_Id]      INT            NOT NULL,
    [Avg_MeasureName] VARCHAR (50)   NOT NULL,
    [Measure_Title]   VARCHAR (500)  NULL,
    [Measure_Desc]    VARCHAR (1000) NOT NULL,
    CONSTRAINT [PK_tbl_lookup_Measure_Average] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_tbl_lookup_Measure_Average_tbl_Lookup_Measure] FOREIGN KEY ([Measure_Id]) REFERENCES [dbo].[tbl_Lookup_Measure] ([Measure_ID])
);

