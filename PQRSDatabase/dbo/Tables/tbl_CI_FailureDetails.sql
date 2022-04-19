CREATE TABLE [dbo].[tbl_CI_FailureDetails] (
    [FailureId]      INT           IDENTITY (1, 1) NOT NULL,
    [FailureCaseId]  INT           NULL,
    [CategoryId]     INT           NULL,
    [Tin]            VARCHAR (9)   NULL,
    [Npi]            VARCHAR (10)  NULL,
    [CmsYear]        INT           NULL,
    [FailureMessage] VARCHAR (MAX) NULL,
    [CreatedDate]    DATETIME      NULL,
    [CreatedBy]      VARCHAR (50)  NULL,
    CONSTRAINT [PK_tbl_CI_FailureDetails] PRIMARY KEY CLUSTERED ([FailureId] ASC)
);

