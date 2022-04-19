CREATE TABLE [dbo].[tbl_Lookup_Denominator_Diag_Code] (
    [Denom_Diag_Code_ID]    INT          IDENTITY (1, 1) NOT NULL,
    [Measure_ID]            INT          NULL,
    [Measure_Num]           VARCHAR (50) NULL,
    [Code]                  VARCHAR (50) NULL,
    [status]                VARCHAR (50) NULL,
    [CMSYear]               INT          NOT NULL,
    [Denominator_Exclusion] BIT          NULL,
    [Last_Mod_Date]         DATETIME     NULL,
    [Created_Date]          DATETIME     NULL,
    [Last_Mod_by]           VARCHAR (50) NULL,
    [Created_By]            VARCHAR (50) NULL,
    CONSTRAINT [PK_tbl_Lookup_Denominator_Diag_Code] PRIMARY KEY CLUSTERED ([Denom_Diag_Code_ID] ASC),
    CONSTRAINT [FK_tbl_Lookup_Denominator_Diag_Code_tbl_Lookup_Measure] FOREIGN KEY ([Measure_ID]) REFERENCES [dbo].[tbl_Lookup_Measure] ([Measure_ID])
);

