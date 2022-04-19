CREATE TABLE [dbo].[tbl_Lookup_Measure_Type] (
    [Measure_type_Id]   INT          IDENTITY (1, 1) NOT NULL,
    [Measure_Type_code] VARCHAR (50) NULL,
    [Measure_Type]      VARCHAR (50) NULL,
    CONSTRAINT [PK_tbl_Lookup_Measure_Type] PRIMARY KEY CLUSTERED ([Measure_type_Id] ASC)
);

