CREATE TABLE [dbo].[tbl_Attestation_TINNPIS] (
    [Id]         INT          IDENTITY (1, 1) NOT NULL,
    [FileId]     INT          NOT NULL,
    [TIN]        VARCHAR (9)  NULL,
    [NPI]        VARCHAR (10) NULL,
    [CreatedBy]  INT          NULL,
    [CreateDate] DATETIME     NULL,
    CONSTRAINT [PK_tbl_Attestation_TINNPIS] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tbl_Attestation_TINNPIS_tbl_AttestationFiles] FOREIGN KEY ([FileId]) REFERENCES [dbo].[tbl_AttestationFiles] ([FileId])
);

