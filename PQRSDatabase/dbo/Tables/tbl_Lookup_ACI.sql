CREATE TABLE [dbo].[tbl_Lookup_ACI] (
    [ACI_Id]      INT           IDENTITY (1, 1) NOT NULL,
    [Description] VARCHAR (100) NOT NULL,
    [ACICode]     VARCHAR (20)  NOT NULL,
    CONSTRAINT [PK_Tbl_lookup_AdvanceCareInformation] PRIMARY KEY CLUSTERED ([ACI_Id] ASC)
);

