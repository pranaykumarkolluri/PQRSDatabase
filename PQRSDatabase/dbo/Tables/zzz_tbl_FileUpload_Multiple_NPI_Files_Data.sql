CREATE TABLE [dbo].[zzz_tbl_FileUpload_Multiple_NPI_Files_Data] (
    [ID]           INT          IDENTITY (1, 1) NOT NULL,
    [FileName]     VARCHAR (50) NOT NULL,
    [NPI]          VARCHAR (50) NULL,
    [Created_Date] DATETIME     NULL,
    [Created_By]   INT          NULL
);

