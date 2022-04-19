-- =============================================
-- Author:		hari j
-- Create date: 1-4-18
-- Description:	deleting the physician user tins
-- =============================================
CREATE PROCEDURE spDeletePhysicianUserTINs
	-- Add the parameters for the stored procedure here
	@userID int
AS
BEGIN
	delete from [dbo].[tbl_Physician_TIN] where UserID=@userID
END
