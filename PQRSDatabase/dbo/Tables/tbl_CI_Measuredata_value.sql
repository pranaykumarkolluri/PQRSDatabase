CREATE TABLE [dbo].[tbl_CI_Measuredata_value] (
    [Id]                          INT             IDENTITY (1, 1) NOT NULL,
    [CategoryId]                  INT             NULL,
    [TIN]                         VARCHAR (9)     NULL,
    [NPI]                         VARCHAR (10)    NULL,
    [KeyId]                       INT             NOT NULL,
    [Measure_Name]                VARCHAR (50)    NOT NULL,
    [isEndToEndReported]          BIT             NULL,
    [performanceMet]              INT             NULL,
    [eligiblePopulationExclusion] INT             NULL,
    [eligiblePopulationException] INT             NULL,
    [eligiblePopulation]          INT             NULL,
    [reportingRate]               DECIMAL (18, 4) NULL,
    [performanceRate]             DECIMAL (18, 4) NULL,
    [numerator]                   DECIMAL (18, 2) NULL,
    [denominator]                 DECIMAL (18, 2) NULL,
    [denominatorException]        DECIMAL (18, 4) NULL,
    [numeratorExclusion]          DECIMAL (18, 4) NULL,
    [valuebit]                    BIT             NULL,
    [Stratum_Name]                VARCHAR (250)   NULL,
    [ObservationInstances]        INT             NULL,
    CONSTRAINT [PK_tbl_CI_measuredata_value_1] PRIMARY KEY CLUSTERED ([Id] ASC)
);

