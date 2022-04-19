CREATE TABLE [dbo].[tbl_Users_Update_History] (
    [ID]            INT           IDENTITY (1, 1) NOT NULL,
    [Old_UserName]  VARCHAR (50)  NULL,
    [New_UserName]  VARCHAR (50)  NULL,
    [Last_Mod_Date] DATETIME      NULL,
    [NRDRUserID]    NVARCHAR (50) NULL,
    CONSTRAINT [PK_tbl_Users_Update_History] PRIMARY KEY CLUSTERED ([ID] ASC)
);

