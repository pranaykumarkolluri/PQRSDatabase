-- =============================================
-- Author:		HARI J
-- Create date:09-10-2018
-- Description:	used to check measure data exist for manual data entry
--Change #1:Exam_Unique_ID varchar size increased varchar(50) to varchar(500)
--Change#2: Hari j,May 3ed 2019
--Change2#: JIRA#694
--Change#3: Hari j,OCT  14th 2019
--Change3#: JIRA#741
--Change#4 : JIRA#1103
-- =============================================
 CREATE PROCEDURE [dbo].[spMeasureDataExistsForManualData] 
	(       
		@PhysicianNPI as varchar(15),
		@ExamTIN as varchar(15),
		@Patient_Id varchar(500),
		@DecryptPatient_Id varchar(500),		
		@Measure_Num varchar(50),
		@Procedure_Code varchar(50),
		@IsEncrypt bit,		
		@Exam_Date datetime,		
		@CMS_Submission_Year int,
		@Exam_Unique_ID varchar(500),   --Change #1:
		@Criteria varchar(20),
		@Denom_Diag_Code varchar(50) -- --Change2#
		,@Numerator_Code varchar(100)--Change#4
		)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

	declare @ExamId int
	/*  below code moved to function fnMIPSExamDataKeyParameters

	select top 1 @ExamId= e.Exam_Id  from tbl_Exam e   with(nolock) 
	  inner join tbl_Exam_Measure_Data md   with(nolock) on md.Exam_Id = e.Exam_Id and md.CMS_Submission_Year = e.CMS_Submission_Year 
	  inner join tbl_Lookup_Measure m   with(nolock) on m.Measure_ID = md.Measure_ID and m.CMSYear = md.CMS_Submission_Year and  m.CMSYear = @CMS_Submission_Year
	  where e.CMS_Submission_Year = @CMS_Submission_Year
	  and e.Exam_Date = @Exam_Date
	  and e.Exam_TIN = LTRIM(RTRIM(@ExamTIN)) 
	  and e.Physician_NPI = LTRIM(RTRIM(@PhysicianNPI))
	  and ((e.Patient_ID = @Patient_Id )  or (e.Patient_ID = @DecryptPatient_Id ) )
	   AND ISNULL(e.Exam_Unique_ID,'')=ISNULL(@Exam_Unique_ID,'')--Change3#
	  and (md.Denominator_proc_code = @Procedure_Code)
	  and (m.Measure_num = @Measure_Num)
	  --and(isnull(md.Criteria,'NA')=isnull(@Criteria,'NA'))
	  and(isnull(md.Criteria,'NA')=case WHEN (@Criteria='' OR isnull(@Criteria,'NA')='NA') THEN isnull(md.Criteria,'NA')
	                                       ELSE @Criteria END )
	   and md.Denominator_Diag_code= case WHEN (m.Is_DiagCodeAsKey =1) THEN @Denom_Diag_Code
	                                       ELSE md.Denominator_Diag_code END --Change2#
	  and ((e.IsEncrypt =1) or (e.IsEncrypt=0))
	  */
	SELECT @ExamId=Exam_Id from [dbo].[fnMIPSExamDataKeyParameters] (
				   @PhysicianNPI
				  ,@ExamTIN
				  ,@Patient_Id
				  ,@DecryptPatient_Id
				  ,@Measure_Num
				  ,@Procedure_Code				  
				  ,@Exam_Date
				  ,@CMS_Submission_Year
				  ,@Exam_Unique_ID
				  ,@Criteria
				  ,@Denom_Diag_Code
				  ,@Numerator_Code)--Change#4

	select isnull(@ExamId,0) as Exam_Id
    
END

