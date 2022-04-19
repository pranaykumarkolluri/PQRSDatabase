CREATE TABLE [dbo].[tbl_MeasureRule_History] (
    [HistoryId]   INT           IDENTITY (1, 1) NOT NULL,
    [RuleId]      INT           NULL,
    [ChangedBy]   INT           NULL,
    [ChangedDate] DATETIME      NULL,
    [ChangedInfo] VARCHAR (MAX) NULL,
    [CMSYear]     INT           NULL,
    CONSTRAINT [PK_tbl_MesureRule_History] PRIMARY KEY CLUSTERED ([HistoryId] ASC)
);

