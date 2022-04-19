CREATE TABLE [dbo].[tbl_lookup_block_submission_bkp] (
    [BlockId]                INT          IDENTITY (1, 1) NOT NULL,
    [CMSYear]                INT          NOT NULL,
    [TIN]                    VARCHAR (9)  NOT NULL,
    [Measure_Num]            VARCHAR (50) NOT NULL,
    [Is_Blocked]             BIT          NULL,
    [Created_datetime]       DATETIME     NULL,
    [Last_Modified_datetime] DATETIME     NULL,
    [CategoryId]             INT          NULL,
    [ChangedBy]              INT          NULL
);

