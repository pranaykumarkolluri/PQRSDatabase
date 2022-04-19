CREATE TABLE [dbo].[tbl_ValidateImportExams] (
    [ExamsID]      INT              NOT NULL,
    [GUI]          UNIQUEIDENTIFIER NOT NULL,
    [Created_Date] DATETIME         NULL,
    CONSTRAINT [PK_tbl_ValidateImportExams] PRIMARY KEY CLUSTERED ([ExamsID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tbl_ValidateImportExams_gui]
    ON [dbo].[tbl_ValidateImportExams]([GUI] ASC);

