CREATE TABLE [dbo].[Tbl_Backend_TINNPI_IAMeasures] (
    [Id]      INT            IDENTITY (1, 1) NOT NULL,
    [Measure] VARCHAR (5000) NULL,
    [CMSYear] INT            NULL,
    CONSTRAINT [PK_Tbl_Backend_TINNPI_IAMeasures] PRIMARY KEY CLUSTERED ([Id] ASC)
);

