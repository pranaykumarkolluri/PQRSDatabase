CREATE TABLE [dbo].[tbl_Lookup_ACI_Data] (
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
    [CMSYear]                INT           NULL,
    [Display_order]          INT           NULL,
    CONSTRAINT [PK_Tbl_Lookup_ACI_Data] PRIMARY KEY CLUSTERED ([ACI_Mes_Id] ASC),
    CONSTRAINT [FK_tbl_Lookup_ACI_Data_tbl_Lookup_ACI] FOREIGN KEY ([ACI_Id]) REFERENCES [dbo].[tbl_Lookup_ACI] ([ACI_Id])
);

