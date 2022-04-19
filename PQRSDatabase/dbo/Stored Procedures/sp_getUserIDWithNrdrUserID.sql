



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_getUserIDWithNrdrUserID] 
	-- Add the parameters for the stored procedure here
	@nrdrUserID nvarchar(50) -- f5386f33-e133-421e-a373-a3a300a7ce88
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   	select UserID from tbl_Users where NRDRUserID = @nrdrUserID
  return @@rowcount;
END



