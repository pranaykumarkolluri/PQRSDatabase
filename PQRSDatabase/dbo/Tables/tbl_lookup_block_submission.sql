CREATE TABLE [dbo].[tbl_lookup_block_submission] (
    [BlockId]                INT         IDENTITY (1, 1) NOT NULL,
    [CMSYear]                INT         NOT NULL,
    [TIN]                    VARCHAR (9) NOT NULL,
    [Is_Blocked]             BIT         NULL,
    [Created_datetime]       DATETIME    NULL,
    [Last_Modified_datetime] DATETIME    NULL,
    [CategoryId]             INT         NULL,
    [ChangedBy]              INT         NULL,
    CONSTRAINT [PK_tbl_lookup_block_submission] PRIMARY KEY CLUSTERED ([BlockId] ASC)
);

