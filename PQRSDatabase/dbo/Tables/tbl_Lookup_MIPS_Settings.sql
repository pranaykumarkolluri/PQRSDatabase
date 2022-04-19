CREATE TABLE [dbo].[tbl_Lookup_MIPS_Settings] (
    [Id]          INT           IDENTITY (1, 1) NOT NULL,
    [Set_Key]     VARCHAR (50)  NULL,
    [Value]       VARCHAR (100) NULL,
    [Description] VARCHAR (250) NULL,
    [CreatedBy]   VARCHAR (100) NULL,
    [CreatedDate] DATETIME      NULL,
    [UpdatedBy]   VARCHAR (100) NULL,
    [UpdatedDate] DATETIME      NULL,
    CONSTRAINT [PK_tbl_Lookup_MIPS_Settings] PRIMARY KEY CLUSTERED ([Id] ASC)
);

