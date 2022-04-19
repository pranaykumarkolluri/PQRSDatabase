CREATE TABLE [dbo].[tbl_Generated_ACIXML_Files] (
    [File_Id]             INT           IDENTITY (1, 1) NOT NULL,
    [File_Number]         INT           NOT NULL,
    [File_Name]           VARCHAR (250) NOT NULL,
    [File_Size]           INT           NOT NULL,
    [Total_Records_Count] INT           NOT NULL,
    [NPI]                 VARCHAR (50)  NOT NULL,
    [CMS_Submission_Year] INT           NULL,
    [TIN]                 VARCHAR (50)  NULL,
    [createdate]          DATETIME      NULL,
    CONSTRAINT [PK_tbl_Generated_ACIXML_Files] PRIMARY KEY CLUSTERED ([File_Id] ASC)
);

