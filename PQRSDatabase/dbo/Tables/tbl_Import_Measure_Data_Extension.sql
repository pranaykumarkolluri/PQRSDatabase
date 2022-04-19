CREATE TABLE [dbo].[tbl_Import_Measure_Data_Extension] (
    [Import_Measure_Data_Ext_ID]            INT           IDENTITY (1, 1) NOT NULL,
    [Import_Measure_Data_ID]                INT           NULL,
    [Import_Measure_Extension_Num]          VARCHAR (50)  NULL,
    [Import_Measure_Extension_Reponse_Code] VARCHAR (50)  NULL,
    [Error_Codes_Desc]                      VARCHAR (MAX) NULL,
    [Status]                                INT           NULL,
    [Error_Codes_JSON]                      VARCHAR (MAX) NULL,
    CONSTRAINT [PK_tbl_Import_Measure_Data_Extension] PRIMARY KEY CLUSTERED ([Import_Measure_Data_Ext_ID] ASC)
);

