CREATE TABLE [dbo].[tbl_Exam_Measure_Data_Extension] (
    [Exam_Measure_Data_Ext_ID] INT          IDENTITY (1, 1) NOT NULL,
    [Exam_Measure_Data_ID]     INT          NOT NULL,
    [Measure_Ext_Id]           INT          NOT NULL,
    [Other_Question_num]       INT          NULL,
    [Response_Value]           VARCHAR (50) NULL,
    [Created_by]               VARCHAR (50) NULL,
    [Created_Date]             DATETIME     NULL,
    [Last_Modified_Date]       DATETIME     NULL,
    [Last_Modified_By]         VARCHAR (50) NULL,
    CONSTRAINT [PK_tbl_Exam_Measure_Data_Extension] PRIMARY KEY CLUSTERED ([Exam_Measure_Data_Ext_ID] ASC),
    CONSTRAINT [FK_tbl_Exam_Measure_Data_Extension_tbl_Lookup_Measure_Extension] FOREIGN KEY ([Measure_Ext_Id]) REFERENCES [dbo].[tbl_Lookup_Measure_Extension] ([Measure_Ext_Id])
);

