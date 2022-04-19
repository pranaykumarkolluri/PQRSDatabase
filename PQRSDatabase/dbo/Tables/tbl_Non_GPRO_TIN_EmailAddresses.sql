CREATE TABLE [dbo].[tbl_Non_GPRO_TIN_EmailAddresses] (
    [id]                        INT           IDENTITY (1, 1) NOT NULL,
    [Non_GPROTIN]               VARCHAR (11)  NOT NULL,
    [NonGPROTIN_EmailAddress]   VARCHAR (100) NULL,
    [CreatedBy]                 VARCHAR (100) NULL,
    [CreatedDate]               DATETIME      NULL,
    [Modifiedby]                VARCHAR (100) NULL,
    [ModifiedDate]              DATETIME      NULL,
    [Tin_CMSAttestYear]         INT           DEFAULT ((2016)) NOT NULL,
    [IsAttested]                BIT           DEFAULT ((0)) NOT NULL,
    [Attestation_Agree_Time]    DATETIME      NULL,
    [Attestation_Disagree_Time] DATETIME      NULL,
    [AttestedBy]                INT           NULL,
    [Last_Modified_FacilityID]  VARCHAR (10)  NULL,
    [NPI]                       VARCHAR (10)  NULL,
    CONSTRAINT [PK_tbl_Non_GPRO_TIN_EmailAddresses] PRIMARY KEY CLUSTERED ([id] ASC)
);

