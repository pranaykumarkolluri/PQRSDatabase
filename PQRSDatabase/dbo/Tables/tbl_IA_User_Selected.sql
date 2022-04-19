CREATE TABLE [dbo].[tbl_IA_User_Selected] (
    [Id]               INT            IDENTITY (1, 1) NOT NULL,
    [SelectedID]       INT            NOT NULL,
    [SelectedActivity] VARCHAR (5000) NULL,
    [StartDate]        DATETIME       NULL,
    [EndDate]          DATETIME       NULL,
    [UpdatedBy]        VARCHAR (50)   NULL,
    [UpdatedDateTime]  DATETIME       NULL,
    [CMSYear]          INT            CONSTRAINT [DF_tbl_IA_User_Selected_CMSYear] DEFAULT ((2017)) NULL,
    [attest]           BIT            NULL,
    CONSTRAINT [PK_tbl_User_Selected_Improvement_Activites] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tbl_User_Selected_Improvement_Activites_tbl_User_Selected_IA_Categories] FOREIGN KEY ([SelectedID]) REFERENCES [dbo].[tbl_IA_User_Selected_Categories] ([ID]) ON DELETE CASCADE
);

