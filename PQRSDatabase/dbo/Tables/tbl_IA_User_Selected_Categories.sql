CREATE TABLE [dbo].[tbl_IA_User_Selected_Categories] (
    [ID]               INT            IDENTITY (1, 1) NOT NULL,
    [Activity]         VARCHAR (5000) NULL,
    [ActivityWeighing] VARCHAR (5000) NULL,
    [UpdatedBy]        VARCHAR (50)   NULL,
    [UpdatedDateTime]  DATETIME       NULL,
    [CMSYear]          INT            CONSTRAINT [DF_tbl_IA_User_Selected_Categories_CMSYear] DEFAULT ((2017)) NULL,
    CONSTRAINT [PK_tbl_User_Selected_Measures] PRIMARY KEY CLUSTERED ([ID] ASC)
);

