CREATE TABLE [dbo].[tbl_CI_lookup_Email_SubjectStatus] (
    [Email_SubjectStatus_Value] INT          NOT NULL,
    [Email_SubjectStatus_Name]  VARCHAR (50) NULL,
    CONSTRAINT [PK_tbl_lookup_Email_SubjectStatus] PRIMARY KEY CLUSTERED ([Email_SubjectStatus_Value] ASC)
);

