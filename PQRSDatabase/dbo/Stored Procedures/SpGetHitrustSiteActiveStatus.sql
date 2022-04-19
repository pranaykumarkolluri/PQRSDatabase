-- =============================================
-- Author:		Raju G
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpGetHitrustSiteActiveStatus]
	-- Add the parameters for the stored procedure here
	@UserId as int,
	@IsSingleUser bit=0
AS
BEGIN
	DECLARE @ISSTOP_STATUS BIT;
	DECLARE @IsHitrustBypass bit;
	SET @ISSTOP_STATUS=0;
	SET @IsHitrustBypass=0;
	IF EXISTS(SELECT 1 FROM Tbl_Hitrust_User_Manager  with(nolock) WHERE Category='WholeApplication' AND SiteActive=0)
	BEGIN

	    SET @ISSTOP_STATUS=1;
	END
	ELSE IF EXISTS(SELECT 1 FROM Tbl_Hitrust_User_Manager  with(nolock) WHERE Category='SingleUser' AND UserId=@UserId AND @UserId>0  AND SiteActive=0)
	BEGIN

	   SET @ISSTOP_STATUS=1;
	END
	
	IF (EXISTS(SELECT 1 FROM Tbl_Hitrust_User_Manager with(nolock) WHERE Category='WholeApplication' AND HitrustExceptionByPass=1)
	AND @IsSingleUser=0)
	BEGIN

	    SET @IsHitrustBypass=1;
		SET @ISSTOP_STATUS=0;
	END

	SELECT @ISSTOP_STATUS AS IsAppStop,@IsHitrustBypass AS IsHistrustBiPass
END
