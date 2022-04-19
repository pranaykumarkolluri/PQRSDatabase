CREATE TABLE [dbo].[tbl_AttestationFiles] (
    [FileId]     INT           IDENTITY (1, 1) NOT NULL,
    [FileName]   VARCHAR (100) NULL,
    [Status]     VARCHAR (50)  NULL,
    [CreatedBy]  INT           NULL,
    [CreateDate] DATETIME      NULL,
    [UpdateDate] DATETIME      NULL,
    [UpdatedBy]  INT           NULL,
    [CmsYear]    INT           NULL,
    [comment]    VARCHAR (MAX) NULL,
    [IsActive]   BIT           NULL,
    CONSTRAINT [PK_tbl_AttestationFiles] PRIMARY KEY CLUSTERED ([FileId] ASC)
);

