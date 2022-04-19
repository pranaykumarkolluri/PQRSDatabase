CREATE TABLE [dbo].[tbl_Attestation_TINNPIS_BACKUP_FORJIRA#659] (
    [Id]         INT          IDENTITY (1, 1) NOT NULL,
    [FileId]     INT          NOT NULL,
    [TIN]        VARCHAR (9)  NULL,
    [NPI]        VARCHAR (10) NULL,
    [CreatedBy]  INT          NULL,
    [CreateDate] DATETIME     NULL
);

