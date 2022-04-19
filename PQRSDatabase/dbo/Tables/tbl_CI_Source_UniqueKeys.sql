CREATE TABLE [dbo].[tbl_CI_Source_UniqueKeys] (
    [Key_Id]                     INT          IDENTITY (1, 1) NOT NULL,
    [Tin]                        VARCHAR (9)  NULL,
    [Npi]                        VARCHAR (10) NULL,
    [Submission_Uniquekey_Id]    VARCHAR (50) NULL,
    [MeasurementSet_Unquekey_id] VARCHAR (50) NULL,
    [Category_Id]                INT          NULL,
    [Response_Id]                INT          NULL,
    [IsMSetIdActive]             BIT          NULL,
    [CmsYear]                    INT          NULL,
    [Score_ResponseId]           INT          NULL,
    [CmsSubmissionDate]          DATETIME     NULL,
    [CehrtId]                    VARCHAR (50) NULL,
    CONSTRAINT [PK_tbl_CI_Socurce_UniqueKeys] PRIMARY KEY CLUSTERED ([Key_Id] ASC),
    CONSTRAINT [FK_tbl_CI_Socurce_UniqueKeys_tbl_CI_ResponseData] FOREIGN KEY ([Response_Id]) REFERENCES [dbo].[tbl_CI_ResponseData] ([Respone_Id]),
    CONSTRAINT [FK_tbl_CI_Socurce_UniqueKeys_tbl_lookup_Categories] FOREIGN KEY ([Category_Id]) REFERENCES [dbo].[tbl_CI_lookup_Categories] ([Category_Id])
);

