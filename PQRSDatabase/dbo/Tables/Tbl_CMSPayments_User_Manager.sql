CREATE TABLE [dbo].[Tbl_CMSPayments_User_Manager] (
    [Id]                         INT          IDENTITY (1, 1) NOT NULL,
    [Category]                   VARCHAR (20) NULL,
    [UserName]                   VARCHAR (50) NULL,
    [PaidStatus]                 BIT          NOT NULL,
    [CMSYear]                    INT          NULL,
    [CreatedDate]                DATETIME     NULL,
    [UpdatedBy]                  INT          NULL,
    [UpdatedDate]                DATETIME     NULL,
    [CMSPaymentsExceptionByPass] BIT          NULL,
    [IsDecisionMade]             BIT          NULL,
    CONSTRAINT [PK_Tbl_CMSPayments_User_Manager] PRIMARY KEY CLUSTERED ([Id] ASC)
);

