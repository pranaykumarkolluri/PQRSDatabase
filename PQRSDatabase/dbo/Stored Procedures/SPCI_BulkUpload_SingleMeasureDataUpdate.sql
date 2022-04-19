-- =============================================
-- Author:		Harikrishna Jubburu
-- Create date: Nov 28,2018
-- Description:	Used to update the bulkupload measure data into "tbl_Physician_Selected_Measures" or "tbl_GPRO_TIN_Selected_Measures"
                       --@IsGPRO=1 for update tbl_GPRO_TIN_Selected_Measures
                         --- @IsGPRO=0-- for update tbl_Physician_Selected_Measures
-- =============================================
create PROCEDURE [dbo].[SPCI_BulkUpload_SingleMeasureDataUpdate]
	@IsGPRO bit,
	--@CmsDataId int, 
	@TIN varchar(9),
	@Npi varchar(10),
	@Measure_Name varchar(50),
	@CmsYear int,
	@Total_no_of_exams_new int,
	@HundredPercentSubmit_new bit,
	@SelectedForCms_new bit,
	@UserName varchar(50),
	@NoofExamsSubmitted int,
    @Total_no_of_exams_old int,
	@HundredPercentSubmit_old bit,
	@SelectedForCms_old bit,
	@Performac_Rate decimal(18,4),
    @Decile varchar(50),
    @Reporting_Rate decimal(18,4),
	@CreatedDate datetime,
	@FileId int,
	@Createdby varchar(50)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  --STEP#1---Check user request 

   declare @Is_MeasureDataUpdated bit;
   declare @InvalidExcelRecords int;
   declare  @ValidExcelRecords int;
   declare @IsValidata bit;


   set @IsValidata=0;
   select @InvalidExcelRecords=isnull(InvalidExcelRecords,0),@ValidExcelRecords=ISNULL(ValidExcelRecords,0) from tbl_CI_BulkFileUpload_History where FileId=@FileId

   set @Is_MeasureDataUpdated=0;
BEGIN TRY
begin Transaction

IF(@IsGPRO=1)
BEGIN
--STEP#3---check [tbl_GPRO_TIN_Selected_Measures] table contains tni,measure data 

IF((SELECT COUNT(*) from tbl_TIN_Aggregation_Year
WHERE Measure_num=ltrim(rtrim(@Measure_Name))
      AND Exam_TIN=ltrim(rtrim(@TIN))
	 AND CMS_Submission_Date =ltrim(rtrim(@CmsYear))
)>0)
BEGIN
set @IsValidata=1;
IF((SELECT COUNT(*) from [tbl_GPRO_TIN_Selected_Measures]
WHERE Measure_num=ltrim(rtrim(@Measure_Name))
      AND [TIN]=ltrim(rtrim(@TIN))
	 AND [Submission_year]=ltrim(rtrim(@CmsYear))
)>0)
BEGIN

 --STEP#4--update [tbl_GPRO_TIN_Selected_Measures] table based on excel data changes
 PRINT ('updating measure'+ISNULL(@Measure_Name,'')+', TIN :'+ISNULL(@TIN,'..'))
 
 
UPDATE [dbo].[tbl_GPRO_TIN_Selected_Measures]
   SET -- [Measure_num] = <Measure_num, varchar(50),>
     -- ,[Submission_year] = <Submission_year, int,>
    --  ,[TIN] = <TIN, varchar(50),>

      [SelectedForSubmission] = CASE 
	                           WHEN ISNULL(@SelectedForCms_new,'')<>'' THEN @SelectedForCms_new
						   ELSE [SelectedForSubmission] 
						   END
      ,[TotalCasesReviewed] = CASE 
	                           WHEN ISNULL(@Total_no_of_exams_new,'')<>'' THEN @Total_no_of_exams_new
						   ELSE [TotalCasesReviewed]
						   END
      ,[HundredPercentSubmit] = CASE 
	                           WHEN ISNULL(@HundredPercentSubmit_new,'')<>'' THEN @HundredPercentSubmit_new
						   ELSE [HundredPercentSubmit]
						   END
      ,[DateLastSelected] =  CASE 
	                           WHEN (ISNULL(@SelectedForCms_new,'')<>'' AND @SelectedForCms_new=1) THEN GETDATE()
						   ELSE [DateLastSelected]
						   END
      ,[DateLastUnSelected] =  CASE 
	                           WHEN (ISNULL(@SelectedForCms_new,'')<>'' AND @SelectedForCms_new=1) THEN GETDATE()
						   ELSE [DateLastUnSelected]
						   END
    ,[LastModifiedBy] =@UserName-- <LastModifiedBy, varchar(50),>  
      ,[UpDatedFrom] = 'BulkUploadUpdate'
 WHERE  Measure_num=ltrim(rtrim(@Measure_Name))
      AND [TIN]=ltrim(rtrim(@TIN))
	 AND [Submission_year]=ltrim(rtrim(@CmsYear))


		  set @Is_MeasureDataUpdated=1;

