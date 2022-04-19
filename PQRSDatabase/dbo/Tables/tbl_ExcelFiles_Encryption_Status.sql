CREATE TABLE [dbo].[tbl_ExcelFiles_Encryption_Status] (
    [Id]                  INT          IDENTITY (1, 1) NOT NULL,
    [IsExcelFilesEncrypt] BIT          NULL,
    [UserName]            VARCHAR (50) NULL,
    [Created_By]          INT          NULL,
    [Created_Date]        DATETIME     NULL,
    [Lastmodified_Date]   DATETIME     NULL,
    [Lastmodified_By]     INT          NULL,
    CONSTRAINT [PK_tbl_ExcelFiles_Encryption_Status] PRIMARY KEY CLUSTERED ([Id] ASC)
);

