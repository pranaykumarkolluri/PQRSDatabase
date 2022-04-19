CREATE TABLE [dbo].[QA_tbl_IA_data] (
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
    [CMSYear]               INT            NULL
);

