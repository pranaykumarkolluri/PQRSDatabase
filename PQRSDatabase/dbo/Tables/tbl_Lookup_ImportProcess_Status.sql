CREATE TABLE [dbo].[tbl_Lookup_ImportProcess_Status] (
    [ID]                INT            NOT NULL,
    [Description]       VARCHAR (50)   NULL,
    [FileStatus]        BIT            NULL,
    [DataStatus]        BIT            NULL,
    [ActiveStatus]      BIT            NULL,
    [ExitStatus]        BIT            NULL,
    [DataStatusMessage] VARCHAR (1000) NULL,
    CONSTRAINT [PK_tbl_Lookup_ImportProcess_Status] PRIMARY KEY CLUSTERED ([ID] ASC)
);

