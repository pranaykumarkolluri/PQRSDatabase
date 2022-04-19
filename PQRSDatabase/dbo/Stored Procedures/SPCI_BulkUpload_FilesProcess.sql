-- =============================================
-- Author:		Raju G
-- Create date: June-20-2019
-- Description:	1.Processing Validation of files,
--			    2.Files data saving to selected measures tables,
--				3.Files Data Performace Caleculation 
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_BulkUpload_FilesProcess]
@CMSYear Int
AS
BEGIN
	
declare @FileId int ;
declare @ISGPRO bit;
DECLARE @IS_REQQUIRE_RUN_PERFORMANCE BIT=0;
DECLARE BATCH_FILES_QM_CUR CURSOR FOR

	 SELECT 
	 FileId
	 ,IsGpro FROM tbl_CI_BulkFileUpload_History WHERE Status in (11,12,14) and CmsYear=@CMSYear and CategoryId=1  --STATUS:11--> FILE 

	
 OPEN BATCH_FILES_QM_CUR
 FETCH NEXT FROM BATCH_FILES_QM_CUR
 INTO @FileId,@ISGPRO

 WHILE @@FETCH_STATUS=0
 BEGIN
		if EXISTS(	
							select 1 from tbl_CI_BulkFileUpload_History H 
											inner join tbl_Users U				on H.FileId =@FileId 
																				and H.CreatedBy=U.UserID
											inner join tbl_UserRoles UR			on U.UserID=UR.UserID
											inner join tbl_Lookup_Roles LR		on  UR.RoleID=LR.Role_ID and LR.Role_ID=1
							)
							BEGIN
							 print 'SPCI_BulkUpload_MeasureDataUpdateForFacility started FileId'+Convert(varchar(50),@FileId);
									EXEC SPCI_BulkUpload_MeasureDataUpdate_ACRStaff @ISGPRO,@FileId
								print 'SPCI_BulkUpload_MeasureDataUpdateForFacility ended FileId'+Convert(varchar(50),@FileId);
							END
							ELSE
							BEGIN
							      print 'SPCI_BulkUpload_MeasureDataUpdateForFacility started FileId'+Convert(varchar(50),@FileId);
									EXEC SPCI_BulkUpload_MeasureDataUpdateForFacility @ISGPRO,@FileId
								print 'SPCI_BulkUpload_MeasureDataUpdateForFacility ended FileId'+Convert(varchar(50),@FileId);
							END

     


  FETCH NEXT FROM BATCH_FILES_QM_CUR INTO @FileId,@ISGPRO
   END
 
 CLOSE BATCH_FILES_QM_CUR
 DEALLOCATE BATCH_FILES_QM_CUR

	
	DECLARE BATCH_FILES_IA_CUR CURSOR FOR
	 SELECT 
	 FileId
	 ,IsGpro FROM tbl_CI_BulkFileUpload_History WHERE Status = 11 and CmsYear=@CMSYear and CategoryId=2  --STATUS:11--> FILE 
	  OPEN BATCH_FILES_IA_CUR
		 FETCH NEXT FROM BATCH_FILES_IA_CUR
		 INTO @FileId,@ISGPRO
		 WHILE @@FETCH_STATUS=0
		 BEGIN
			 Exec SPCI_BulkUpload_MeasureDataUpdate_IA @ISGPRO, @FileID
			 FETCH NEXT FROM BATCH_FILES_IA_CUR INTO @FileId,@ISGPRO
		 END
		 CLOSE BATCH_FILES_IA_CUR
	  DEALLOCATE BATCH_FILES_IA_CUR
END

