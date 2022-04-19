CREATE TABLE [dbo].[tbl_CI_ResponseData] (
    [Respone_Id]          INT           IDENTITY (1, 1) NOT NULL,
    [Method_Id]           INT           NULL,
    [Request_Id]          INT           NULL,
    [Response_Data]       VARCHAR (MAX) NULL,
    [Status_Id]           INT           NULL,
    [CreatedDate]         DATETIME      NOT NULL,
    [CreatedBy]           VARCHAR (50)  NULL,
    [Status_Code]         INT           NULL,
    [Response_Start_Date] DATETIME      NULL,
    [Response_End_Date]   DATETIME      NULL,
    [NoofMeasures]        INT           NULL,
    [Status]              VARCHAR (50)  NULL,
    CONSTRAINT [PK_tbl_CI_ResponseData] PRIMARY KEY CLUSTERED ([Respone_Id] ASC),
    CONSTRAINT [FK_tbl_CI_ResponseData_tbl_CI_lookup_Integration_Type] FOREIGN KEY ([Method_Id]) REFERENCES [dbo].[tbl_CI_lookup_Integration_Type] ([Method_Id]),
    CONSTRAINT [FK_tbl_CI_ResponseData_tbl_CI_RequestData] FOREIGN KEY ([Request_Id]) REFERENCES [dbo].[tbl_CI_RequestData] ([Request_Id]),
    CONSTRAINT [FK_tbl_CI_ResponseData_tbl_lookup_Http_Response_Status] FOREIGN KEY ([Status_Id]) REFERENCES [dbo].[tbl_CI_lookup_Http_Response_Status] ([Http_Status_Id])
);

