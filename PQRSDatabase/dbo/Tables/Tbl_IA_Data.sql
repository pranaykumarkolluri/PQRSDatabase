CREATE TABLE [dbo].[Tbl_IA_Data] (
    [ID]                    SMALLINT       IDENTITY (1, 1) NOT NULL,
    [ActivityID]            VARCHAR (20)   NULL,
    [ActivityName]          NVARCHAR (MAX) NULL,
    [ActivityDescription]   NVARCHAR (MAX) NULL,
    [Subcategory]           SMALLINT       NOT NULL,
    [Weighing]              VARCHAR (20)   NULL,
    [CMSsuggesteddocuments] VARCHAR (MAX)  NULL,
    [ACRsuggesteddocuments] VARCHAR (MAX)  NULL,
    [Validations]           VARCHAR (MAX)  NULL,
    [Message]               VARCHAR (MAX)  NULL,
    [CMSYear]               INT            NULL,
    CONSTRAINT [PK_Tbl_IA_Data] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_Tbl_IA_Data_Tbl_lookup_ImprovementActivities] FOREIGN KEY ([Subcategory]) REFERENCES [dbo].[Tbl_lookup_ImprovementActivities] ([Id])
);

