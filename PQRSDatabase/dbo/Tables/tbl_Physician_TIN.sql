CREATE TABLE [dbo].[tbl_Physician_TIN] (
    [TIN_ID]          INT           IDENTITY (1, 1) NOT NULL,
    [UserID]          INT           NOT NULL,
    [TIN]             VARCHAR (10)  NOT NULL,
    [Facility_name]   VARCHAR (50)  NULL,
    [Created_Date]    DATE          NULL,
    [Created_By]      NVARCHAR (50) NULL,
    [Last_Mod_Date]   DATE          NULL,
    [Last_Mod_By]     NVARCHAR (50) NULL,
    [TIN_DESCRIPTION] VARCHAR (255) NULL,
    [REGISTRY_NAME]   VARCHAR (50)  NULL,
    [GPRO]            BIT           NULL,
    CONSTRAINT [PK_tbl_Physician_TIN] PRIMARY KEY CLUSTERED ([TIN_ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tbl_Physician_TIN]
    ON [dbo].[tbl_Physician_TIN]([TIN] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tbl_Physician_USERID_TIN]
    ON [dbo].[tbl_Physician_TIN]([UserID] ASC, [TIN] ASC);

