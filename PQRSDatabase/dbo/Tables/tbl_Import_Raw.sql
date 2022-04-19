CREATE TABLE [dbo].[tbl_Import_Raw] (
    [ImportID]                           INT            IDENTITY (1, 1) NOT NULL,
    [ImportRawData]                      NVARCHAR (MAX) NULL,
    [ImportDate]                         DATETIME       NULL,
    [ImportIPAddress]                    VARCHAR (50)   CONSTRAINT [DF_tbl_Import_Raw_ImportIPAddress] DEFAULT (getdate()) NULL,
    [ImportCorrect]                      BIT            NULL,
    [Error_Codes]                        VARCHAR (MAX)  NULL,
    [Status]                             INT            NULL,
    [Data_Status]                        INT            NULL,
    [Correct_ExamsCount]                 INT            NULL,
    [InCorrect_ExamsCount]               INT            NULL,
    [No_of_Errors]                       INT            NULL,
    [Correct_ExamsWith_WarningCount]     INT            NULL,
    [InCorrect_ExamsWith_ExclusionCount] INT            NULL,
    CONSTRAINT [PK_tbl_Import_Raw] PRIMARY KEY CLUSTERED ([ImportID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20190612-192425]
    ON [dbo].[tbl_Import_Raw]([Status] ASC, [Data_Status] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20190926-130605d]
    ON [dbo].[tbl_Import_Raw]([Status] ASC, [Data_Status] ASC, [No_of_Errors] ASC);

