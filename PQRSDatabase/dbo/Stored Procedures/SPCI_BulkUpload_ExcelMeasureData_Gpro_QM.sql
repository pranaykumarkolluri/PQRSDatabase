

-- =============================================
-- Author:		<RAJU>
-- Create date: <30-11-2018>
-- Description: used to insert bulk Gpro Excel data for CMS Submission
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_BulkUpload_ExcelMeasureData_Gpro_QM]
	-- Add the parameters for the stored procedure here
	@Cmsyear int,
	@FileId int,
	@Createdby varchar(50),
	@CreatedDate datetime,
	@tbl_CI_BulkFileUploadCmsData_Type_ForGpro tbl_CI_BulkFileUploadCmsData_Type_ForGpro READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   --  Insert statements for procedure here
	INSERT INTO [dbo].[tbl_CI_BulkFileUploadCmsData]
           ([FileId]
           ,[TIN]
           --,[Npi]
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
           ,[Createdby]
           ,[CreatedDate]
           --,[Is_MeasureDataUpdated]
           --,[Is_PerformanceCalculated]
           --,[IsRowEditedByUser]
           --,[IsValidata]
           --,[ErrorMessage]
		   ,EndtoEndReporting_old
		   ,EndtoEndReporting_new
		   )
		  select
		  @FileId,
		  LTRIM(RTRIM(TIN)) ,
	LTRIM(RTRIM(Measure_Name)) ,
	@Cmsyear,
	LTRIM(RTRIM(Total_numberof_Exams_mygroup_performed)) ,
	LTRIM(RTRIM(Number_of_Exams_Submitted_OLD)),
	LTRIM(RTRIM(Number_of_Exams_Submitted_NEW)),
	LTRIM(RTRIM(Submitted_Hundred_Percent_OLD)) ,
	LTRIM(RTRIM(Submitted_Hundred_Percent_NEW)) ,
	LTRIM(RTRIM(Selected_for_CMS_submission_OLD)) ,
	LTRIM(RTRIM(Selected_for_CMS_submission_NEW)),
	LTRIM(RTRIM(Performance_rate)) ,
	LTRIM(RTRIM(Decile)) ,
	LTRIM(RTRIM(Completeness)),
	@Createdby,
	@CreatedDate,
	LTRIM(RTRIM(EndtoEndReporting_OLD)),
	LTRIM(RTRIM(EndtoEndReporting_NEW))

	from @tbl_CI_BulkFileUploadCmsData_Type_ForGpro

	IF EXISTS(SELECT 1 FROM tbl_CI_BulkFileUploadCmsData where FileId=@FileId)
	BEGIN

	

      	UPDATE tbl_CI_BulkFileUpload_History SET Status=11  where FileId=@FileId
	END
	 
END


