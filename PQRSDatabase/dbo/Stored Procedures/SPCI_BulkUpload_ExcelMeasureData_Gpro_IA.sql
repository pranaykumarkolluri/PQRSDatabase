

-- =============================================
-- Author:		<PAVAN>
-- Create date: <01-12-2021>
-- Description: used to insert IA bulk Excel data for CMS Submission
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_BulkUpload_ExcelMeasureData_Gpro_IA]
	-- Add the parameters for the stored procedure here
	@Cmsyear int,
	@FileId int,
	@Createdby varchar(50),
	@CreatedDate datetime,
	@UserRole int,
	@tbl_CI_BulkFileUploadCmsData_Type_ForGpro_IA tbl_CI_BulkFileUploadCmsData_Type_ForGpro_IA READONLY
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   --  Insert statements for procedure here
	INSERT INTO [dbo].[tbl_CI_BulkFileUploadCmsDataforIA]
           ([FileId]
           ,[TIN]
           --,[Npi]
           ,[CmsYear]
           ,[Improvement_Activitiy]
		  ,[Attestation]
		  ,[Createdby]
		  ,[CreatedDate]
		  ,[First_Encounter_Date]
		  ,[Last_Encounter_Date]
		  ,[IsValidata]
		   )
		  select
		  @FileId,
		  LTRIM(RTRIM(TIN)) ,
	Reporting_Year,
	LTRIM(RTRIM([Improvement_Activitiy])) ,
	CASE WHEN (UPPER(Attestation) ='YES') OR (UPPER(Attestation) ='Y') OR (Attestation ='1')  THEN 1
		 ELSE 0
		 END
	as Attestation,
	@Createdby,
	@CreatedDate,
	[First_Encounter_Date],
	[Last_Encounter_Date],
	NULL

	from @tbl_CI_BulkFileUploadCmsData_Type_ForGpro_IA

	Exec SPCI_BulkUpload_PREValidation_For_IA 1, @FileId


END


