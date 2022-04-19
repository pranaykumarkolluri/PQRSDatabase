CREATE TABLE [dbo].[QA_tbl_lookup_Numerator_Code] (
    [Num_Code_ID]              INT           IDENTITY (1, 1) NOT NULL,
    [Measure_ID]               INT           NULL,
    [Measure_Num]              VARCHAR (50)  NULL,
    [Numerator_Code]           VARCHAR (100) NULL,
    [Numerator_Code_Desc]      VARCHAR (MAX) NULL,
    [Numerator_Display_Seq]    INT           NULL,
    [Numerator_response_Value] INT           NULL,
    [Exclusion]                VARCHAR (1)   NULL,
    [Performance_met]          VARCHAR (2)   NULL,
    [Status]                   VARCHAR (50)  NULL,
    [Denominator_Exceptions]   VARCHAR (1)   NULL,
    [CMSYear]                  INT           NOT NULL,
    [Criteria]                 VARCHAR (20)  NULL
);

