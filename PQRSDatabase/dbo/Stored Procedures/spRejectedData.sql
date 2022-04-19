-- =============================================
-- Author:		Raju G
-- Create date: May 1 ,18
-- Description:	jira-545
--CHANGE#1:Hari J ,May 7th 2019--JIRA#697

-- =============================================
CREATE PROCEDURE [dbo].[spRejectedData] 
	-- Add the parameters for the stored procedure here
	@DataSourceId int,
	@CreatedBy int,
	@FileId int,
	@tbl_Data_Error_Type tbl_Data_Error_Type READONLY,
	@tbl_Data_Error_Type_New tbl_Data_Error_Type_New READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	insert into tbl_Data_Error (
		[Exam_Date] 
	,[Exam_TIN] 
	,[Physician_NPI] 
	,[Patient_ID] 
	,[Patient_Age] 
	,[Patient_Gender] 
	,[Patient_Medicare_Beneficiary] 
	,[Patient_Medicare_Advantage] 
	,[Measure_Num] 
	,[Denominator_Proc_code] 
	,[Denominator_Diag_code] 
	,[Numerator_Response_Value] 
	,[Measure_Extension_Number] 
	,[Extension_Response_value] 
	,[Exam_Unique_ID] 
	,[Error_Msg]
	,[Created_By]
	,[Created_Date]
	,DataSource_Id
	,[File_ID]
	,[CMS_Submission_Year] 
	,[Warning]  
	,[Exclusion]
	,FileRow_Num ----CHANGE#1
	)
	select 
	[Exam_Date_Time] 
	,[Physician Group Tin] 
	,[Physician NPI] 
	,[Patient ID] 
	,[Patient Age] 
	,[Patient Gender] 
	,[Patient Medicare Beneficiary] 
	,[Patient Medicare Advantage] 
	,[Measure Number] 
	,[CPT_Code] 
	,[Denominator Diagnosis Code] 
	,[Numerator Response Value] 
	,[Measure Extension Number] 
	,[Extension Response Value] 
	,[Exam_Unique_ID] 
	,Error 
	,@CreatedBy
	,GETDATE()
	,@DataSourceId
	,@FileId
	,CASE

   WHEN ISDATE(Exam_Date_Time) = 1 THEN YEAR(Exam_Date_Time)

   ELSE YEAR(GETDATE())

   END
   ,[Warning]
   ,[Exclusion]
   ,FileRow_Num

	 from @tbl_Data_Error_Type
  
END
