CREATE TABLE [dbo].[tbl_Tin_NPI_90Days_Check] (
    [Id_90Days_Check]  INT          IDENTITY (1, 1) NOT NULL,
    [TIN]              VARCHAR (9)  NULL,
    [NPI]              VARCHAR (11) NULL,
    [is90Days_Checked] BIT          CONSTRAINT [DF_tbl_Tin_NPI_90Days_Check_is90Days_Checked] DEFAULT ((0)) NOT NULL,
    [CMSYear]          INT          NULL,
    [isGpro]           BIT          NULL,
    [CreatedBy]        INT          NULL,
    [CreatedDate]      DATETIME     NULL,
    [LastModifiedBy]   INT          NULL,
    [LastModifiedDate] DATETIME     NULL,
    CONSTRAINT [PK_tbl_Tin_NPI_90Days_Check] PRIMARY KEY CLUSTERED ([Id_90Days_Check] ASC)
);

