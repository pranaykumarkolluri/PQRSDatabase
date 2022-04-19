CREATE TABLE [dbo].[tbl_CI_Submissions_Data] (
    [CI_Submission_Id]    UNIQUEIDENTIFIER NOT NULL,
    [Submissions_Req_Id]  UNIQUEIDENTIFIER NULL,
    [Tin]                 VARCHAR (9)      NULL,
    [Npi]                 VARCHAR (10)     NULL,
    [SubmissionUniqueKey] VARCHAR (50)     NULL,
    [CmsYear]             INT              NULL,
    [EntityType]          VARCHAR (50)     NULL,
    [CreatedDate]         DATETIME         NULL,
    [CreatedBy]           VARCHAR (50)     NULL,
    [ErrorMeassage]       VARCHAR (500)    NULL,
    CONSTRAINT [PK_tbl_CI_Submissions_Data] PRIMARY KEY CLUSTERED ([CI_Submission_Id] ASC)
);

