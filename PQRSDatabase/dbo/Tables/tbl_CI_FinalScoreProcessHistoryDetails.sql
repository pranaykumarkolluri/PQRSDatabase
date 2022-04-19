CREATE TABLE [dbo].[tbl_CI_FinalScoreProcessHistoryDetails] (
    [Fid]          INT           IDENTITY (1, 1) NOT NULL,
    [TIN]          VARCHAR (9)   NOT NULL,
    [NPI]          VARCHAR (10)  NULL,
    [Status_ID]    INT           NOT NULL,
    [CreatedBy]    INT           NOT NULL,
    [CreatedDate]  DATETIME      NULL,
    [UpdatedDate]  DATETIME      NULL,
    [ErrorMessage] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_tbl_CI_FinalScoreProcessHistoryDetails] PRIMARY KEY CLUSTERED ([Fid] ASC)
);

