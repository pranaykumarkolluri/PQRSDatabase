CREATE TABLE [dbo].[Tbl_Hitrust_EventLogs] (
    [Id]          INT           IDENTITY (1, 1) NOT NULL,
    [EventData]   VARCHAR (MAX) NULL,
    [CreatedDate] DATETIME      NULL,
    [CreatedBy]   INT           NULL,
    CONSTRAINT [PK_Tbl_Hitrust_EventLogs] PRIMARY KEY CLUSTERED ([Id] ASC)
);

