CREATE TABLE [dbo].[tbl_CI_OptIn_Details] (
    [OptId]             INT           IDENTITY (1, 1) NOT NULL,
    [Tin]               VARCHAR (9)   NULL,
    [Npi]               VARCHAR (10)  NULL,
    [OptinYear]         INT           NULL,
    [RequestData]       VARCHAR (MAX) NULL,
    [ResponseData]      VARCHAR (MAX) NULL,
    [Method_Id]         INT           NULL,
    [Status_Code]       VARCHAR (10)  NULL,
    [ResponseId]        INT           NULL,
    [isOptInEligible]   BIT           NULL,
    [optInDecisionDate] DATETIME      NULL,
    [isOptedIn]         BIT           NULL,
    [CreatedBy]         INT           NULL,
    [CreatedDate]       DATETIME      NULL,
    [UpdatedBy]         INT           NULL,
    [UpdatedDate]       DATETIME      NULL,
    CONSTRAINT [PK_tbl_optin_details] PRIMARY KEY CLUSTERED ([OptId] ASC)
);

