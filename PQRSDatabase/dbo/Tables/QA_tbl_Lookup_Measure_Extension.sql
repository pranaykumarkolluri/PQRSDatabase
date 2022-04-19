CREATE TABLE [dbo].[QA_tbl_Lookup_Measure_Extension] (
    [Measure_Ext_Id]            INT          IDENTITY (1, 1) NOT NULL,
    [Measure_ID]                INT          NULL,
    [Measure_num]               VARCHAR (50) NULL,
    [Other_Question_Num]        VARCHAR (50) NULL,
    [Question_Text]             VARCHAR (50) NULL,
    [Measure_Ext_Created_Date]  DATE         NULL,
    [Measure_Ext_Created_By]    VARCHAR (50) NULL,
    [Measure_Ext_Modified_Date] DATE         NULL,
    [Measure_Ext_Modified_By]   VARCHAR (50) NULL,
    [CMSYear]                   INT          NOT NULL
);

