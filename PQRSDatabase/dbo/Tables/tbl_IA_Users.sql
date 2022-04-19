CREATE TABLE [dbo].[tbl_IA_Users] (
    [Id]              INT          IDENTITY (1, 1) NOT NULL,
    [SelectedID]      INT          NULL,
    [IsGpro]          BIT          NULL,
    [NPI]             VARCHAR (10) NULL,
    [TIN]             VARCHAR (10) NULL,
    [Updatedby]       VARCHAR (50) NULL,
    [UpdatedDateTime] DATETIME     NULL,
    [CMSYear]         INT          CONSTRAINT [DF_tbl_IA_Users_CMSYear] DEFAULT ((2017)) NULL,
    CONSTRAINT [PK_tbl_IA_Users] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tbl_IA_Users_tbl_User_Selected_IA_Categories] FOREIGN KEY ([SelectedID]) REFERENCES [dbo].[tbl_IA_User_Selected_Categories] ([ID]) ON DELETE CASCADE
);

