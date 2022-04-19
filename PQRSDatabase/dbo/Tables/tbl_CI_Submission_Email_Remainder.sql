CREATE TABLE [dbo].[tbl_CI_Submission_Email_Remainder] (
    [Id]                         INT           IDENTITY (1, 1) NOT NULL,
    [Tin]                        VARCHAR (9)   NULL,
    [NPI]                        VARCHAR (10)  NULL,
    [QM_Measures_MIPS]           INT           NULL,
    [QM_Measures_CMS]            INT           NULL,
    [QM_SixMeasures_CMS]         BIT           NULL,
    [QM_MeasuresData_CMS]        VARCHAR (500) NULL,
    [Email_NotificationRequired] BIT           NULL,
    [IA_Measures_MIPS]           BIT           NULL,
    [IA_Measures_CMS]            BIT           NULL,
    [PI_Measures_MIPS]           BIT           NULL,
    [PI_Measures_CMS]            BIT           NULL,
    [CmsYear]                    INT           NULL,
    [CreatedDate]                DATETIME      NULL,
    [CreatedBy]                  VARCHAR (50)  NULL,
    [UpdatedDate]                DATETIME      NULL,
    [UpdatedBy]                  VARCHAR (50)  NULL,
    [Email_SubjectStatus_Value]  INT           NULL,
    CONSTRAINT [PK_tbl_CI_Submission_Email_Remainder] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tbl_CI_Submission_Email_Remainder_tbl_CI_lookup_Email_SubjectStatus] FOREIGN KEY ([Email_SubjectStatus_Value]) REFERENCES [dbo].[tbl_CI_lookup_Email_SubjectStatus] ([Email_SubjectStatus_Value])
);

