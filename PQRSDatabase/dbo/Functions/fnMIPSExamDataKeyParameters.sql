-- =============================================
-- Author:		Hari
-- Create date: 25/10/2019
-- Description:	Used to check MIPS upload exam data unique parameters
-- =============================================
CREATE FUNCTION [dbo].[fnMIPSExamDataKeyParameters]
(	
	-- Add the parameters for the function here
@PhysicianNPI as varchar(15),
		@ExamTIN as varchar(15),
		@Patient_Id varchar(500),
		@DecryptPatient_Id varchar(500),				
		@Measure_Num varchar(50),
		@Procedure_Code varchar(50),			
		@Exam_Date datetime,		
		@CMS_Submission_Year int,
		@Exam_Unique_ID varchar(500),	--JIRA#741	
		@Criteria varchar(20),
		@Denom_Diag_Code varchar(50)--JIRA#694,
		,@Numerator_Code varchar(100) -- JIRA#1103
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
 select top 1 e.Exam_Id,md.Exam_Measure_Id from tbl_Exam e   with(nolock) 
	  inner join tbl_Exam_Measure_Data md   with(nolock) on md.Exam_Id = e.Exam_Id and md.CMS_Submission_Year = e.CMS_Submission_Year 
	  inner join tbl_Lookup_Measure m   with(nolock) on m.Measure_ID = md.Measure_ID and m.CMSYear = md.CMS_Submission_Year and  m.CMSYear = @CMS_Submission_Year
	  where e.CMS_Submission_Year = @CMS_Submission_Year
	  and e.Exam_TIN = LTRIM(RTRIM(@ExamTIN)) 
	  and e.Physician_NPI = LTRIM(RTRIM(@PhysicianNPI))
	  and ((e.Patient_ID = @Patient_Id )  or (e.Patient_ID = @DecryptPatient_Id ) )
	  and (md.Denominator_proc_code = @Procedure_Code)
	  and (m.Measure_num = @Measure_Num)
	  and e.Exam_Date=@Exam_Date
	   AND ISNULL(e.Exam_Unique_ID,'')=ISNULL(@Exam_Unique_ID,'')--JIRA#741
	  --and(isnull(md.Criteria,'NA')=isnull(@Criteria,'NA'))
	  and(isnull(md.Criteria,'NA')=case WHEN (@Criteria='' OR isnull(@Criteria,'NA')='NA') THEN isnull(md.Criteria,'NA')
	                                       ELSE @Criteria END )
	  and md.Denominator_Diag_code= case WHEN (m.Is_DiagCodeAsKey =1) THEN @Denom_Diag_Code
	                                       ELSE md.Denominator_Diag_code END --JIRA#694
	  and md.Numerator_Code= case WHEN (m.Is_NumCodeAsKey =1) THEN @Numerator_Code
	                                       ELSE md.Numerator_Code END  -- JIRA#1103
)


