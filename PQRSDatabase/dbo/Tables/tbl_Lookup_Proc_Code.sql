CREATE TABLE [dbo].[tbl_Lookup_Proc_Code] (
    [Proc_Code_ID] INT          NOT NULL,
    [Measure_num]  VARCHAR (50) NULL,
    [Code]         VARCHAR (50) NULL,
    [Status]       VARCHAR (50) NULL,
    CONSTRAINT [PK_tbl_Lookup_Proc_Code] PRIMARY KEY CLUSTERED ([Proc_Code_ID] ASC)
);

