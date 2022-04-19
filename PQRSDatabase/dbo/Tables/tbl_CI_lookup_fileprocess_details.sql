CREATE TABLE [dbo].[tbl_CI_lookup_fileprocess_details] (
    [ProcessId]   INT          IDENTITY (1, 1) NOT NULL,
    [ProcessName] VARCHAR (50) NULL,
    CONSTRAINT [PK_tbl_CI_lookup_fileprocess_details] PRIMARY KEY CLUSTERED ([ProcessId] ASC)
);

