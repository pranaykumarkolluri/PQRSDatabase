CREATE TABLE [dbo].[TBL_SELECT_LOOKUP_IA_MEASURES_BACKEND] (
    [Id]               INT            IDENTITY (1, 1) NOT NULL,
    [SelectedActivity] VARCHAR (5000) NULL,
    [StartDate]        DATETIME       NULL,
    [EndDate]          DATETIME       NULL,
    [UpdatedBy]        VARCHAR (50)   NULL,
    [UpdatedDateTime]  DATETIME       NULL,
    CONSTRAINT [PK_TBL_SELECT_IA_MEASURES_BACKEND] PRIMARY KEY CLUSTERED ([Id] ASC)
);

