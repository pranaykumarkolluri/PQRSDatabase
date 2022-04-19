CREATE TYPE [dbo].[MeasureRuleConfigPart5_Type] AS TABLE (
    [MeasureId]    INT            NULL,
    [IsAvgMes]     BIT            NULL,
    [AvgMes]       VARCHAR (50)   NULL,
    [IsRemoveAll]  BIT            NULL,
    [Measure_Desc] VARCHAR (1000) NULL);

