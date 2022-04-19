﻿CREATE TABLE [dbo].[tbl_PQRS_FileUpload_TINData] (
    [ID]     INT         IDENTITY (1, 1) NOT NULL,
    [FileId] INT         NOT NULL,
    [TIN]    VARCHAR (9) NOT NULL,
    CONSTRAINT [PK__tbl_PQRS__3214EC2737A5467D] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_tbl_PQRS_FileUpload_TINData_tbl_PQRS_FILE_UPLOAD_HISTORY] FOREIGN KEY ([FileId]) REFERENCES [dbo].[tbl_PQRS_FILE_UPLOAD_HISTORY] ([ID])
);

