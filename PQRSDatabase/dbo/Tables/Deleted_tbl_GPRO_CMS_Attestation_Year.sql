CREATE TABLE [dbo].[Deleted_tbl_GPRO_CMS_Attestation_Year] (
    [Tin_Attestation_Id]        INT           IDENTITY (1, 1) NOT NULL,
    [Tin_CMSAttestYear]         INT           NOT NULL,
    [Exam_Tin]                  VARCHAR (10)  NOT NULL,
    [IsAttested]                BIT           CONSTRAINT [DF_tbl_GPRO_CMS_Attestation_Year_IsAttested] DEFAULT ((0)) NOT NULL,
    [Attestation_Agree_Time]    DATETIME      NULL,
    [Attestation_Disagree_Time] DATETIME      NULL,
    [AttestedBy]                INT           NULL,
    [Last_Modified_By]          INT           NULL,
    [Last_Modified_FacilityID]  VARCHAR (10)  NULL,
    [EmailAddress]              VARCHAR (100) NULL,
    CONSTRAINT [PK_tbl_GPRO_CMS_Attestation_Year] PRIMARY KEY CLUSTERED ([Tin_Attestation_Id] ASC)
);

