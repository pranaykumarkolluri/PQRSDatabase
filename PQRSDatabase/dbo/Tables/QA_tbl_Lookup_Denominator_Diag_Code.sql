CREATE TABLE [dbo].[QA_tbl_Lookup_Denominator_Diag_Code] (
    [Denom_Diag_Code_ID]    INT          IDENTITY (1, 1) NOT NULL,
    [Measure_ID]            INT          NULL,
    [Measure_Num]           VARCHAR (50) NULL,
    [Code]                  VARCHAR (50) NULL,
    [status]                VARCHAR (50) NULL,
    [CMSYear]               INT          NOT NULL,
    [Denominator_Exclusion] BIT          NULL
);

