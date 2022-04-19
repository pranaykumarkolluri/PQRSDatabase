





-- =============================================
-- Author:		Prashanth kumar Garlapally
-- Create date: 19-jul-2014
-- Description:	Copy import Exam Measure Data(@Import_ExamID) into transaction Measure Data Table
--change #1:King on jan-31-18
--change #1:--added year filter for calc of @intNumeratorCodeID
--Change #2: Hari J on 07-09-2018
--Change #2:--added Criteria coulm in tbl_Exam_Measure_Data
--Change #3:--added Numerator_Code coulm in tbl_Exam_Measure_Data
-- Change #4:  Hari J
-- Change Date: April 5th, 2019
-- Change Desc:JIRA#684
-- =============================================
CREATE PROCEDURE [dbo].[spMigrateExamMeasureData] 
	-- Add the parameters for the stored procedure here
@NewExamID            INT,
@Import_ExamID        INT,
@transaction_datetime DATETIME
AS
         BEGIN
             DECLARE @Import_Exam_MeasureID INT, @Import_Measure_num VARCHAR(20), @Import_CPT_Code VARCHAR(20), @Import_Diagnosis_code VARCHAR(20), @Import_Numerator_code VARCHAR(20);
             DECLARE @intMeasureNumID INT, @intblExamMeasureId INT, @intNumeratorCodeID INT, @intNumerator_code_value INT;
             DECLARE @intSubmissionYear INT;

	   --Change #2:
             DECLARE @Criteria VARCHAR(50);
	   -- Change #4
             DECLARE @CPT_CODE_CRITERIA VARCHAR(30);
             DECLARE @NUM_CODE_CRITERIA VARCHAR(30);
  
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.


             SET NOCOUNT ON; 

	    -- Change #4:
             DECLARE @CurrentActive_Year INT;
             SELECT TOP 1 @CurrentActive_Year = Submission_Year
             FROM tbl_Lookup_Active_Submission_Year
             WHERE IsActive = 1;
             DECLARE @IsAcceptableDateRange BIT;
             DECLARE Cursor_MigrateExamMeasureData CURSOR
             FOR SELECT [Import_Exam_MeasureID],
                        [Import_Measure_num],
                        [Import_CPT_Code],
                        [Import_Diagnosis_code],
                        [Import_Numerator_code]
                 FROM [dbo].[tbl_Import_Exam_Measure_Data]
                 WHERE Import_ExamID = @Import_ExamID
                       AND [tbl_Import_Exam_Measure_Data].[Status] = 3;
             OPEN Cursor_MigrateExamMeasureData;
             FETCH NEXT FROM Cursor_MigrateExamMeasureData INTO @Import_Exam_MeasureID, @Import_Measure_num, @Import_CPT_Code, @Import_Diagnosis_code, @Import_Numerator_code;
             WHILE @@FETCH_STATUS = 0
                 BEGIN
                     SET @intMeasureNumID = 0;
                     SET @intNumeratorCodeID = 0;
                     SET @intNumerator_code_value = 0;
                     SELECT @intSubmissionYear = YEAR(GETDATE());
                     SET @Criteria = 'NA';
                     SET @CPT_CODE_CRITERIA = '';
                     SET @NUM_CODE_CRITERIA = '';
                     SET @IsAcceptableDateRange = 0;
                     SELECT @IsAcceptableDateRange = IsAcceptableDateRange
                     FROM tbl_Lookup_Measure
                     WHERE Measure_num = @Import_Measure_num
                           AND CMSYear = @CurrentActive_Year;
                     IF(@IsAcceptableDateRange = 1)
                         BEGIN
                             SET @intSubmissionYear = @CurrentActive_Year;
                             SELECT @CPT_CODE_CRITERIA = Proc_Criteria
                             FROM tbl_lookup_Denominator_Proc_Code
                             WHERE Measure_num = @Import_Measure_num
                                   AND CMSYear = @CurrentActive_Year
                                   AND Proc_code = @Import_CPT_Code;
                         END;
                         ELSE
                         BEGIN
		                -- Get cms Submission year from record
                             SELECT @intSubmissionYear = YEAR(ISNULL(Import_Exam_DateTime, GETDATE()))
                             FROM tbl_Import_Exam
                             WHERE Import_examID = @Import_ExamID;
                         END;		   



               
				-- Now Get proper measure Id based on "Measure number" and "CMS Year"
                     SELECT @intMeasureNumID = Measure_ID
                     FROM tbl_Lookup_Measure
                     WHERE Measure_num = @Import_Measure_num
                           AND CMSYear = @intSubmissionYear;

