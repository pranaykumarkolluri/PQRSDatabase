CREATE TABLE [dbo].[Tbl_Hitrust_User_Manager] (
    [Id]                     INT          IDENTITY (1, 1) NOT NULL,
    [Category]               VARCHAR (20) NULL,
    [UserId]                 INT          NULL,
    [SiteActive]             BIT          NOT NULL,
    [CreatedDate]            DATETIME     NULL,
    [UpdatedBy]              INT          NULL,
    [UpdatedDate]            DATETIME     NULL,
    [HitrustExceptionByPass] BIT          NULL,
    CONSTRAINT [PK_Tbl_Hitrust_User_Manager] PRIMARY KEY CLUSTERED ([Id] ASC)
);

