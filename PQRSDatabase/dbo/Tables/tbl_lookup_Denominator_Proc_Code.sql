CREATE TABLE [dbo].[tbl_lookup_Denominator_Proc_Code] (
    [Denom_Proc_Code_ID]    INT           IDENTITY (1, 1) NOT NULL,
    [Measure_ID]            INT           NULL,
    [Measure_num]           VARCHAR (50)  NOT NULL,
    [Proc_code]             VARCHAR (100) NULL,
    [Status]                VARCHAR (1)   NULL,
    [Created_date]          DATETIME      NULL,
    [Created_By]            VARCHAR (50)  NULL,
    [Las_mod_Date]          DATETIME      NULL,
    [Last_Mod_by]           VARCHAR (50)  NULL,
    [CMSYear]               INT           NOT NULL,
    [Denominator_Exclusion] BIT           NULL,
    [Gender_Exclusion]      VARCHAR (5)   NULL,
    [Atleast_Condition_226] VARCHAR (200) NULL,
    [Proc_Criteria]         VARCHAR (20)  NULL,
    [IsMain_ProcCode]       BIT           NULL,
    CONSTRAINT [PK_tbl_lookup_Denominator_Proc_Code] PRIMARY KEY CLUSTERED ([Denom_Proc_Code_ID] ASC),
    CONSTRAINT [FK_tbl_lookup_Denominator_Proc_Code_tbl_Lookup_Measure] FOREIGN KEY ([Measure_ID]) REFERENCES [dbo].[tbl_Lookup_Measure] ([Measure_ID])
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-2020Raju]
    ON [dbo].[tbl_lookup_Denominator_Proc_Code]([Measure_num] ASC, [Proc_code] ASC, [CMSYear] ASC, [Atleast_Condition_226] ASC);

