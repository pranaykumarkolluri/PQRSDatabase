CREATE TABLE [dbo].[tbl_CI_SubmissionRequestData] (
    [Submissions_Req_Id] UNIQUEIDENTIFIER NOT NULL,
    [EntityType]         VARCHAR (50)     NULL,
    [totalItems]         INT              NULL,
    [CreatedDate]        DATETIME         NULL,
    [CreatedBy]          VARCHAR (50)     NULL,
    [isActive]           BIT              NULL,
    [SyncingCount]       INT              NULL,
    [IsSyncCompleted]    BIT              NULL,
    [SyncedDate]         DATETIME         NULL,
    CONSTRAINT [PK_tbl_CI_SubmissionRequestData] PRIMARY KEY CLUSTERED ([Submissions_Req_Id] ASC)
);

