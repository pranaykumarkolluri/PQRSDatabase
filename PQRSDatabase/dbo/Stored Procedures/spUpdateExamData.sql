-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
--Change#2: Hari j,May 3ed 2019
--Change2#: JIRA#694
--Change#3 : JIRA#1011
--Change#4 : JIRA#1103
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateExamData] 
	(       
		@PartnerId varchar(50),
		@PhysicianNPI as varchar(15),
		@ExamTIN as varchar(15),
		@Patient_Id varchar(500),
		@DecryptPatient_Id varchar(500),
		@Patient_Age decimal,
		@Patient_Gender varchar(50),
		@Measure_Num varchar(50),
		@Procedure_Code varchar(50),
		@IsEncrypt bit,
		@Patient_Medicare_Advantage smallint, 
		@Patient_Medicare_Beneficiary smallint,
		@Exam_Date datetime,
		@Last_Modified_Date datetime,
		@Last_Modified_By varchar(50),
		@CMS_Submission_Year int,
		@Exam_Unique_ID varchar(500),
		@DataSource_Id int,
		@File_Name varchar(50),
		@Criteria varchar(20),
		@Denom_Diag_Code varchar(50), -- --Change2#
		@Numerator_Code varchar(100)--Change#4
		)
as
BEGIN

--Set NOCOUNT ON;
DECLARE @File_ID as int;
declare @Exam_id as int
declare @Errors as varchar(250);
set @Errors = '';
set @Exam_id = 0;
Declare @recordsUpdated as int
set @recordsUpdated = 0;


				SELECT @Exam_id=Exam_Id from [dbo].[fnMIPSExamDataKeyParameters] (
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
				  /*     below code moved to function fnMIPSExamDataKeyParameters				  
							  select top 1 @Exam_id = e.Exam_Id from tbl_Exam e   with(nolock) 
							  inner join tbl_Exam_Measure_Data md   with(nolock) on md.Exam_Id = e.Exam_Id and md.CMS_Submission_Year = e.CMS_Submission_Year 
							  inner join tbl_Lookup_Measure m   with(nolock) on m.Measure_ID = md.Measure_ID and m.CMSYear = md.CMS_Submission_Year and  m.CMSYear = @CMS_Submission_Year
							  where e.CMS_Submission_Year = @CMS_Submission_Year
							  and e.Exam_TIN = LTRIM(RTRIM(@ExamTIN)) 
							  and e.Physician_NPI = LTRIM(RTRIM(@PhysicianNPI))
							  and ((e.Patient_ID = @Patient_Id )  or (e.Patient_ID = @DecryptPatient_Id ) )
							  and (md.Denominator_proc_code = @Procedure_Code)
							  and (m.Measure_num = @Measure_Num)
							  and e.Exam_Date=@Exam_Date
							   AND ISNULL(e.Exam_Unique_ID,'')=ISNULL(@Exam_Unique_ID,'')--Change3#
							  --and(isnull(md.Criteria,'NA')=isnull(@Criteria,'NA'))
							  and(isnull(md.Criteria,'NA')=case WHEN (@Criteria='' OR isnull(@Criteria,'NA')='NA') THEN isnull(md.Criteria,'NA')
																   ELSE @Criteria END )
							  and md.Denominator_Diag_code= case WHEN (m.Is_DiagCodeAsKey =1) THEN @Denom_Diag_Code
																   ELSE md.Denominator_Diag_code END --Change2#
              */
	

	  if (@Exam_id >0)
	  Begin
	  
	  SELECT @File_ID=ID from tbl_PQRS_FILE_UPLOAD_HISTORY where LTRIM(RTRIM(FILE_NAME))=LTRIM(RTRIM(@File_Name))

		update tbl_Exam set 
		Patient_Age=LTRIM(RTRIM(@Patient_Age)),
		PartnerID=LTRIM(RTRIM(@PartnerId)),
		Patient_Gender=LTRIM(RTRIM(@Patient_Gender)),
		Patient_ID=LTRIM(RTRIM(@Patient_Id)),
		IsEncrypt=LTRIM(RTRIM(@IsEncrypt)),
		Patient_Medicare_Advantage=LTRIM(RTRIM(@Patient_Medicare_Advantage)),
		Patient_Medicare_Beneficiary=LTRIM(RTRIM(@Patient_Medicare_Beneficiary)),
		Exam_Date=LTRIM(RTRIM(@Exam_Date)),
		Last_Modified_Date=LTRIM(RTRIM(@Last_Modified_Date)),
		Last_Modified_By=LTRIM(RTRIM(@Last_Modified_By)),
		CMS_Submission_Year=LTRIM(RTRIM(@CMS_Submission_Year)),
		Exam_Unique_ID=LTRIM(RTRIM(@Exam_Unique_ID)),
		DataSource_Id=LTRIM(RTRIM(@DataSource_Id)) ,
		File_ID=@File_ID		
		where Exam_Id=@Exam_id	

		set @recordsUpdated = @@ROWCOUNT		
		end
		--SET NOCOUNT OFF;
		Select @Exam_id as Exam_id,@RecordsUpdated as [RecordsUpdated], @Errors as [Errors]
		return @@rowcount;
END



