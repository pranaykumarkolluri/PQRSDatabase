CREATE TABLE [dbo].[tbl_lookup_MeasureBlockList] (
    [Block_Mes_Id] INT          IDENTITY (1, 1) NOT NULL,
    [BlockId]      INT          NOT NULL,
    [Measure]      VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_tbl_lookup_MeasureBlockList] PRIMARY KEY CLUSTERED ([Block_Mes_Id] ASC),
    CONSTRAINT [FK_tbl_lookup_MeasureBlockList_tbl_lookup_block_submission] FOREIGN KEY ([BlockId]) REFERENCES [dbo].[tbl_lookup_block_submission] ([BlockId])
);

