CREATE TYPE [dbo].[MeasureRuleConfigPart4_Type] AS TABLE (
    [MeasureId]             INT      NULL,
    [IsAcceptableDateRange] BIT      NULL,
    [StartDate]             DATETIME NULL,
    [EndDate]               DATETIME NULL,
    [IsRemoveAll]           BIT      NULL);

