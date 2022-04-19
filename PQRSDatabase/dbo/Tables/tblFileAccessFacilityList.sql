CREATE TABLE [dbo].[tblFileAccessFacilityList] (
    [FileId]     INT          NOT NULL,
    [FacilityId] VARCHAR (50) NOT NULL
);


GO
CREATE CLUSTERED INDEX [Idx_tblFileAccessFacilityList_fileid]
    ON [dbo].[tblFileAccessFacilityList]([FileId] ASC);


GO
CREATE NONCLUSTERED INDEX [Idx_tblFileAccessFacilityList_facilityid]
    ON [dbo].[tblFileAccessFacilityList]([FacilityId] ASC);

