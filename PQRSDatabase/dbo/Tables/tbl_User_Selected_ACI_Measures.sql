CREATE TABLE [dbo].[tbl_User_Selected_ACI_Measures] (
    [Id]                  INT           IDENTITY (1, 1) NOT NULL,
    [Selected_MeasureIds] VARCHAR (MAX) NULL,
    [Updated_By]          VARCHAR (50)  NULL,
    [Updated_Datetime]    DATETIME      NULL,
    [Start_Date]          DATETIME      NULL,
    [End_Date]            DATETIME      NULL,
    [Selected_Id]         INT           NULL,
    [CMSYear]             INT           NULL,
    [Numerator]           INT           NULL,
    [Denominator]         INT           NULL,
    [Attestion]           BIT           NULL,
    CONSTRAINT [PK_tbl_User_Selected_ACI_Measures] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tbl_User_Selected_ACI_Measures_tbl_ACI_User_Measure_Type] FOREIGN KEY ([Selected_Id]) REFERENCES [dbo].[tbl_ACI_User_Measure_Type] ([Selected_Id]) ON DELETE CASCADE
);

