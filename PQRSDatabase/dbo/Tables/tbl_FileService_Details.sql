CREATE TABLE [dbo].[tbl_FileService_Details] (
    [ServiceId]     INT           IDENTITY (1, 1) NOT NULL,
    [ServiceName]   VARCHAR (100) NOT NULL,
    [IpAddress]     VARCHAR (100) NULL,
    [IsActive]      BIT           CONSTRAINT [DF_tbl_FileService_Details_IsActive] DEFAULT ((0)) NOT NULL,
    [CreatedBy]     INT           NULL,
    [CreatedDate]   DATETIME      NULL,
    [UpdatedBy]     INT           NULL,
    [UpdatedDate]   DATETIME      NULL,
    [RequestsLimit] INT           CONSTRAINT [tbl_FileService_Details_RequestsLimit_con] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tbl_FileService_Details] PRIMARY KEY CLUSTERED ([ServiceId] ASC, [ServiceName] ASC)
);

