-- =============================================
-- Author:		Pavan
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpGetCMSPaymentsActiveStatus]
	-- Add the parameters for the stored procedure here
	@UserName as varchar(50),
	@IsSingleUser bit=0,
	@CMSYear int
AS
BEGIN
	DECLARE @IsAppLevelByPass BIT;
	DECLARE @IsUserLevelBypass bit;
	SET @IsAppLevelByPass=0;
	SET @IsUserLevelBypass=0;
	IF EXISTS(SELECT 1 FROM Tbl_CMSPayments_User_Manager  with(nolock) WHERE Category='WholeApplication' AND CMSPaymentsExceptionByPass=1)
	BEGIN
	    SET @IsAppLevelByPass=1;
	END	
	IF EXISTS(SELECT 1 FROM Tbl_CMSPayments_User_Manager  with(nolock) WHERE Category='SingleUser' AND UserName = @UserName  AND CMSPaymentsExceptionByPass = 1)
	BEGIN
	    SET @IsAppLevelByPass=1;
	END	
	IF EXISTS(SELECT 1 FROM Tbl_CMSPayments_User_Manager  with(nolock) WHERE Category='SingleUser' AND UserName = @UserName AND IsDecisionMade = 1 )
	BEGIN
	    SET @IsUserLevelBypass=1;
	END
	SELECT @IsAppLevelByPass AS IsCMSPaymentsBiPass,@IsUserLevelBypass AS IsUserPaymentsBiPass
END
