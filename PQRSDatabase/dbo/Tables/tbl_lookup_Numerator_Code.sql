CREATE TABLE [dbo].[tbl_lookup_Numerator_Code] (
    [Num_Code_ID]              INT            IDENTITY (1, 1) NOT NULL,
    [Measure_ID]               INT            NULL,
    [Measure_Num]              VARCHAR (50)   NULL,
    [Numerator_Code]           VARCHAR (100)  NULL,
    [Numerator_Code_Desc]      VARCHAR (4000) NULL,
    [Numerator_Display_Seq]    INT            NULL,
    [Numerator_response_Value] INT            NULL,
    [Exclusion]                VARCHAR (1)    NULL,
    [Performance_met]          VARCHAR (2)    NULL,
    [Status]                   VARCHAR (50)   NULL,
    [Denominator_Exceptions]   VARCHAR (1)    NULL,
    [CMSYear]                  INT            NOT NULL,
    [Criteria]                 VARCHAR (20)   NULL,
    [Last_Mod_Date]            DATETIME       NULL,
    [Created_date]             DATETIME       NULL,
    [Last_Mod_by]              VARCHAR (100)  NULL,
    [Created_By]               VARCHAR (100)  NULL,
    CONSTRAINT [PK_tbl_lookup_Numerator_Code] PRIMARY KEY CLUSTERED ([Num_Code_ID] ASC),
    CONSTRAINT [FK_tbl_lookup_Numerator_Code_tbl_Lookup_Measure] FOREIGN KEY ([Measure_ID]) REFERENCES [dbo].[tbl_Lookup_Measure] ([Measure_ID])
);

