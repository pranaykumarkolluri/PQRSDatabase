CREATE TABLE [dbo].[tbl_ACI_Attestation_Year] (
    [Attestation_Id]            INT          IDENTITY (1, 1) NOT NULL,
    [CMSAttestYear]             INT          NULL,
    [IsAttested]                BIT          NULL,
    [EmailAddress]              VARCHAR (50) NULL,
    [Attestation_Agree_Time]    DATETIME     NULL,
    [Attestation_Disagree_Time] DATETIME     NULL,
    [CreatedBy]                 INT          NULL,
    [ModifiedBy]                INT          NULL,
    [CreatedDate]               DATETIME     NULL,
    [ModifiedDate]              DATETIME     NULL,
    CONSTRAINT [PK_tbl_ACI_Attestation_Year] PRIMARY KEY CLUSTERED ([Attestation_Id] ASC)
);

