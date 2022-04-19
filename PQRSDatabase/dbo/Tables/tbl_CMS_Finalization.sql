CREATE TABLE [dbo].[tbl_CMS_Finalization] (
    [Fid]                  INT          IDENTITY (1, 1) NOT NULL,
    [isGpro]               BIT          NULL,
    [TIN]                  VARCHAR (9)  NULL,
    [NPI]                  VARCHAR (10) NULL,
    [FinalizeEmail]        VARCHAR (50) NULL,
    [isFinalize]           BIT          CONSTRAINT [DF_tbl_CMS_Finalization_isFinalize] DEFAULT ((0)) NOT NULL,
    [FinalizeAgreeTime]    DATETIME     NULL,
    [FinalizeDisagreeTime] DATETIME     NULL,
    [CreatedBy]            INT          NULL,
    [CreatedDate]          DATETIME     NULL,
    [UpdatedBy]            INT          NULL,
    [UpdatedDate]          DATETIME     NULL,
    [Finalize_Year]        INT          NULL,
    CONSTRAINT [PK_tbl_CMS_Finalization] PRIMARY KEY CLUSTERED ([Fid] ASC)
);

