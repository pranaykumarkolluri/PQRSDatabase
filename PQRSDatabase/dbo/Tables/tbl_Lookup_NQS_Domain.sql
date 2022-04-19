CREATE TABLE [dbo].[tbl_Lookup_NQS_Domain] (
    [NQIS_Domain_ID]  INT            NOT NULL,
    [NQS_Domain_Code] VARCHAR (50)   NULL,
    [NQS_Domain_Desc] VARCHAR (1000) NULL,
    [Created_Date]    DATE           NULL,
    [Created_By]      VARBINARY (50) NULL,
    [Last_Mod_Date]   DATE           NULL,
    [Last_Mod_By]     VARBINARY (50) NULL,
    CONSTRAINT [PK_tbl_Lookup_NQS_Domain] PRIMARY KEY CLUSTERED ([NQIS_Domain_ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tbl_Lookup_NQS_Domain]
    ON [dbo].[tbl_Lookup_NQS_Domain]([NQS_Domain_Code] ASC);

