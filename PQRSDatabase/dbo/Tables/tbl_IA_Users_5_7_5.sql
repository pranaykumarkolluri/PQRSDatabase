CREATE TABLE [dbo].[tbl_IA_Users_5_7_5] (
    [Id]              INT          IDENTITY (1, 1) NOT NULL,
    [SelectedID]      INT          NULL,
    [IsGpro]          BIT          NULL,
    [NPI]             VARCHAR (10) NULL,
    [TIN]             VARCHAR (10) NULL,
    [Updatedby]       VARCHAR (50) NULL,
    [UpdatedDateTime] DATETIME     NULL,
    [CMSYear]         INT          NULL
);

