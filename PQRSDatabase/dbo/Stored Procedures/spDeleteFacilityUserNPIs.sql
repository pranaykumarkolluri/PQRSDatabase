-- =============================================
-- Author:		hari j
-- Create date: 1-4-18
-- Description:	deleting the facility NPIS
-- =============================================
CREATE PROCEDURE [dbo].[spDeleteFacilityUserNPIs]
	-- Add the parameters for the stored procedure here
	@userID int
AS
BEGIN
	delete from [dbo].[tbl_FacilityManaged_NPI_List] where UserId=@userID
END
