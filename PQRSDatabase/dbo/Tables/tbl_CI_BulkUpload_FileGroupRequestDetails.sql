CREATE TABLE [dbo].[tbl_CI_BulkUpload_FileGroupRequestDetails] (
    [FileGroupReqId] INT      IDENTITY (1, 1) NOT NULL,
    [CreateDate]     DATETIME NULL,
    [UpdatedDate]    DATETIME NULL,
    [CreatedBy]      INT      NULL,
    [UpdatedBy]      INT      NULL,
    [CategoryId]     INT      NULL,
    [Status]         INT      NULL,
    [CMSYear]        INT      NULL,
    CONSTRAINT [PK_tbl_CI_Shedule_FileGroupRequestDetails] PRIMARY KEY CLUSTERED ([FileGroupReqId] ASC)
);

