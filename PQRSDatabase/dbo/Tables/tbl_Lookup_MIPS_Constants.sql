CREATE TABLE [dbo].[tbl_Lookup_MIPS_Constants] (
    [Cnst_ID]     INT           IDENTITY (1, 1) NOT NULL,
    [Name]        VARCHAR (100) NULL,
    [Type]        VARCHAR (100) NULL,
    [Description] VARCHAR (500) NULL,
    CONSTRAINT [PK_tbl_Lookup_MIPS_Constants] PRIMARY KEY CLUSTERED ([Cnst_ID] ASC)
);

