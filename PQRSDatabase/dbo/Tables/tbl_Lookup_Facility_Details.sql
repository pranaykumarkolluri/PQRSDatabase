CREATE TABLE [dbo].[tbl_Lookup_Facility_Details] (
    [ID]           INT          IDENTITY (1, 1) NOT NULL,
    [FacilityID]   VARCHAR (50) NOT NULL,
    [FacilityName] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_tbl_Lookup_Facility_Details] PRIMARY KEY CLUSTERED ([FacilityID] ASC)
);

