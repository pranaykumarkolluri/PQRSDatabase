CREATE TABLE [dbo].[tbl_CI_Lookup_OptinData] (
    [OptinDataId]       INT          IDENTITY (1, 1) NOT NULL,
    [TIN]               VARCHAR (9)  NULL,
    [NPI]               VARCHAR (10) NULL,
    [CmsYear]           INT          NULL,
    [IsOptInEligible]   BIT          NULL,
    [IsOptedIn]         BIT          NULL,
    [OptInDecisionDate] DATETIME     NULL,
    [OptInReqId]        INT          NULL,
    CONSTRAINT [PK__tbl_Lookup_OptinData] PRIMARY KEY CLUSTERED ([OptinDataId] ASC)
);

