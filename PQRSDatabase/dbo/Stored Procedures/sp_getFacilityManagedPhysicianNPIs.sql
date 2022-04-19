

 
CREATE PROCEDURE [dbo].[sp_getFacilityManagedPhysicianNPIs]   
	@facilityUserName varchar(50)
AS
BEGIN


--exec NRDR..sp_getFacilityManagedPhysicianNPIs @facilityUserName
exec NRDR..sp_getFacilityManagedPhysicianNPIs @facilityUserName


END






