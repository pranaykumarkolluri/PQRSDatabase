CREATE TABLE [dbo].[tbl_PendingFilesAPI] (
    [FileID]       INT              NOT NULL,
    [GUI]          UNIQUEIDENTIFIER NULL,
    [Created_Date] DATETIME         NULL,
    CONSTRAINT [PK_tbl_PendingFilesAPI] PRIMARY KEY CLUSTERED ([FileID] ASC)
);