END

ELSE


 PRINT ('Inserting measure'+ISNULL(@Measure_Name,'')+', TIN :'+ISNULL(@TIN,'..'))
 INSERT INTO [dbo].[tbl_GPRO_TIN_Selected_Measures]
           ([Measure_num]
           ,[Submission_year]
           ,[TIN]
           ,[SelectedForSubmission]
           ,[TotalCasesReviewed]
           ,[HundredPercentSubmit]
           ,[DateLastSelected]
          -- ,[DateLastUnSelected]
          ,[LastModifiedBy]
           ,[Is_Active]
           ,[Is_90Days]
           ,[UpDatedFrom])
     VALUES
           (ltrim(rtrim(@Measure_Name))
           ,ltrim(rtrim(@CmsYear))
           ,ltrim(rtrim(@TIN))
           ,@SelectedForCms_new
           ,@Total_no_of_exams_new
           ,@HundredPercentSubmit_new
           ,GETDATE()
           --,<DateLastUnSelected, datetime,>
           ,@UserName--<LastModifiedBy, varchar(50),>
           ,1
           ,0--  <Is_90Days, bit,>
           ,'BulkUploadInsert'
		 )
	 set @Is_MeasureDataUpdated=1;
	 set @ValidExcelRecords=@ValidExcelRecords+1;
END  --Tin Agg end

ELSE
BEGIN
set @IsValidata=0;
 set @InvalidExcelRecords=@InvalidExcelRecords+1;
 set @Is_MeasureDataUpdated=0;
END
END    --Gpro end



ELSE IF(@IsGPRO=0)--non gpro related  code
BEGIN
IF((SELECT COUNT(*) from tbl_Physician_Aggregation_Year
WHERE Measure_Num=ltrim(rtrim(@Measure_Name))
      AND Exam_TIN=ltrim(rtrim(@TIN))
	 AND CMS_Submission_Year=ltrim(rtrim(@CmsYear))
	  AND Physician_NPI=ltrim(rtrim(@Npi))
	
)>0)
BEGIN
set @IsValidata=1;


IF((SELECT COUNT(*) from [tbl_Physician_Selected_Measures]
WHERE Measure_num_ID=ltrim(rtrim(@Measure_Name))
      AND [TIN]=ltrim(rtrim(@TIN))
	 AND [Submission_year]=ltrim(rtrim(@CmsYear))
	  AND NPI=ltrim(rtrim(@Npi))
	
)>0)
BEGIN


 PRINT ('Update with measure'+ISNULL(@Measure_Name,'')+',Npi :'+ISNULL(@Npi,'..')+', TIN :'+ISNULL(@TIN,'..'))

UPDATE [dbo].[tbl_Physician_Selected_Measures]
   SET
      [SelectedForSubmission] = CASE 
	                           WHEN ISNULL(@SelectedForCms_new,'')<>'' THEN @SelectedForCms_new
						   ELSE [SelectedForSubmission] 
						   END
      ,[TotalCasesReviewed] = CASE 
	                           WHEN ISNULL(@Total_no_of_exams_new,'')<>'' THEN @Total_no_of_exams_new
						   ELSE [TotalCasesReviewed]
						   END
      ,[HundredPercentSubmit] = CASE 
	                           WHEN ISNULL(@HundredPercentSubmit_new,'')<>'' THEN @HundredPercentSubmit_new
						   ELSE [HundredPercentSubmit]
						   END
      ,[DateLastSelected] =  CASE 
	                           WHEN (ISNULL(@SelectedForCms_new,'')<>'' AND @SelectedForCms_new=1) THEN GETDATE()
						   ELSE [DateLastSelected]
						   END
      ,[DateLastUnSelected] =  CASE 
	                           WHEN (ISNULL(@SelectedForCms_new,'')<>'' AND @SelectedForCms_new=1) THEN GETDATE()
						   ELSE [DateLastUnSelected]
						   END
     ,[LastModifiedBy] = @UserName 
      ,[UpDatedFrom] = 'BulkUpload'
 WHERE  Measure_num_ID=ltrim(rtrim(@Measure_Name))
      AND [TIN]=ltrim(rtrim(@TIN))
	 AND NPI=ltrim(rtrim(@Npi))
	 AND [Submission_year]=ltrim(rtrim(@CmsYear))

	 

		  set @Is_MeasureDataUpdated=1;

