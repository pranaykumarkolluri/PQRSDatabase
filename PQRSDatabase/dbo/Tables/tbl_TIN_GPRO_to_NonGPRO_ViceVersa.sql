CREATE TABLE [dbo].[tbl_TIN_GPRO_to_NonGPRO_ViceVersa] (
    [CMSYear]          INT          NOT NULL,
    [TIN]              VARCHAR (11) NOT NULL,
    [is_GPRO]          BIT          CONSTRAINT [DF_tbl_TIN_GPRO_to_NonGPRO_ViceVersa_is_GPRO] DEFAULT ((0)) NOT NULL,
    [Moved_to_GPRO]    BIT          NULL,
    [Moved_to_NonGPRO] BIT          NULL,
    [Last_Mod_By]      VARCHAR (50) NULL,
    [Last_Mod_Date]    DATETIME     NULL,
    CONSTRAINT [PK_tbl_TIN_GPRO_to_NonGPRO_ViceVersa] PRIMARY KEY CLUSTERED ([TIN] ASC, [CMSYear] ASC)
);

