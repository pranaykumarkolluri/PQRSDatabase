-- =============================================
-- Author:		hari j
-- Create date: 1-4-18
-- Description:	add Facility User NPIs
-- =============================================
CREATE PROCEDURE [dbo].[spAddFacilityUserNPIsFromNRDR]
	-- Add the parameters for the stored procedure here
	 @tblFacilityManagedNPIList_TYPE [tbl_FacilityManaged_NPI_List_TYPE] READONLY
AS
BEGIN
	
INSERT INTO [dbo].[tbl_FacilityManaged_NPI_List]
           ([UserId]
           ,[PhysicianNPI]
           ,[FacilityID]
           ,[Created_Date]
           ,[Created_by]
           ,[Last_Modified_date]
           ,[Last_Modified_by])
		 SELECT 
           [UserId]
           ,[PhysicianNPI]
           ,[FacilityID]
           ,[Created_Date]
           ,[Created_by]
           ,[Last_Modified_date]
           ,[Last_Modified_by]           
		 FROM @tblFacilityManagedNPIList_TYPE
	
	
	select @@ROWCOUNT as 'Total_Updated'
END
