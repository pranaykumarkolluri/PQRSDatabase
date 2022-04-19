CREATE TABLE [dbo].[tmp_tbl_OptInReserveData] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [tin]          VARCHAR (9)   NULL,
    [npi]          VARCHAR (10)  NULL,
    [ispost]       BIT           NULL,
    [CreatedBy]    VARCHAR (50)  NULL,
    [CreatedDate]  DATETIME      NULL,
    [ResponseJson] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_tmp_tbl_OptInReserveData] PRIMARY KEY CLUSTERED ([Id] ASC)
);

