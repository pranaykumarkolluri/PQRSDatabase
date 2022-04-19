
-- =============================================
-- Author:		Alane Pavan
-- Create date: Dec 12,2021
-- Description:	Used to validate bulk upload data for IA Selected Measuers and loaf errors in
--		'tbl_CI_BulkFileUploadCmsDataforIA'
-- =============================================
CREATE  PROCEDURE [dbo].[SPCI_BulkUpload_MeasureDataUpdate_IA]
	@IsGPRO bit ,
	@FileId int 

AS
BEGIN

	Declare @UserName varchar(50);
	SELECT  @UserName= UserName from tbl_Users where UserID=CONVERT(int,(select Createdby from tbl_CI_BulkFileUpload_History where FileId=@FileId))

	UPDATE M SET  M.ErrorMessage = CASE 
			WHEN NOT EXISTS(select 1 from tbl_Lookup_Active_Submission_Year where IsActive=1 and Submission_Year = M.CmsYear)
			THEN 'Reporting Year is not Active' 
			WHEN NOT EXISTS ( Select 1 from Tbl_IA_Data where ActivityID = M.Improvement_Activitiy and CMSYear = M.CmsYear ) 
			THEN 'Invalid Improvement Activity or Activity not present under current reproting year'
			WHEN (Convert(int,DATEDIFF(day, M.First_Encounter_Date, M.Last_Encounter_Date)) < 90 )
			THEN '90 Days period is not completed for this activity'
			WHEN (M.Attestation = 0 and B.IsGpro = 1)
			THEN 'To report this activity you must attest that at least 50% of NPIs in this group TIN participated in this activity.'
			ELSE null
		END 
     from [tbl_CI_BulkFileUploadCmsDataforIA] M inner join 
	       tbl_CI_BulkFileUpload_History B on  M.FileId=@FileId and M.FileId=B.FileId and IsGpro = @IsGPRO

	update [tbl_CI_BulkFileUploadCmsDataforIA] set IsValidata = 1 where ErrorMessage IS NULL and FileId =@FileId
	update [tbl_CI_BulkFileUploadCmsDataforIA] set IsValidata = 0 where ErrorMessage IS NOT NULL and FileId =@FileId

DECLARE @RECORDS_COUNT INT;
DECLARE @VALIDRECORDS_COUNT INT=0;

