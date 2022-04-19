CREATE TYPE [dbo].[tbl_Physician_TIN_TYPE] AS TABLE (
    [UserID]          INT           NULL,
    [TIN]             VARCHAR (10)  NULL,
    [Created_Date]    DATE          NULL,
    [Created_By]      NVARCHAR (50) NULL,
    [TIN_DESCRIPTION] VARCHAR (255) NULL,
    [REGISTRY_NAME]   VARCHAR (50)  NULL);

