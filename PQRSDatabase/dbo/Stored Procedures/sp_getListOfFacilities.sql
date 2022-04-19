-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_getListOfFacilities] 
	-- Add the parameters for the stored procedure here
	@Nrdr_Facility_id int
AS
BEGIN
	SET NOCOUNT ON;
  
    declare @Facilities table (Facility_id int)

  insert @Facilities (Facility_id)
  exec NRDR..sp_getListOfFacilities @Nrdr_Facility_id
  
  set nocount off
  select * from @Facilities
  
  return @@rowCount;
    
    
	
END

