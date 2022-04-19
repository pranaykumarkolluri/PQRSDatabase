CREATE TABLE [dbo].[Submissions_Sync_Tracking] (
    [SyncId]             INT              NOT NULL,
    [Submissions_Req_Id] UNIQUEIDENTIFIER NULL,
    [SyncStartIndex]     INT              NULL,
    [SyncEndIndex]       INT              NULL,
    [SyncTotalCount]     INT              NULL,
    [SyncRemainingCount] INT              NULL,
    [SyncingCount]       INT              NULL,
    [CreatedDate]        DATETIME         NOT NULL,
    [SyncedDate]         DATETIME         NULL,
    [CreatedBy]          VARCHAR (50)     NULL,
    [SyncStatus]         BIT              NULL,
    CONSTRAINT [PK_Submissions_Sync_Tracking] PRIMARY KEY CLUSTERED ([SyncId] ASC)
);

