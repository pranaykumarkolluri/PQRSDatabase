CREATE TABLE [dbo].[tbl_Lookup_Data_Source] (
    [DataSource_Id]          INT           NOT NULL,
    [DataSource]             VARCHAR (50)  NOT NULL,
    [DataSource_Description] VARCHAR (250) NOT NULL,
    CONSTRAINT [PK_tbl_Lookup_DataLoad_Types] PRIMARY KEY CLUSTERED ([DataSource_Id] ASC)
);

