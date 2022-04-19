CREATE TABLE [dbo].[tbl_CI_lookup_CIFailureCases] (
    [FailureCaseId]      INT           IDENTITY (1, 1) NOT NULL,
    [FailureType]        VARCHAR (50)  NULL,
    [FailureDescription] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_tbl_CI_lookup_CIFailureCases] PRIMARY KEY CLUSTERED ([FailureCaseId] ASC)
);

