CREATE TABLE [dbo].[tbl_OptInFetch_History] (
    [FetchID]      INT      IDENTITY (1, 1) NOT NULL,
    [Created_Date] DATETIME NULL,
    CONSTRAINT [PK_tbl_OptInFetch_History] PRIMARY KEY CLUSTERED ([FetchID] ASC)
);

