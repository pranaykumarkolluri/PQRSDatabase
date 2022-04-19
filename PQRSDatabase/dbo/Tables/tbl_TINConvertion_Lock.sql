CREATE TABLE [dbo].[tbl_TINConvertion_Lock] (
    [Id]               INT          IDENTITY (1, 1) NOT NULL,
    [isGpro]           BIT          NULL,
    [TIN]              VARCHAR (9)  NULL,
    [NPI]              VARCHAR (11) NULL,
    [isIAFinalize]     BIT          CONSTRAINT [DF_tbl_TINConvertion_Lock_isIAFinalize] DEFAULT ((0)) NOT NULL,
    [isACIFinalize]    BIT          CONSTRAINT [DF_tbl_TINConvertion_Lock_isACIFinalize] DEFAULT ((0)) NOT NULL,
    [isQMFinalize]     BIT          CONSTRAINT [DF_tbl_TINConvertion_Lock_isQMFinalize] DEFAULT ((0)) NOT NULL,
    [isLock]           BIT          CONSTRAINT [DF_tbl_TINConvertion_Lock_isLock] DEFAULT ((0)) NOT NULL,
    [CMSYear]          INT          NULL,
    [CreatedBy]        INT          NULL,
    [CreatedDate]      DATETIME     NULL,
    [LastModifiedBy]   INT          NULL,
    [LastModifiedDate] DATETIME     NULL,
    CONSTRAINT [PK_tbl_TINConvertion_Lock] PRIMARY KEY CLUSTERED ([Id] ASC)
);

