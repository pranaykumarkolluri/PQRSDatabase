CREATE TABLE [dbo].[tbl_Lookup_PR_Tooltips] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [ColumnHeading] VARCHAR (500) NULL,
    [Tooltip]       VARCHAR (MAX) NULL,
    [Orderfor_P]    INT           NULL,
    [Orderfor_C]    INT           NULL,
    CONSTRAINT [PK_tbl_lookup_PR_tooltips] PRIMARY KEY CLUSTERED ([Id] ASC)
);

