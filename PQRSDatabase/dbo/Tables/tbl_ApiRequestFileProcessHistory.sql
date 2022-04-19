CREATE TABLE [dbo].[tbl_ApiRequestFileProcessHistory] (
    [ReqId]          INT            IDENTITY (1, 1) NOT NULL,
    [Notes]          VARCHAR (5000) NULL,
    [TotalFiles]     INT            NULL,
    [StartDate]      DATETIME       NULL,
    [EndDate]        DATETIME       NULL,
    [CreatedBy]      INT            NULL,
    [Createdate]     DATETIME       NULL,
    [Process_CnstID] INT            NULL,
    [UpdatedBy]      INT            NULL,
    [UpdatedDate]    DATETIME       NULL,
    [Status_CnstID]  INT            NULL,
    [CMSYear]        INT            NULL,
    [ServiceId]      INT            NULL,
    CONSTRAINT [PK_tbl_ApiRequestFileProcessHistory] PRIMARY KEY CLUSTERED ([ReqId] ASC)
);

