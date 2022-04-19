CREATE TABLE [dbo].[tbl_DuplicateExam_IDs] (
    [Id]           INT          IDENTITY (1, 1) NOT NULL,
    [Exam_ID]      INT          NULL,
    [Created_Date] DATETIME     NULL,
    [Created_By]   VARCHAR (50) NULL
);

