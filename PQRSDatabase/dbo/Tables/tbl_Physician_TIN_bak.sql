CREATE TABLE [dbo].[tbl_Physician_TIN_bak] (
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
    [GPRO]            BIT           NULL
);

