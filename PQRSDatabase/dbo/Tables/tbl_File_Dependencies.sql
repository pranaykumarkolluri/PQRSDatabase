CREATE TABLE [dbo].[tbl_File_Dependencies] (
    [FileId]    INT NOT NULL,
    [DepFileId] INT NOT NULL,
    CONSTRAINT [PK_tbl_File_Dependencies] PRIMARY KEY CLUSTERED ([FileId] ASC, [DepFileId] ASC),
    CONSTRAINT [FK_tbl_File_Dependencies_tbl_PQRS_FILE_UPLOAD_HISTORY2] FOREIGN KEY ([FileId]) REFERENCES [dbo].[tbl_PQRS_FILE_UPLOAD_HISTORY] ([ID])
);

