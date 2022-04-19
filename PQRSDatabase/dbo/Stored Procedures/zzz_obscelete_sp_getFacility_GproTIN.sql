
    CREATE PROCEDURE [dbo].[zzz_obscelete_sp_getFacility_GproTIN]   
	@FacilityID nvarchar(6)
	AS
	BEGIN
	SELECT distinct RT.NUMBER AS TIN, IS_GPRO FROM NRDR11X..REGISTRY_TIN RT
    where RT.FACILITY_ID = @FacilityID
	union
	select '023456789', ''
	END
