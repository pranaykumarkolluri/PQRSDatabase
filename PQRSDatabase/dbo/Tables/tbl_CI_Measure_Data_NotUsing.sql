CREATE TABLE [dbo].[tbl_CI_Measure_Data_NotUsing] (
    [Mid]                 INT           IDENTITY (1, 1) NOT NULL,
    [KeyId]               INT           NULL,
    [CategoryId]          INT           NULL,
    [Measure_UniquekeyId] VARCHAR (50)  NULL,
    [Measure_Name]        VARCHAR (50)  NULL,
    [value]               VARCHAR (MAX) NULL,
    [CreatedDate]         DATETIME      NULL,
    [CreatedBy]           VARCHAR (50)  NULL,
    [Notes]               VARCHAR (500) NULL,
    [CMSYear]             INT           NULL,
    [CMSSubmissionDate]   DATETIME      NULL,
    CONSTRAINT [PK_tbl_CI_Measure_Data] PRIMARY KEY CLUSTERED ([Mid] ASC),
    CONSTRAINT [FK_tbl_CI_Measure_Data_tbl_CI_Socurce_UniqueKeys] FOREIGN KEY ([KeyId]) REFERENCES [dbo].[tbl_CI_Source_UniqueKeys] ([Key_Id])
);

