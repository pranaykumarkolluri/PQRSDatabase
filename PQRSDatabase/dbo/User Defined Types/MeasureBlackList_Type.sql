CREATE TYPE [dbo].[MeasureBlackList_Type] AS TABLE (
    [TIN]        VARCHAR (9)  NULL,
    [CMSYear]    INT          NULL,
    [CategoryId] INT          NULL,
    [Measure]    VARCHAR (50) NULL);

