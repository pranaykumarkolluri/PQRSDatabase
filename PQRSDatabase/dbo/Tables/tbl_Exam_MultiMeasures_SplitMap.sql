CREATE TABLE [dbo].[tbl_Exam_MultiMeasures_SplitMap] (
    [MasterExamId] INT NOT NULL,
    [ChildExamid]  INT NOT NULL,
    CONSTRAINT [PK_tblExam_MultiMeasures_SplitMap] PRIMARY KEY CLUSTERED ([MasterExamId] ASC, [ChildExamid] ASC)
);

