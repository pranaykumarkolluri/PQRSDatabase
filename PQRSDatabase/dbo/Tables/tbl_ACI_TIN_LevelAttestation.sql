CREATE TABLE [dbo].[tbl_ACI_TIN_LevelAttestation] (
    [id]                        INT           IDENTITY (1, 1) NOT NULL,
    [GPROTIN]                   VARCHAR (11)  NOT NULL,
    [GPROTIN_EmailAddress]      VARCHAR (100) NULL,
    [CreatedBy]                 VARCHAR (100) NULL,
    [CreatedDate]               DATETIME      NULL,
    [Modifiedby]                VARCHAR (100) NULL,
    [ModifiedDate]              DATETIME      NULL,
    [Tin_CMSAttestYear]         INT           NOT NULL,
    [IsAttested]                BIT           NOT NULL,
    [Attestation_Agree_Time]    DATETIME      NULL,
    [Attestation_Disagree_Time] DATETIME      NULL,
    [AttestedBy]                INT           NULL,
    [Last_Modified_username]    VARCHAR (50)  NULL,
    CONSTRAINT [PK_tbl_ACI_TIN_Level_Attestation] PRIMARY KEY CLUSTERED ([id] ASC)
);