/* King Lo
The below query does not return the correct data; it is assuming the num_code_id and numerator_response_value are the same for any cmsyear.
The incorrect numerator_response_value will result in incorrect performance rate calculation done by the spReCalculatePerfomanceRateForYear stored proc
as it will pick up the wrong performance_met, exclusion etc from the tbl_lookup_numerator_code
*/

/* SELECT TOP 1
                        @intNumeratorCodeID = num_code_id ,
                        @intNumerator_code_value = Numerator_response_Value
                FROM    tbl_lookup_Numerator_Code
                WHERE   Numerator_Code = @Import_Numerator_code
                        AND ( Measure_Num = @Import_Measure_num
                              OR Measure_ID = @intMeasureNumID
                            )
					    */

/*  Suggested fixes for the above query */

/*
                SELECT 
                        @intNumeratorCodeID = num_code_id ,
                        @intNumerator_code_value = Numerator_response_Value
                FROM    tbl_lookup_Numerator_Code
                WHERE   Numerator_Code = @Import_Numerator_code
                        AND Measure_ID = @intMeasureNumID;

*/

/* alternatively, we can do this */

/*
                SELECT 
                        @intNumeratorCodeID = num_code_id ,
                        @intNumerator_code_value = Numerator_response_Value
                FROM    tbl_lookup_Numerator_Code
                WHERE   Numerator_Code = @Import_Numerator_code
                        AND Measure_Num = @Import_Measure_num
						AND CMSYear  = @intSubmissionYear;

*/

--change #1:
                     SELECT @intNumeratorCodeID = num_code_id,
                            @intNumerator_code_value = Numerator_response_Value,
                            @NUM_CODE_CRITERIA = ISNULL(Criteria, 'NA')
                     FROM tbl_lookup_Numerator_Code
                     WHERE Numerator_Code = @Import_Numerator_code
                           AND Measure_Num = @Import_Measure_num
                           AND CMSYear = @intSubmissionYear;
                     INSERT INTO tbl_Exam_Measure_Data
([Exam_Id],
 [Measure_ID],
 [Denominator_proc_code],
 [Denominator_Diag_code],
 [Numerator_response_value],
 [Status],
 Created_Date,
 Created_By,
 Last_Mod_Date,
 Last_Mod_By,
 CMS_Submission_Year,
 Criteria,
 Numerator_Code                 --change# 3
					 --CPTCode_Criteria
)
                            SELECT @NewExamID,
                                   @intMeasureNumID,
                                   @Import_CPT_Code,
                                   @Import_Diagnosis_code,
                                   @intNumerator_code_value,
                                   2,
                                   @transaction_datetime,
                                   'ImportWorkFlow',
                                   GETDATE(),
                                   'ImportWorkFlow',
                                   @intSubmissionYear,
						        --@Criteria,
                                   @NUM_CODE_CRITERIA,
                                   @Import_Numerator_code;           --change# 3
								 --@CPT_CODE_CRITERIA
						  --CASE WHEN ((@CPT_CODE_CRITERIA IS NULL) OR @CPT_CODE_CRITERIA='' OR @CPT_CODE_CRITERIA='NA' ) THEN @NUM_CODE_CRITERIA
						  --      ELSE @CPT_CODE_CRITERIA END, 
						 

      --select @NewExamID, @intMeasureNumID,@Import_CPT_Code,@Import_Diagnosis_code,@intNumeratorCodeID,2, @transaction_datetime,'ImportWorkFlow',GETDATE(),'ImportWorkFlow'

                     SET @intblExamMeasureId = @@IDENTITY;

	-- now use @Import_Exam_MeasureID,@intblExamMeasureId transfer exam extension data.
                 /*    EXEC spMigrateExamMeasureDataExtension
                          @intblExamMeasureId,
                          @Import_Exam_MeasureID;*/
	
	-- Now update tbl_Import_Exam_Measure_Data to 
                     UPDATE tbl_Import_Exam_Measure_Data
                       SET
                           [Status] = 6
	--where Import_ExamID = @Import_ExamID
                     WHERE Import_Exam_MeasureID = @Import_Exam_MeasureID;
                     FETCH NEXT FROM Cursor_MigrateExamMeasureData INTO @Import_Exam_MeasureID, @Import_Measure_num, @Import_CPT_Code, @Import_Diagnosis_code, @Import_Numerator_code;
                 END;
             CLOSE Cursor_MigrateExamMeasureData;
             DEALLOCATE Cursor_MigrateExamMeasureData;
         END;

