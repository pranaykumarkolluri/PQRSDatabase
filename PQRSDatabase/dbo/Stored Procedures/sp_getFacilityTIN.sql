-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_getFacilityTIN] 
	-- Add the parameters for the stored procedure here
	@FacilityUserName nvarchar(256)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		EXEC [NRDR]..[sp_getFacilityTIN] @FacilityUserName
	--select TINS from tbl_facilityTINS where FacilityId = @FacilityID
  return @@rowcount;
END

