
-- =============================================
-- Author:		Raju G
-- Create date:16-01-2021
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpUpdateHitrustSiteActiveStatus]
	-- Add the parameters for the stored procedure here
	@Userid as int,
	@SiteActive bit,
	@Category varchar(20)
AS
BEGIN
	
	 IF(@Category ='WholeApplication')
	 BEGIN
		UPDATE Tbl_Hitrust_User_Manager 
		SET 
		SiteActive = @SiteActive
		,UpdatedDate =GETDATE()
		,UpdatedBy =@Userid
		
		WhERE Category= @Category
	 END
	 ELSE IF(@Category='SingleUser')
	 BEGIN 
	      IF EXISTS (SELECT 1 FROM Tbl_Hitrust_User_Manager WHERE Category=@Category AND UserId=@Userid)
		  BEGIN
		        UPDATE Tbl_Hitrust_User_Manager SET SiteActive=@SiteActive WHERE Category=@Category AND UserId=@Userid;
		  END
		  ELSE
		  BEGIN
		     
				
				INSERT INTO [dbo].[Tbl_Hitrust_User_Manager]
						   ([Category]
						   ,[UserId]
						   ,[SiteActive]
						   ,[CreatedDate]
						  )
					 VALUES
						   (@Category
						   ,@Userid
						   ,@SiteActive
						   ,GETDATE()
						 )



		  END
	 END
END

