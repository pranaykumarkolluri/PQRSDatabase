CREATE TABLE [dbo].[QA_tbl_lookup_Denominator_Proc_Code] (
    [Denom_Proc_Code_ID]    INT           IDENTITY (1, 1) NOT NULL,
    [Measure_ID]            INT           NULL,
    [Measure_num]           VARCHAR (50)  NOT NULL,
    [Proc_code]             VARCHAR (100) NULL,
    [Status]                VARCHAR (1)   NULL,
    [Created_date]          DATE          NULL,
    [Created_By]            VARCHAR (50)  NULL,
    [Las_mod_Date]          DATE          NULL,
    [Last_Mod_by]           VARCHAR (50)  NULL,
    [CMSYear]               INT           NOT NULL,
    [Denominator_Exclusion] BIT           NULL,
    [Gender_Exclusion]      VARCHAR (5)   NULL,
    [Atleast_Condition_226] VARCHAR (200) NULL,
    [Proc_Criteria]         VARCHAR (20)  NULL,
    [IsMain_ProcCode]       BIT           NULL
);

