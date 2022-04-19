CREATE TABLE [dbo].[Tbl_Backend_TIN_IA] (
    [Id]         INT          IDENTITY (1, 1) NOT NULL,
    [Tin]        VARCHAR (9)  NULL,
    [Activity]   VARCHAR (50) NULL,
    [CMSYear]    INT          NULL,
    [Start_Date] DATETIME     NULL,
    [End_Date]   DATETIME     NULL,
    [Is_Done]    BIT          CONSTRAINT [DF_Tbl_Backend_TIN_IA_Is_Done] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Tbl_Backend_TIN_IA] PRIMARY KEY CLUSTERED ([Id] ASC)
);

