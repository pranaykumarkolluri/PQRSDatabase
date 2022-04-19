CREATE TABLE [dbo].[tbl_PatientIds_decryption_Npis] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [Npi]          VARCHAR (10)  NULL,
    [CmsYear]      INT           NULL,
    [Status]       VARCHAR (50)  NULL,
    [ErrorMessage] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_tbl_PatientIds_decryption_Npis] PRIMARY KEY CLUSTERED ([Id] ASC)
);

