CREATE TABLE [dbo].[tbl_TIN_CehrtIds] (
    [Id]          INT          IDENTITY (1, 1) NOT NULL,
    [TIN]         VARCHAR (9)  NULL,
    [CEHRTID]     VARCHAR (50) NULL,
    [CreatedBy]   INT          NULL,
    [CreatedDate] DATETIME     NULL,
    [UpdatedBy]   INT          NULL,
    [UpdatedDate] DATETIME     NULL,
    [CMSYear]     INT          NULL,
    CONSTRAINT [PK_tbl_TIN_CehrtIds] PRIMARY KEY CLUSTERED ([Id] ASC)
);