SELECT @RECORDS_COUNT=COUNT(*) FROM tbl_CI_BulkFileUploadCmsDataforIA WHERE FileId=@FileId
SELECT @VALIDRECORDS_COUNT=COUNT(*) FROM tbl_CI_BulkFileUploadCmsDataforIA WHERE FileId=@FileId AND IsValidata=1;


  /*
	12	ValidationSuccessful
	13	ValidationFailed
	14	PartiallySuccessful
  */
  UPDATE tbl_CI_BulkFileUpload_History
  
  SET Status = CASE WHEN @VALIDRECORDS_COUNT=0 THEN 13
					WHEN @VALIDRECORDS_COUNT=@RECORDS_COUNT THEN 12
					WHEN @VALIDRECORDS_COUNT>0 AND @VALIDRECORDS_COUNT <@RECORDS_COUNT  THEN 14
					ELSE Status
					END
   WHERE FileId=@FileId
   		print('IA Data Insertion started')

   IF EXISTS( select 1 from tbl_CI_BulkFileUpload_History where status IN (12,14) and Fileid = @FileId)
   BEGIN
		Declare @CUR_TIN varchar(9)
		Declare @CUR_NPI varchar(10)
		Declare @CUR_FileID int
		Declare @CUR_IA varchar(5000)
		Declare @CUR_CMSYear int
		Declare @SelectedId int
		DECLARE @FIRST_ENCOUNTER_DATE datetime
		DECLARE @LAST_ENCOUNTER_DATE datetime
		Declare @DataExists int = 0

		DECLARE IA_CURSOR CURSOR FOR(select distinct TIN, NPI, Improvement_Activitiy, FileId, CmsYear from tbl_CI_BulkFileUploadCmsDataforIA where FileId = @FileId and ErrorMessage is NULL )
	    OPEN IA_CURSOR
		 FETCH NEXT FROM IA_CURSOR
		 INTO @CUR_TIN,@CUR_NPI,@CUR_IA,@CUR_FileID,@CUR_CMSYear
		 WHILE @@FETCH_STATUS=0
		 BEGIN
			set @DataExists = 0
			IF(@IsGPRO = 1)
				BEGIN
					IF EXISTS ( select 1 from tbl_IA_User_Selected S join tbl_IA_Users U on U.SelectedID = S.SelectedID where S.CMSYear = @CUR_CMSYear and U.TIN = @CUR_TIN and U.NPI IS NULL and S.SelectedActivity = @CUR_IA and U.Updatedby = @UserName)
					BEGIN
						set @DataExists = 1
					END
				END
			ELSE
				BEGIN
					IF EXISTS ( select 1 from tbl_IA_User_Selected S join tbl_IA_Users U on U.SelectedID = S.SelectedID where S.CMSYear = @CUR_CMSYear and U.TIN = @CUR_TIN and U.NPI = @CUR_NPI and S.SelectedActivity = @CUR_IA and U.Updatedby = @UserName)
					BEGIN
						set @DataExists = 1
					END
				END
			IF(@DataExists = 1)
			BEGIN
			print('IA DATA EXISTS ANd UPDATE')
				IF(@IsGPRO = 1 )
					BEGIN
					select @SelectedId = S.SelectedId  from tbl_IA_User_Selected S join tbl_IA_Users U on U.SelectedID = S.SelectedID where S.CMSYear = @CUR_CMSYear and U.TIN = @CUR_TIN  and S.SelectedActivity = @CUR_IA
					select @FIRST_ENCOUNTER_DATE = First_Encounter_Date, @LAST_ENCOUNTER_DATE = Last_Encounter_Date from tbl_CI_BulkFileUploadCmsDataforIA where TIN= @CUR_TIN and NPI IS NULL and FIleid = @FileId and Improvement_Activitiy = @CUR_IA
					END
				ELSE
					BEGIN
					select @SelectedId = S.SelectedId, @FIRST_ENCOUNTER_DATE = StartDate, @LAST_ENCOUNTER_DATE = EndDate from tbl_IA_User_Selected S join tbl_IA_Users U on U.SelectedID = S.SelectedID where S.CMSYear = @CUR_CMSYear and U.TIN = @CUR_TIN and U.NPI = @CUR_NPI and S.SelectedActivity = @CUR_IA
					select @FIRST_ENCOUNTER_DATE = First_Encounter_Date, @LAST_ENCOUNTER_DATE = Last_Encounter_Date from tbl_CI_BulkFileUploadCmsDataforIA where TIN= @CUR_TIN and NPI = @CUR_NPI and FIleid = @FileId and Improvement_Activitiy = @CUR_IA
					END
				update tbl_IA_User_Selected set StartDate = @FIRST_ENCOUNTER_DATE, EndDate = @LAST_ENCOUNTER_DATE
				 where SelectedID = @SelectedId and SelectedActivity = @CUR_IA

			END
			ELSE
			BEGIN
				set @DataExists =  CASE 
									WHEN ( ( @IsGPRO = 1) AND (select count(*) from tbl_IA_Users  where TIN = @CUR_TIN and NPI is NULL and Updatedby = @UserName and CMSYear = @CUR_CMSYear ) > 0 ) 
									THEN 1 
									WHEN ( ( @IsGPRO = 0) AND (select count(*) from tbl_IA_Users  where TIN = @CUR_TIN and NPI =  @CUR_NPI and Updatedby = @UserName and CMSYear = @CUR_CMSYear ) > 0 ) 
									THEN 1 
									ELSE 0
									END
			
				IF(@DataExists = 1)
				BEGIN
				print('IA_USER Update')									
					IF(@IsGPRO = 1 )
						BEGIN
							select @SelectedId = SelectedID from tbl_IA_Users where TIN = @CUR_TIN  and Updatedby = @UserName and CMSYear = @CUR_CMSYear and NPI is NULL
						END
					ELSE
						BEGIN
							select @SelectedId = SelectedID from tbl_IA_Users where TIN = @CUR_TIN and NPI = @CUR_NPI and Updatedby = @UserName and CMSYear = @CUR_CMSYear
						END
					update tbl_IA_Users set UpdatedDateTime = GETDATE() where SelectedID = @SelectedId
				END
				ELSE
				BEGIN
				print('IA_USER insert')
					INSERT into tbl_IA_User_Selected_Categories(UpdatedBy,UpdatedDateTime,CMSYear) VALUES(@UserName,GETDATE(),@CUR_CMSYear)
					select @SelectedId = @@IDENTITY

					insert into tbl_IA_Users(SelectedID,TIn,NPI,Updatedby,UpdatedDateTime,CMSYear,IsGpro) VALUES(
										@SelectedId,
										@CUR_TIN,
										@CUR_NPI,
										@UserName,
										GETDATE(),
									@CUR_CMSYear,
									@IsGPRO)
				END
				IF(@IsGPRO = 1)
					BEGIN
						insert into tbl_IA_User_Selected(
									SelectedID,
									SelectedActivity,
									StartDate,
									EndDate,
									UpdatedBy,
									UpdatedDateTime,
									CMSYear,
									attest
								)
						select @SelectedId,
								Improvement_Activitiy,
								First_Encounter_Date,
								Last_Encounter_Date,
								@UserName,
								GETDATE(),
								CmsYear,
								Attestation from tbl_CI_BulkFileUploadCmsDataforIA
						where FileId = @FileId AND TIN = @CUR_TIN AND Improvement_Activitiy = @CUR_IA 
					END
				ELSE
					BEGIN
						insert into tbl_IA_User_Selected(
									SelectedID,
									SelectedActivity,
									StartDate,
									EndDate,
									UpdatedBy,
									UpdatedDateTime,
									CMSYear,
									attest
								)
						select @SelectedId,
								Improvement_Activitiy,
								First_Encounter_Date,
								Last_Encounter_Date,
								@UserName,
								GETDATE(),
								CmsYear,
								Attestation from tbl_CI_BulkFileUploadCmsDataforIA
						where FileId = @FileId AND TIN = @CUR_TIN AND NPI = @CUR_NPI AND Improvement_Activitiy = @CUR_IA 
					END
			END
			FETCH NEXT FROM IA_CURSOR INTO @CUR_TIN,@CUR_NPI,@CUR_IA,@CUR_FileID,@CUR_CMSYear
		 END
		 CLOSE IA_CURSOR
		 DEALLOCATE IA_CURSOR
	END
END