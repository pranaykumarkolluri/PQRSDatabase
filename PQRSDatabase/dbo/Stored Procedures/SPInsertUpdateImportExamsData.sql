


-- =============================================
-- Author:  	SUMANTH S
-- Create date: 12 june,2019
-- Description: Web Service data  Insert/Update SP.
-- =============================================
CREATE PROCEDURE [dbo].[SPInsertUpdateImportExamsData]
-- Add the parameters for the stored procedure here
    @Transaction_ID varchar(50),
	@Transaction_DateTime varchar(50),
	@Num_of_exams_Included varchar(50),
	@PartnerId varchar(50),
	@Appid varchar(50),
	@Facility_Id varchar(50),
	@Prev_Transction_ID varchar(50),
	@RawData_Id varchar(50),
	@Import_Status int ,
@tbl_Import_NewExam_Data_Type tbl_Import_NewExam_Data_Type READONLY,
@tbl_Import_Measure_Exam_Data_Type tbl_Import_Measure_Exam_Data_Type READONLY,
@tbl_Import_Measure_Exam_Data_Exe_Type tbl_Import_Measure_Exam_Data_Exe_Type READONLY

AS
BEGIN

Declare

    @Import_Exam_DateTime varchar(50),
	@Import_Exam_Unique_ID varchar(500), 
	@Import_First_Name varchar(50),
	@Import_Last_Name varchar(50),
	@Import_Physician_NPI varchar(50),
	@Import_Physician_Group_TIN varchar(50),
	@Import_Num_of_Measures_Included varchar(50),
	@Import_Patient_Age varchar(50),
	@Import_Patient_Gender varchar(50),
	@Import_Patient_ID varchar(500),
	@Decrypt_Patient_ID varchar(500),
	@isEncrypt bit,
	@Import_Patient_Medicare_Beneficiary varchar(50),
	@Import_Patient_Medicare_Advantage varchar(50),
	@Import_Measure_num varchar(50),
	@Import_Numerator_code varchar(50),
	@Import_CPT_Code varchar(50),
	@Import_Diagnosis_code varchar(50),
	@Import_Measure_Extension_Num varchar(50),
	@Import_ExamId varchar(500),
	@Import_MeasureExamId varchar(500),
	@Import_Measure_Extension_Reponse_Code varchar(50);

	Declare @_Import_ExamId int;
	Declare @intExamid int;
    Declare	@Import_Exam_MeasureID int;

	--Step #1:tbl_Import_Exams data insertion
	INSERT INTO [dbo].[tbl_Import_Exams]
           ([Transaction_ID]
           ,[Transaction_DateTime]
           ,[Num_of_exams_Included]
           ,[PartnerId]
           ,[Appid]
           ,[Facility_Id]
           ,[Prev_Transction_ID]
           ,[RawData_Id]
           ,[Import_Status]
           --,[Error_Codes_Desc]
           --,[Correct_ExamCount]
           --,[InCorrect_ExamCount]
           --,[No_of_Errors]
           --,[Error_Codes_JSON]
           --,[Correct_ExamWith_WarningCount]
           --,[InCorrect_ExamWith_ExclusionCount]
		   )
		   Values(@Transaction_ID,
		   @Transaction_DateTime,
		   @Num_of_exams_Included,
		   @PartnerId,
		   @Appid,
		   @Facility_Id,
		   @Prev_Transction_ID,
		   @RawData_Id,
		   @Import_Status
		   )
		   SET @_Import_ExamId = SCOPE_IDENTITY();

		   --select * into tmpImportExamtype from @tbl_Import_NewExam_Data_Type

	DECLARE Cur_tbl_Import_Exam_Type CURSOR FOR

  SELECT
    
   	Import_Exam_DateTime ,
	Import_Exam_Unique_ID , 
	Import_First_Name ,
	Import_Last_Name ,
	Import_Physician_NPI ,
	Import_Physician_Group_TIN ,
	Import_Num_of_Measures_Included,
	Import_Patient_Age ,
	Import_Patient_Gender ,
	Import_Patient_ID ,
	isEncrypt ,
	Import_Patient_Medicare_Beneficiary ,
	Import_Patient_Medicare_Advantage,
	Import_ExamId,
	Decrypt_Patient_ID
	
	
      
  FROM @tbl_Import_NewExam_Data_Type

  OPEN Cur_tbl_Import_Exam_Type

    FETCH NEXT FROM Cur_tbl_Import_Exam_Type INTO 	
	@Import_Exam_DateTime ,
	@Import_Exam_Unique_ID , 
	@Import_First_Name ,
	@Import_Last_Name ,
	@Import_Physician_NPI ,
	@Import_Physician_Group_TIN ,
	@Import_Num_of_Measures_Included,
    @Import_Patient_Age ,
	@Import_Patient_Gender ,
	@Import_Patient_ID ,
	@isEncrypt ,
	@Import_Patient_Medicare_Beneficiary ,
	@Import_Patient_Medicare_Advantage,
	@Import_ExamId,
	@Decrypt_Patient_ID

  WHILE @@FETCH_STATUS = 0
  BEGIN
     
	 --Step #2:tbl_Import_Exam data insertion
		   INSERT INTO [dbo].[tbl_Import_Exam]
           ([Import_ExamsID]
           ,[Import_Physician_Group_TIN]
           ,[Import_Exam_Unique_ID]
           ,[Import_Exam_DateTime]
           ,[Import_Physician_NPI]
           ,[Import_First_Name]
           ,[Import_Last_Name]
           ,[Import_Patient_ID]
           ,[Import_Patient_Age]
           ,[Import_Patient_Gender]
           ,[Import_Patient_Medicare_Beneficiary]
           ,[Import_Patient_Medicare_Advantage]
           ,[Import_Num_of_Measures_Included]
           ,[isEncrypt]
           ,[Decrypt_Patient_ID]
		   )

		   values(
		   @_Import_ExamId,
		   @Import_Physician_Group_TIN,
		   @Import_Exam_Unique_ID,
		   @Import_Exam_DateTime,
		   @Import_Physician_NPI,
		   @Import_First_Name,
		   @Import_Last_Name,
		   @Import_Patient_ID,
		   @Import_Patient_Age,
		   @Import_Patient_Gender,
		   @Import_Patient_Medicare_Beneficiary,
           @Import_Patient_Medicare_Advantage,
		   @Import_Num_of_Measures_Included,
		   @isEncrypt,
		   @Decrypt_Patient_ID
		   )
		  SET @intExamid = SCOPE_IDENTITY();



