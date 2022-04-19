CREATE TABLE [dbo].[tbl_CMS_Attestation_Year] (
    [Attestation_Id]            INT           IDENTITY (1, 1) NOT NULL,
    [CMSAttestYear]             INT           NULL,
    [PhysicianNPI]              VARCHAR (50)  NULL,
    [IsAttested]                BIT           NULL,
    [Attestation_Agree_Time]    DATETIME      NULL,
    [Attestation_Disagree_Time] DATETIME      NULL,
    [AttestedBy]                INT           NULL,
    [Email]                     VARCHAR (100) NULL,
    [TIN]                       VARCHAR (9)   NULL,
    CONSTRAINT [PK_tbl_CMS_Attestation_Year] PRIMARY KEY CLUSTERED ([Attestation_Id] ASC)
);

