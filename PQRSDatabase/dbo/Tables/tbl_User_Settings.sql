CREATE TABLE [dbo].[tbl_User_Settings] (
    [SettingsID]          INT      IDENTITY (1, 1) NOT NULL,
    [UserId]              INT      NOT NULL,
    [DisplayNoofRowsGrid] INT      NULL,
    [DefaultLeftMenu]     SMALLINT NULL,
    [CreatedDateTime]     DATETIME NULL,
    [UpdateDateTime]      DATETIME NULL,
    CONSTRAINT [PK_tbl_User_Settings] PRIMARY KEY CLUSTERED ([SettingsID] ASC)
);

