CREATE TABLE [dbo].[tbl_Lookup_Measure_Extension_values] (
    [MeasureExt_ValuesID]             INT          IDENTITY (1, 1) NOT NULL,
    [Measure_Ext_Id]                  INT          NOT NULL,
    [Measure_Ext_Response_Code]       VARCHAR (50) NOT NULL,
    [Measure_Ext_Response_Code_Value] INT          NOT NULL,
    CONSTRAINT [PK_tbl_Lookup_Measure_Extension_values] PRIMARY KEY CLUSTERED ([MeasureExt_ValuesID] ASC)
);

