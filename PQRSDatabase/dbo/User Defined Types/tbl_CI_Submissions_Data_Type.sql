CREATE TYPE [dbo].[tbl_CI_Submissions_Data_Type] AS TABLE (
    [Submissions_Req_Id]  UNIQUEIDENTIFIER NULL,
    [Tin]                 VARCHAR (9)      NULL,
    [Npi]                 VARCHAR (10)     NULL,
    [SubmissionUniqueKey] VARCHAR (50)     NULL,
    [CmsYear]             INT              NULL,
    [EntityType]          VARCHAR (50)     NULL,
    [CreatedDate]         DATETIME         NULL,
    [CreatedBy]           VARCHAR (50)     NULL);

