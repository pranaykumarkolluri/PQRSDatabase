CREATE TABLE [dbo].[tbl_Lookup_Stratum] (
    [Stratum_Id]   INT           IDENTITY (1, 1) NOT NULL,
    [Measure_Num]  VARCHAR (50)  NULL,
    [Start_Age]    INT           NULL,
    [End_Age]      INT           NULL,
    [Stratum_Name] VARCHAR (250) NULL,
    [Criteria]     VARCHAR (20)  NULL,
    CONSTRAINT [PK_tbl_Lookup_Stratum_2] PRIMARY KEY CLUSTERED ([Stratum_Id] ASC)
);

