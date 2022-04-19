-- =============================================
-- Author:		hari j
-- Create date: 1-4-18
-- Description:	add User FacilityTIN
-- =============================================
CREATE PROCEDURE [dbo].[spAddUserFacilityTIN_forFacility]
	-- Add the parameters for the stored procedure here
	 @tblPhysician_TIN_TYPE [tbl_Physician_TIN_TYPE] READONLY
AS
BEGIN
	
INSERT INTO [dbo].[tbl_Physician_TIN]
           ([UserID]
           ,[TIN]          
           ,[Created_Date]
           ,[Created_By]          
           ,[TIN_DESCRIPTION]
           ,[REGISTRY_NAME]
         )

		 SELECT 
           [UserID]
           ,[TIN]          
           ,[Created_Date]
           ,[Created_By]          
           ,[TIN_DESCRIPTION]
           ,[REGISTRY_NAME]           
		 FROM @tblPhysician_TIN_TYPE
	
	select  @@identity as 'Latest_Record';
	
END
