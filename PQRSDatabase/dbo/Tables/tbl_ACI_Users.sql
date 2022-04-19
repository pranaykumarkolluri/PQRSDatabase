CREATE TABLE [dbo].[tbl_ACI_Users] (
    [Id]               INT          IDENTITY (1, 1) NOT NULL,
    [Selected_Id]      INT          NULL,
    [ACI_Id]           INT          NULL,
    [IsGpro]           BIT          NULL,
    [TIN]              VARCHAR (10) NULL,
    [NPI]              VARCHAR (10) NULL,
    [Updated_By]       VARCHAR (50) NULL,
    [Updated_Datetime] DATETIME     NULL,
    [CMSYear]          INT          NULL,
    CONSTRAINT [PK_tbl_ACI_Users] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_tbl_ACI_Users_tbl_ACI_User_Measure_Type] FOREIGN KEY ([Selected_Id]) REFERENCES [dbo].[tbl_ACI_User_Measure_Type] ([Selected_Id]) ON DELETE CASCADE
);

