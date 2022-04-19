CREATE TABLE [dbo].[tbl_Users_not] (
    [UserID]        INT            IDENTITY (1, 1) NOT NULL,
    [UserName]      VARCHAR (50)   NOT NULL,
    [FirstName]     VARCHAR (50)   NULL,
    [LastName]      VARCHAR (50)   NULL,
    [NPI]           VARCHAR (50)   NULL,
    [EMail_Address] VARCHAR (50)   NULL,
    [Attested]      BIT            NULL,
    [Status]        INT            NULL,
    [Created_Date]  DATE           NULL,
    [Created_By]    VARCHAR (50)   NULL,
    [Last_Mod_Date] DATE           NULL,
    [Last_Mod_By]   VARCHAR (50)   NULL,
    [ProfileImage]  NVARCHAR (250) NULL,
    [NRDRUserID]    NVARCHAR (50)  NULL,
    CONSTRAINT [PK_tbl_Physician_1] PRIMARY KEY CLUSTERED ([UserID] ASC)
);