DECLARE Cur_tbl_Import_Exam_Measure_Type CURSOR FOR

  SELECT
    Import_Measure_num ,
	Import_Numerator_code ,
	Import_CPT_Code,
	Import_Diagnosis_code,
	Import_MeasureExamId 
	  FROM @tbl_Import_Measure_Exam_Data_Type where Import_ExamId=@Import_ExamId

  OPEN Cur_tbl_Import_Exam_Measure_Type

  FETCH NEXT FROM Cur_tbl_Import_Exam_Measure_Type INTO  
    @Import_Measure_num,
	@Import_Numerator_code,
	@Import_CPT_Code,
	@Import_Diagnosis_code,
	@Import_MeasureExamId
	  WHILE @@FETCH_STATUS = 0
      BEGIN
	   --Step #3:tbl_Import_Exam_Measure_Data  insertion
	         INSERT INTO [dbo].[tbl_Import_Exam_Measure_Data]
           ([Import_ExamID]
           ,[Import_Measure_num]
           ,[Import_CPT_Code]
           ,[Import_Diagnosis_code]
           ,[Import_Numerator_code]
           --,[Error_Codes_Desc]
           --,[Correct_Data_Extensions]
           --,[InCorrect_Data_Extensions]
           --,[Status]
           --,[No_of_Errors]
           --,[Error_Codes_JSON]
           --,[Warning_Codes_Desc]
           --,[No_of_Warnings]
           --,[Exclusion_Codes_Desc]
           --,[No_of_Exclusions]
           --,[Exam_Record_Status]
		   )
		   Values(
		     @intExamid,
		     @Import_Measure_num,
           @Import_CPT_Code,
           @Import_Diagnosis_code,
           @Import_Numerator_code
		   )

		  SET @Import_Exam_MeasureID= SCOPE_IDENTITY();
		


	   DECLARE Cur_tbl_Import_Exam_Measure_Exe_Type CURSOR FOR

	     SELECT  
	  Import_Measure_Extension_Num,
	  Import_Measure_Extension_Reponse_Code
	  FROM @tbl_Import_Measure_Exam_Data_Exe_Type where Import_MeasureExamId=@Import_MeasureExamId

  OPEN Cur_tbl_Import_Exam_Measure_Exe_Type
  FETCH NEXT FROM Cur_tbl_Import_Exam_Measure_Exe_Type INTO 
    @Import_Measure_Extension_Num,
	@Import_Measure_Extension_Reponse_Code
	WHILE @@FETCH_STATUS = 0
      BEGIN
	   --Step #4:tbl_Import_Measure_Data_Extension  insertion
	  INSERT INTO [dbo].[tbl_Import_Measure_Data_Extension]
           ([Import_Measure_Data_ID]
           ,[Import_Measure_Extension_Num]
           ,[Import_Measure_Extension_Reponse_Code]
           --,[Error_Codes_Desc]
           --,[Status]
           --,[Error_Codes_JSON]
		   )

		   Values(
		   @Import_Exam_MeasureID,
		     @Import_Measure_Extension_Num,
             @Import_Measure_Extension_Reponse_Code
		   )
		     FETCH NEXT FROM Cur_tbl_Import_Exam_Measure_Exe_Type INTO 
             @Import_Measure_Extension_Num,
	         @Import_Measure_Extension_Reponse_Code
	  END

	   CLOSE Cur_tbl_Import_Exam_Measure_Exe_Type;
       DEALLOCATE Cur_tbl_Import_Exam_Measure_Exe_Type;
		  

		      FETCH NEXT FROM Cur_tbl_Import_Exam_Measure_Type INTO 
			  
			  @Import_Measure_num,
	@Import_Numerator_code,
	@Import_CPT_Code,
	@Import_Diagnosis_code,
	@Import_MeasureExamId
	   END
	   CLOSE Cur_tbl_Import_Exam_Measure_Type;
       DEALLOCATE Cur_tbl_Import_Exam_Measure_Type;
		  
		  
		    FETCH NEXT FROM Cur_tbl_Import_Exam_Type INTO   
			--@Import_ExamId, 
			@Import_Exam_DateTime ,@Import_Exam_Unique_ID , @Import_First_Name ,@Import_Last_Name ,@Import_Physician_NPI ,@Import_Physician_Group_TIN ,@Import_Num_of_Measures_Included,
    @Import_Patient_Age ,@Import_Patient_Gender ,@Import_Patient_ID ,@isEncrypt ,@Import_Patient_Medicare_Beneficiary ,@Import_Patient_Medicare_Advantage,@Import_ExamId ,@Decrypt_Patient_ID
  END
  CLOSE Cur_tbl_Import_Exam_Type;
  DEALLOCATE Cur_tbl_Import_Exam_Type;
 
END


