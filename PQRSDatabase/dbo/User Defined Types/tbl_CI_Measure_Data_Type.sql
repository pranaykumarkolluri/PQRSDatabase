CREATE TYPE [dbo].[tbl_CI_Measure_Data_Type] AS TABLE (
    [CategoryId]   INT           NULL,
    [Measure_Id]   VARCHAR (50)  NULL,
    [Measure_Name] VARCHAR (50)  NULL,
    [value]        VARCHAR (MAX) NULL,
    [Notes]        VARCHAR (MAX) NULL);

