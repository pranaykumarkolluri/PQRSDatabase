CREATE TABLE [dbo].[tbl_CI_Source_UniqueKeys_oct_11_19bkp] (
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
    [CehrtId]                    VARCHAR (50) NULL
);

