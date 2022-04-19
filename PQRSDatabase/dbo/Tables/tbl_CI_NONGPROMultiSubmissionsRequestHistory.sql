CREATE TABLE [dbo].[tbl_CI_NONGPROMultiSubmissionsRequestHistory] (
    [ReqId]       INT         IDENTITY (1, 1) NOT NULL,
    [TIN]         VARCHAR (9) NULL,
    [CategoryId]  INT         NULL,
    [CMSYear]     INT         NULL,
    [UserId]      INT         NULL,
    [CreatedDate] DATETIME    NULL,
    [UpdatedDate] DATETIME    NULL,
    CONSTRAINT [PK_tbl_CI_NONGPROMultiSubmissionsRequestHistory] PRIMARY KEY CLUSTERED ([ReqId] ASC)
);

