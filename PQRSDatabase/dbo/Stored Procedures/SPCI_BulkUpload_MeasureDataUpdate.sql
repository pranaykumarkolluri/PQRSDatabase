-- =============================================
-- Author:		RAJU G
-- Create date: 
-- Description:	
CREATE PROCEDURE [dbo].[SPCI_BulkUpload_MeasureDataUpdate]
	@IsGPORO bit ,
	@FileId int
	--@FacilityUserName varchar(50),
	--@CMS_Submission_Year int,
	--@isUserValidationRequired bit--user related validation required or not dicided based on this parameter

AS
BEGIN
	
					if EXISTS(	
							select * from tbl_CI_BulkFileUpload_History H 
											inner join  tbl_UserRoles UR					on H.FileId =@FileId 
																				    and H.CreatedBy=Ur.UserID
																					and UR.RoleID=1
										
							)
							BEGIN

									EXEC SPCI_BulkUpload_MeasureDataUpdate_ACRStaff @IsGPORO,@FileId
							END
							ELSE
							BEGIN

									EXEC SPCI_BulkUpload_MeasureDataUpdateForFacility @IsGPORO,@FileId
							END

											
							 
 ---STEP:Need to call performance related SP's

END
