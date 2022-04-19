CREATE TABLE [dbo].[tbl_Lookup_ACI_Data_2019] (
    [ACI_Mes_Id]             INT           IDENTITY (1, 1) NOT NULL,
    [ACI_Id]                 INT           NULL,
    [MeasureId]              VARCHAR (20)  NULL,
    [IsUnique]               BIT           NULL,
    [MeasureName]            VARCHAR (100) NULL,
    [ObjectiveName]          VARCHAR (100) NULL,
    [MeasureDescription]     VARCHAR (MAX) NULL,
    [PerformanceScoreWeight] VARCHAR (20)  NULL,
    [ReportType]             VARCHAR (100) NULL,
    [RequiredforBaseScore]   BIT           NULL,
    [CMSYear]                INT           NULL
);

