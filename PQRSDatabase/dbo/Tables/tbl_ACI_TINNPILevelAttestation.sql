CREATE TABLE [dbo].[tbl_ACI_TINNPILevelAttestation] (
    [Attestation_Id]            INT           IDENTITY (1, 1) NOT NULL,
    [CMSAttestYear]             INT           NULL,
    [PhysicianNPI]              VARCHAR (50)  NULL,
    [IsAttested]                BIT           NULL,
    [Attestation_Agree_Time]    DATETIME      NULL,
    [Attestation_Disagree_Time] DATETIME      NULL,
    [AttestedBy]                INT           NULL,
    [ModifiedBy]                INT           NULL,
    [CreatedBy]                 INT           NULL,
    [ModifiedDate]              DATETIME      NULL,
    [CreatedDate]               DATETIME      NULL,
    [Email]                     VARCHAR (100) NULL,
    CONSTRAINT [PK_tbl_ACI_TINNPILevelAttestation] PRIMARY KEY CLUSTERED ([Attestation_Id] ASC)
);