END

ELSE

BEGIN --INSERT
 PRINT ('Insert with measure'+ISNULL(@Measure_Name,'')+',Npi :'+ISNULL(@Npi,'..')+', TIN :'+ISNULL(@TIN,'..'))
 

INSERT INTO [dbo].[tbl_Physician_Selected_Measures]
           ([NPI]
           ,[Physician_ID]
           ,[Measure_num_ID]
           ,[Submission_year]
           ,[TIN]
           ,[SelectedForSubmission]
           ,[TotalCasesReviewed]
           ,[HundredPercentSubmit]
           ,[DateLastSelected]
         --  ,[DateLastUnSelected]
           ,[LastModifiedBy]
           ,[Is_Active]
          ,[Is_90Days]
           ,[UpDatedFrom])
     VALUES
           (ltrim(rtrim(@Npi))
		 ,(SELECT ISNULL((SELECT TOP 1 UserID from tbl_Users where NPI=@Npi),0))
		 ,ltrim(rtrim(@Measure_Name))
           ,ltrim(rtrim(@CmsYear))
           ,ltrim(rtrim(@TIN))
           ,@SelectedForCms_new
           ,@Total_no_of_exams_new
           ,@HundredPercentSubmit_new
           ,GETDATE()
           --,<DateLastUnSelected, datetime,>
          ,@UserName--<LastModifiedBy, varchar(50),>
           ,1
           ,0--<Is_90Days, bit,>
           ,'BulkUploadInsert'
		 )

		  set @Is_MeasureDataUpdated=1;

		  set @ValidExcelRecords=@ValidExcelRecords+1;
END

END--non gpro agrre if end

ELSE
BEGIN
 set @Is_MeasureDataUpdated=0;
 set @InvalidExcelRecords=@InvalidExcelRecords+1;
 set @IsValidata=0;
END

end  --NonGpro end




 --STEP#4---update [[tbl_CI_BulkFileUploadCmsData]] table of measure status





ELSE
BEGIN
PRINT ('neither GPRO nor NON GPRO Request given by user')
END


--curser CUR_TinMeasureUpdate Ended

 INSERT INTO [dbo].[tbl_CI_BulkFileUploadCmsData]
           (
		   --[FileId]
           [TIN]
           ,[Npi]
           ,[Measure_Name]
           ,[CmsYear]
           ,[NoofExamsSubmitted]
           ,[Total_no_of_exams_old]
           ,[Total_no_of_exams_new]
           ,[HundredPercentSubmit_old]
           ,[HundredPercentSubmit_new]
           ,[SelectedForCms_old]
           ,[SelectedForCms_new]
           ,[Performac_Rate]
           ,[Decile]
           ,[Reporting_Rate]
           --,[Createdby]
           ,[CreatedDate]
		   ,FileId
		   ,Createdby
           ,[Is_MeasureDataUpdated]
           ,[Is_PerformanceCalculated]
           ,[IsValidata])
           --,[ErrorMessage])
     VALUES
           (
		   --<FileId, int,>
            @TIN
           ,@Npi
           ,@Measure_Name
           ,@CmsYear
           ,@NoofExamsSubmitted
           ,@Total_no_of_exams_old
           ,@Total_no_of_exams_new
           ,@HundredPercentSubmit_old
           ,@HundredPercentSubmit_new
           ,@SelectedForCms_old
           ,@SelectedForCms_new
           ,@Performac_Rate
           ,@Decile
           ,@Reporting_Rate
           --,@Createdby
           ,@CreatedDate
		   ,@FileId
		   ,@Createdby
           ,@Is_MeasureDataUpdated
           ,0
           ,@IsValidata)
          -- ,<ErrorMessage)


		  update tbl_CI_BulkFileUpload_History set InvalidExcelRecords=@InvalidExcelRecords,
		  ValidExcelRecords=@ValidExcelRecords where FileId=@FileId

commit Transaction
END TRY
BEGIN CATCH
rollback Transaction
END CATCH
select @Is_MeasureDataUpdated as IsMeasureDataUpdated
END

