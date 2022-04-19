CREATE TABLE [dbo].[tbl_Measure_Mean_Performance_Rate] (
    [Id]               INT          IDENTITY (1, 1) NOT NULL,
    [CMS_Year]         INT          NOT NULL,
    [Measure_No]       VARCHAR (50) NOT NULL,
    [Performance_Rate] INT          NULL,
    CONSTRAINT [PK_Measure_Mean] PRIMARY KEY CLUSTERED ([Id] ASC)
);

