CREATE PROCEDURE [dbo].[sp_getFacilityTIN_GPRO] 
	-- Add the parameters for the stored procedure here
	@FacilityUserName as varchar(250)
AS
BEGIN

	exec [NRDR]..[sp_getFacilityTIN_GPRO] @FacilityUserName
	
END