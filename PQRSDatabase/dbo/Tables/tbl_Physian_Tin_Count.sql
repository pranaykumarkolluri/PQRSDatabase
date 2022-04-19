CREATE TABLE [dbo].[tbl_Physian_Tin_Count] (
    [ID]           INT          IDENTITY (1, 1) NOT NULL,
    [NPI]          VARCHAR (50) NOT NULL,
    [TIN]          VARCHAR (50) NOT NULL,
    [DATE_UPDATED] DATETIME     NULL,
    [CMS_Year]     INT          NOT NULL,
    [TotalCount]   INT          NULL,
    [UserName]     VARCHAR (50) NULL,
    [FirstName]    VARCHAR (50) NULL,
    [LastName]     VARCHAR (50) NULL,
    [UserId]       INT          NULL,
    CONSTRAINT [PK_tbl_Physian_Tin_Count] PRIMARY KEY CLUSTERED ([ID] ASC, [NPI] ASC, [TIN] ASC, [CMS_Year] ASC)
);

