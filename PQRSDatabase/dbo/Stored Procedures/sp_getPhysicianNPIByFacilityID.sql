CREATE PROCEDURE [dbo].[sp_getPhysicianNPIByFacilityID]
@NrdrFacilityid as int
as
begin
exec NRDR..sp_getPhysicianNPIByFacilityID @NrdrFacilityid
return @@rowcount
end
 
