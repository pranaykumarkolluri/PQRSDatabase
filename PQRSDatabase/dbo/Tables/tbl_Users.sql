CREATE TABLE [dbo].[tbl_Users] (
    [UserID]        INT            IDENTITY (1, 1) NOT NULL,
    [UserName]      VARCHAR (50)   NOT NULL,
    [FirstName]     VARCHAR (50)   NULL,
    [LastName]      VARCHAR (50)   NULL,
    [NPI]           VARCHAR (50)   NULL,
    [EMail_Address] VARCHAR (50)   NULL,
    [Attested]      BIT            NULL,
    [Status]        INT            NULL,
    [Created_Date]  DATETIME       NULL,
    [Created_By]    VARCHAR (50)   NULL,
    [Last_Mod_Date] DATETIME       NULL,
    [Last_Mod_By]   VARCHAR (50)   NULL,
    [ProfileImage]  NVARCHAR (250) NULL,
    [NRDRUserID]    NVARCHAR (50)  NULL,
    [Notes]         VARCHAR (5000) NULL,
    CONSTRAINT [PK_tbl_Physician] PRIMARY KEY CLUSTERED ([UserID] ASC)
);

