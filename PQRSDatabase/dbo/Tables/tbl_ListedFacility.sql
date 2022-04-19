CREATE TABLE [dbo].[tbl_ListedFacility] (
    [ID]               INT      IDENTITY (1, 1) NOT NULL,
    [MainFacilityId]   INT      NOT NULL,
    [FacilityID]       INT      NOT NULL,
    [CreatedDate]      DATETIME NULL,
    [CreatedBy]        INT      NOT NULL,
    [LastModifiedDate] DATETIME NULL,
    [LastModifiedBy]   INT      NULL,
    CONSTRAINT [PK_tbl_ListedFacility] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tbl_ListedFacility]
    ON [dbo].[tbl_ListedFacility]([MainFacilityId] ASC, [FacilityID] ASC);

