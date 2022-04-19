CREATE TABLE [dbo].[tbl_CI_lookup_Http_Response_Status] (
    [Http_Status_Id]          INT           IDENTITY (1, 1) NOT NULL,
    [Http_Status_Code]        INT           NULL,
    [Http_Status_Description] VARCHAR (100) NULL,
    CONSTRAINT [PK_tbl_lookup_Http_Response] PRIMARY KEY CLUSTERED ([Http_Status_Id] ASC)
);

