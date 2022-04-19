-- =============================================
-- Author:		Hari J
-- Create date: june 3ed,2019
-- Description:	decide reset button enable or not for file upload new logic
-- =============================================
CREATE PROCEDURE SpIs_ResetButtonEnable
	-- Add the parameters for the stored procedure here
	@FileID int,
	@ReqID int
AS
BEGIN
	Declare @ISEnable bit;
	
	SET @ISEnable=0;

	if((select ISNULL(CountUpdateOn,GETDATE()) from tbl_ApiRequstedFilesList with (nolock) where FileId=@FileID and ReqId=@ReqID)<= (SELECT DateADD(mi,-5,GETDATE())))
	BEGIN
	SET @ISEnable=1;
	END

	ELSE
	BEGIN
	SET @ISEnable=0;
	END
	select  @ISEnable as IsResetBtnEnable
END
