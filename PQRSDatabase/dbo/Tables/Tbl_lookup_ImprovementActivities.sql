CREATE TABLE [dbo].[Tbl_lookup_ImprovementActivities] (
    [Id]          SMALLINT      IDENTITY (1, 1) NOT NULL,
    [Description] VARCHAR (MAX) NULL,
    [IACode]      VARCHAR (20)  NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

