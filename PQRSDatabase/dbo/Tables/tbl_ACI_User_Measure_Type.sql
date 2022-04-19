CREATE TABLE [dbo].[tbl_ACI_User_Measure_Type] (
    [Selected_Id]      INT          IDENTITY (1, 1) NOT NULL,
    [ACI_Id]           INT          NULL,
    [Updated_By]       VARCHAR (50) NULL,
    [Updated_Datetime] DATETIME     NULL,
    CONSTRAINT [PK_tbl_User_Measure_Type] PRIMARY KEY CLUSTERED ([Selected_Id] ASC)
);

