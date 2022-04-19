CREATE TABLE [dbo].[tbl_Scheduled_Jobs_Log_Data] (
    [LogId]      INT          IDENTITY (1, 1) NOT NULL,
    [LogName]    VARCHAR (50) NOT NULL,
    [LogForYear] INT          NOT NULL,
    [LogValue]   VARCHAR (50) NULL,
    [LogTime]    DATETIME     NULL,
    CONSTRAINT [PK_tbl_Scheduled_Jobs_Log_Data] PRIMARY KEY CLUSTERED ([LogName] ASC, [LogForYear] ASC)
);

