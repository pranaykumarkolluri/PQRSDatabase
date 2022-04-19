
-- =============================================
-- Author:		Prashanth kumar Garlapally
-- Create date: 17-Jul-20014
-- Description:	Objective of this procedure is to trigger validation of imported Exams data
-- Step#1 validate data per table i.e exams, exam, exam_measure, exam_measure_ext

-- Jan 24, 2018 - King changed logic to validate facility id

-- Change #1:  Hari J
-- Change Date: 16-APRIL-18
-- Change Desc: Find FacilityIDs at a time and use these instead of everty time calling nrdr
-- Change #2:  Hari J
-- Change Date: 16-APRIL-18
-- Change Desc: JIRA#545
-- Change #3:  Hari J
-- Change Date: 7-July-18
-- Change Desc: For JIRA#566
-- Change #4:  Hari J
-- Change Date:17-July-18
-- Change Desc: For JIRA#565

-- Change #5:  Hari J
-- Change Date:27-sept-18
-- Change Desc: For partiallysuccessful state records not inserting in error table

-- Change #7:  Hari J
-- Change Date: 17-Jan-19
-- Change Desc: For JIRA#627
-- =============================================
CREATE PROCEDURE [dbo].[spValidateImportExams]
AS
         BEGIN
             SET NOCOUNT ON;
             DECLARE @ExamsID INT, @Transaction_ID NVARCHAR(50), @Transaction_DateTime VARCHAR(80), @Num_of_exams_Included NVARCHAR(50), @Import_Facility_ID VARCHAR(50), @PartnerId VARCHAR(80), @Appid VARCHAR(80), @Prev_Transction_ID VARCHAR(80), @RawData_Id VARCHAR(80);
             DECLARE @message VARCHAR(MAX);
             DECLARE @messageJSON VARCHAR(MAX);
             DECLARE @ParentNode VARCHAR(MAX);
             DECLARE @blnExamDataExists BIT;
             DECLARE @intExamsCount INT;
             DECLARE @intCorrectExamCount INT;
             DECLARE @intInCorrectExamCount INT;
             DECLARE @intSuccessExamCount INT;
             DECLARE @intPartialSuccessExamCount INT;
             DECLARE @intValidationFailedExamCount INT;
             DECLARE @intCorrectEXAMSCount INT;
             DECLARE @intInCorrectEXAMSCount INT;
             DECLARE @intSuccessEXAMSCount INT;
             DECLARE @intPartialSuccessEXAMSCount INT;
             DECLARE @intValidationFailedEXAMSCount INT;
             DECLARE @dteImportDate DATETIME;
             DECLARE @strImportIPAddress VARCHAR(50);
             DECLARE @No_of_Errors INT;
             DECLARE @blnKeyOk INT;
             DECLARE @x AS VARCHAR(10);

-- Change #3:
             DECLARE @intCorrectWarningExamCount INT;
             DECLARE @Correct_ExamsWith_WarningCount INT;
-- Change #4:
             DECLARE @intInCorrectExclusionExamCount INT;
             DECLARE @InCorrect_ExamsWith_ExclusionCount INT;
             IF OBJECT_ID('tempdb..#Exams') IS NOT NULL
                 DROP TABLE #Exams;
             CREATE TABLE #Exams(ExamsID INT NOT NULL);


---find distinct FacilityIDs 
-- Change #1:
             DECLARE @LoopValue INT= 0;
			 
             IF OBJECT_ID('tempdb..#FacilityIDs') IS NOT NULL
                 DROP TABLE #FacilityIDs;
             CREATE TABLE #FacilityIDs(FacilityID VARCHAR(50));

			 
             SET DATEFORMAT MDY;


-- Change #7
             DECLARE @AcceptableStatusID INT;
             SET @AcceptableStatusID =
(
    SELECT TOP 1 ID
    FROM tbl_Lookup_ImportProcess_Status
    WHERE [Description] = 'Accepted'
);
             DECLARE Cursor_Imports CURSOR
             FOR SELECT TOP 5000 ExamsID,
                                 Transaction_ID,
                                 Transaction_DateTime,
                                 Num_of_exams_Included,
                                 PartnerId,
                                 Appid,
                                 Prev_Transction_ID,
                                 facility_id,
                                 RawData_Id
                 FROM tbl_Import_Exams WITH (nolock)
                 WHERE Import_Status = 1;
             OPEN Cursor_Imports;
             FETCH NEXT FROM Cursor_Imports INTO @ExamsID, @Transaction_ID, @Transaction_DateTime, @Num_of_exams_Included, @PartnerId, @Appid, @Prev_Transction_ID, @Import_Facility_ID, @RawData_Id;
             WHILE @@FETCH_STATUS = 0
                 BEGIN
                     SET @message = '';
                     SET @messageJSON = '';
                     SET @No_of_Errors = 0;
                     SET @blnKeyOk = 1;
   --set @ParentNode = '[Parent Data-->PartnerID: ' + isnull(@PartnerId,'missing') + '\TransactionID: ' + isnull(@Transaction_ID,'missing') + '\Trans Datetime:' + isnull(@Transaction_DateTime,'missing')
                     SET @ParentNode = '';
                     SET @LoopValue = @LoopValue + 1;
					
                     IF(@LoopValue = 1)--------redefined code start
                         BEGIN
                             PRINT('loop value is 1:-----------');
                             PRINT('validate-1 started'+CONVERT(VARCHAR(24), GETDATE(), 113));
                             INSERT INTO #FacilityIDs
                                    SELECT DISTINCT
                                           ID
                                    FROM [NRDR]..facility readonly WITH (nolock)
                                    WHERE id IN
(
    SELECT DISTINCT TOP 5000 facility_id
    FROM tbl_Import_Exams
    WHERE Import_Status = 1
          AND Facility_Id IS NOT NULL
);
                         END;------redefined code end

						 
 -- print('validate-2 started'+CONVERT( VARCHAR(24), GETDATE(), 113));
                     IF(@Transaction_ID IS NULL)
                       OR (ISNULL(@Transaction_ID, '') = '')
                         BEGIN
 --   set @message = @message + 'P2001:Missing Transaction_ID' + CHAR(10) ;
                             SET @No_of_Errors = @No_of_Errors + 1;
                             SET @blnKeyOk = 0;
                         END;
                     IF(@Transaction_DateTime IS NOT NULL)
                         BEGIN
                             SET @Transaction_DateTime = LTRIM(RTRIM(@Transaction_DateTime));
                         END;
                     IF(@Transaction_DateTime IS NULL)
                       OR (ISNULL(@Transaction_DateTime, '') = '')
                         BEGIN
                             SET @message = @message+'P2011:Missing Transaction_DateTime'+CHAR(10);
                             SET @No_of_Errors = @No_of_Errors + 1;
                         END;
                         ELSE
                     IF ISDATE(@Transaction_DateTime) = 0
                         BEGIN
                             SET @message = @message+'P2012:Transaction_DateTime is not a valid date time in format mm/dd/yyyy'+CHAR(10);
                             SET @No_of_Errors = @No_of_Errors + 1;
                         END;
                         ELSE
                     IF(ISDATE(@Transaction_DateTime) = 1
                        AND (CONVERT(DATETIME, CONVERT(VARCHAR(20), @Transaction_DateTime, 101)) > GETDATE()))
                         BEGIN
                             SET @message = @message+'P2013:Transaction_DateTime ('+@Transaction_DateTime+')is future dated. Tested format mm/dd/yyyy'+CHAR(10);
                             SET @No_of_Errors = @No_of_Errors + 1;
                         END;
                     IF(@Num_of_exams_Included IS NULL)
                       OR (ISNULL(@Num_of_exams_Included, '') = '')
                         BEGIN
                             SET @message = @message+'P2021:Missing Num_of_Exam_Included'+CHAR(10);
                             SET @No_of_Errors = @No_of_Errors + 1;
                         END;
                         ELSE
                     IF dbo.IsInteger(@Num_of_exams_Included) = 0
    --Else if ISNUMERIC(@Num_of_exams_Included) = 0
                         BEGIN
                             SET @message = @message+'P2022:Entered value for Num_of_Exam_Included is not an integer'+CHAR(10);
                             SET @No_of_Errors = @No_of_Errors + 1;
                         END;
                     IF(@PartnerId IS NULL)
                       OR (ISNULL(@PartnerId, '') = '')
                         BEGIN
                             SET @message = @message+'P2031:Missing PartnerID'+CHAR(10);
                             SET @No_of_Errors = @No_of_Errors + 1;
                             SET @blnKeyOk = 0;
                         END;
                     IF(@Appid IS NULL)
                       OR (ISNULL(@Appid, '') = '')
                         BEGIN
                             SET @message = @message+'P2041:Missing AppID'+CHAR(10);
                             SET @No_of_Errors = @No_of_Errors + 1;
                             SET @blnKeyOk = 0;
                         END;
                     IF(@Import_Facility_ID IS NULL)
                       OR (ISNULL(@Import_Facility_ID, '') = '')
                         BEGIN
                             SET @message = @message+'P2051:Missing Facility_ID'+CHAR(10);
                             SET @No_of_Errors = @No_of_Errors + 1;
                         END;
                         ELSE
                     IF(dbo.IsInteger(@Import_Facility_ID) <> 1)
                         BEGIN
                             SET @message = @message+'P2052:Facility_ID: '+ISNULL(@Import_Facility_ID, '')+' not invalid it must be integer.'+CHAR(10);
                             SET @No_of_Errors = @No_of_Errors + 1;
                         END;
                         ELSE
                         BEGIN
--     print('validate-3 started'+CONVERT( VARCHAR(24), GETDATE(), 113));
/* Jan 24, 2018 - King change the logic to query NRDR directly to validate the facility id instead of
                     saving the facility ids into a table variable and then do the comparison
	*/

/*
			declare @FacilityList table (Facility_id int)      
			set @x  = '0'
			select @x = cast(ISNULL(@Import_Facility_ID,'0')  as int)
			insert @FacilityList (Facility_id)
			exec NRDR..sp_getListOfFacilities @x
			
			if not exists(select top 1 * from @FacilityList where Facility_id = @x)
	*/

                             SET @x = '0';
                             SELECT @x = CAST(ISNULL(@Import_Facility_ID, '0') AS INT);
			--if not exists(select top 1 * from [nrdr]..facility readonly with (nolock) where id = @x)
			-- Change #1:
                             IF NOT EXISTS
(
    SELECT  1 
    FROM #FacilityIDs  WITH (nolock)
    WHERE FacilityID = @x
)
                                 BEGIN
                                     SET @message = @message+'P2053:Facility_ID: '+ISNULL(@Import_Facility_ID, '')+' not listed or invalid.'+CHAR(10);
                                     SET @No_of_Errors = @No_of_Errors + 1;
                                 END;
		--   print('validate-4 started'+CONVERT( VARCHAR(24), GETDATE(), 113));	
                         END; 
    
    --transaction_id, partnerID and AppID

                     IF(ISNULL(@Transaction_ID, '') <> '')
                       AND (ISNULL(@Appid, '') <> '')
                       AND (ISNULL(@PartnerId, '') <> '')
                       AND (@blnKeyOk = 1)
                         BEGIN
                             IF EXISTS
(
    SELECT *
    FROM tbl_Import_Exams
    WHERE Transaction_ID = @Transaction_ID
          AND Appid = @Appid
          AND PartnerId = @PartnerId
          AND (ExamsID <> @ExamsID)
          AND (ExamsID < @ExamsID)
)
                                 BEGIN
                                     SET @message = @message+'P2003:Transaction_ID must be unique. Transaction_ID ['+ISNULL(@Transaction_ID, '')+'] has been submitted in a previous transaction by AppID ['+ISNULL(@Appid, '')+'],PartnerID ['+ISNULL(@PartnerId, '')+'].'+CHAR(10);
                                     SET @No_of_Errors = @No_of_Errors + 1;
                                 END;
                         END;
                     IF(ISNULL(@Transaction_ID, '') <> '')
                         BEGIN
                             SELECT @message = @message+'P2004: Transaction_ID must be unique. Transaction_ID ['+ISNULL(@Transaction_ID, '')+'] is submitted multiple times in same file.'+CHAR(10),
                                    @No_of_Errors = @No_of_Errors + 1
                             FROM tbl_Import_Exams
                             WHERE ExamsID = @ExamsID
                                   AND Transaction_ID = @Transaction_ID
                             GROUP BY ExamsID,
                                      Transaction_ID
                             HAVING COUNT(Transaction_ID) > 1;
                         END;
                     IF((@Prev_Transction_ID IS NOT NULL)
                        AND (ISNULL(@Prev_Transction_ID, '') <> ''))
                         BEGIN
                             IF NOT EXISTS
(
    SELECT TOP 1 *
    FROM tbl_Import_Exams
    WHERE Transaction_ID = @Prev_Transction_ID
          AND Appid = @Appid
          AND PartnerId = @PartnerId
)
                                 BEGIN
                                     SET @message = @message+'P2062:Invalid Prev_Transction_ID. No Transaction with Transaction_ID ['+ISNULL(@Prev_Transction_ID, '')+'] received till now.'+CHAR(10);
                                     SET @No_of_Errors = @No_of_Errors + 1;
                                 END;
                         END;
   --  print('validate-5 started'+CONVERT( VARCHAR(24), GETDATE(), 113));	  

                     SET @blnExamDataExists = 1;
                     SET @intExamsCount = 0;
                     SET @intCorrectExamCount = 0;
                     SET @intCorrectWarningExamCount = 0;
                     SET @intInCorrectExclusionExamCount = 0;
                     SET @intInCorrectExamCount = 0;
                     SET @intSuccessExamCount = 0;
                     SET @intPartialSuccessExamCount = 0;
                     SET @intValidationFailedExamCount = 0;
                     SET @Correct_ExamsWith_WarningCount = 0;
                     SET @InCorrect_ExamsWith_ExclusionCount = 0;
                     IF NOT EXISTS
(
    SELECT TOP 1 *
    FROM tbl_Import_Exam
    WHERE Import_ExamsID = @ExamsID
)
                         BEGIN
                             SET @message = @message+'P2071:Missing Exam Object Information.'+CHAR(10);
                             SET @blnExamDataExists = 0;
                             SET @No_of_Errors = @No_of_Errors + 1;
                         END;
                         ELSE
                         BEGIN
                             SELECT @intExamsCount = COUNT(*)
                             FROM tbl_Import_Exam
                             WHERE Import_ExamsID = @ExamsID;
                             IF dbo.IsInteger(@Num_of_exams_Included) = 1
                                 BEGIN
                                     IF(@intExamsCount <> CONVERT(INT, @Num_of_exams_Included))
                                         BEGIN
                                             SET @message = @message+'P2072:Data in Num_of_Exam_Included ['+@Num_of_exams_Included+'] does not match with Exams received ['+CONVERT(VARCHAR(10), @intExamsCount)+'].'+CHAR(10);
                                             SET @No_of_Errors = @No_of_Errors + 1;
                                         END;
                                 END;
				--Else
				--	Begin
				--		set @message = @message + 'P2073:Data in Num_of_Exam_Included (' + @Num_of_exams_Included + ') is not a valid integer. '  + CHAR(10) ;
				--		 set @No_of_Errors = @No_of_Errors +1;
					
				--	End

                         END;
                     IF(@blnExamDataExists = 1)
                         BEGIN
			-- Change #7
                             IF EXISTS
(
    SELECT 1
    FROM tbl_import_exam
    WHERE Import_ExamsID = @ExamsID
          AND ISDATE(Import_Exam_DateTime) = 1
          AND YEAR(Import_Exam_DateTime) IN
(
    SELECT Submission_Year
    FROM tbl_Lookup_Active_Submission_Year
    WHERE Submission_Year = YEAR(Import_Exam_DateTime)
          AND On_hold = 1
          AND IsActive = 0
)
)
                                 BEGIN
                                     PRINT('exams have future dates,put on hold');
                                     UPDATE tbl_Import_Exams
                                       SET
                                           Import_Status = @AcceptableStatusID
                                     WHERE ExamsID = @ExamsID;
                                 END;
                                 ELSE
                                 BEGIN
                                     PRINT('spValidateImportExam executed');
                                     EXEC dbo.spValidateImportExam
                                          @ExamsID,
                                          @Transaction_ID,
                                          @ParentNode,
                                          @Import_Facility_ID;	 
				--Now Check for exam error count			
				
				
				---old code---
                                     SELECT @intCorrectExamCount = CASE
                                                                       WHEN((Error_Codes_Desc IS NULL)
                                                                            AND (([Status] = 3)
                                                                                 OR ([Status] = 4)))
                                                                       THEN(@intCorrectExamCount + 1)
                                                                       ELSE @intCorrectExamCount
                                                                   END,
                                            @intInCorrectExamCount = CASE
                                                                         WHEN((Error_Codes_Desc IS NOT NULL)
                                                                              OR (([Status] <> 3)
                                                                                  AND ([Status] <> 4)))
                                                                         THEN(@intInCorrectExamCount + 1)
                                                                         ELSE @intInCorrectExamCount
                                                                     END,
                                            @intSuccessExamCount = CASE [Status]
                                                                       WHEN 3
                                                                       THEN(@intSuccessExamCount + 1)
                                                                       ELSE @intSuccessExamCount
                                                                   END,
                                            @intPartialSuccessExamCount = CASE [Status]
                                                                              WHEN 4
                                                                              THEN(@intPartialSuccessExamCount + 1)
                                                                              ELSE @intPartialSuccessExamCount
                                                                          END,
                                            @intValidationFailedExamCount = CASE [Status]
                                                                                WHEN 5
                                                                                THEN(@intValidationFailedExamCount + 1)
                                                                                ELSE @intValidationFailedExamCount
                                                                            END
                                     FROM tbl_Import_Exam
                                     WHERE Import_ExamsID = @ExamsID; 
				
					--select  @intCorrectExamCount = case  when (( Error_Codes_Desc  is null) and ( ISNULL(Correct_Measure_DataWith_WarningCount,0)  = 0) and ( ([Status]  = 3 ) or ([Status] = 4))) then (@intCorrectExamCount + 1) else @intCorrectExamCount end,
					--	@intInCorrectExamCount = case  when (( Error_Codes_Desc  is not null) OR (Incorrect_Measure_DataCount>0) AND [Status] <> 4 ) then (@intInCorrectExamCount + 1) else @intInCorrectExamCount end,
					--	@intSuccessExamCount = case [Status] when 3 then (@intSuccessExamCount + 1) else @intSuccessExamCount end,
					--	@intPartialSuccessExamCount = case [Status] when 4 then (@intPartialSuccessExamCount + 1) else @intPartialSuccessExamCount end,
					--	@intValidationFailedExamCount = case [Status] when 5 then (@intValidationFailedExamCount + 1) else @intValidationFailedExamCount end,

					--	@intInCorrectExclusionExamCount=case  when (( InCorrect_Measure_DataWith_ExclusionCount  > 0) AND ( Error_Codes_Desc  is null) ) then (@intInCorrectExclusionExamCount + 1) else @intInCorrectExclusionExamCount end,
					--	@intCorrectWarningExamCount=case  when (( Correct_Measure_DataWith_WarningCount  > 0) AND  ( ([Status]  = 3 ) or ([Status] = 4))) then (@intCorrectWarningExamCount + 1) else @intCorrectWarningExamCount end
						
						
					--	from tbl_Import_Exam where Import_ExamsID = @ExamsID 

                                 END;
                         END;
			--   print('validate-6 started'+CONVERT( VARCHAR(24), GETDATE(), 113));	
                     IF NOT EXISTS
(
    SELECT *
    FROM tbl_Import_Exams
    WHERE Import_Status = (@AcceptableStatusID)
          AND ExamsID = @ExamsID
)-- Change #7
                         BEGIN
                             PRINT('no future date exams inside:341');
                             IF(isnull(@message, '') <> '')
                                 BEGIN
			
--Declare @dteImportDate datetime
--Declare @strImportIPAddress varchar(50)

                                     SELECT @dteImportDate = ImportDate,
                                            @strImportIPAddress = isnull(ImportIPAddress, 'missing')
                                     FROM tbl_Import_Raw
                                     WHERE ImportID = @RawData_Id;
                                     SET @messageJSON = @message;
		--set @message = 'Errors In Import File exams Set from IP Address:' + @strImportIPAddress + ' ,imported time:' + convert(varchar(24),@dteImportDate)  + @ParentNode + CHAR(10) +  @message;
                                     SET @message = 'Errors In Transaction ID ['+ISNULL(@Transaction_ID, '')+']'+@ParentNode+CHAR(10)+@message;
		--@ParentNode

                                     UPDATE tbl_Import_Exams
                                       SET
                                           Error_Codes_Desc = @message,
                                           Error_Codes_JSON = @messageJSON,
                                           Correct_ExamCount = @intCorrectExamCount,
                                           InCorrect_ExamCount = @intInCorrectExamCount,
                                           Import_Status = 5,
                                           No_of_Errors = @No_of_Errors,
                                           [Correct_ExamWith_WarningCount] = @intCorrectWarningExamCount,
                                           InCorrect_ExamWith_ExclusionCount = @intInCorrectExclusionExamCount
                                     WHERE ExamsID = @ExamsID;
                                     PRINT '-------- Exam Report --------';
                                     PRINT @message;
                                     PRINT '-------- End Report --------';
		--    print('validate-7 started'+CONVERT( VARCHAR(24), GETDATE(), 113));	
                                 END;
                                 ELSE
                                 BEGIN
						--select 						 
						--  @intCorrectExamCount as 'Correct_ExamCount',
						--@intInCorrectExamCount as 'InCorrect_ExamCount',
						--case when (@intCorrectExamCount  = 0 ) then 5
						--when (@intCorrectExamCount  > 0  and @intInCorrectExamCount > 0)or (@intPartialSuccessExamCount > 0) then 4
						--when (@intCorrectExamCount  > 0 and (@intPartialSuccessExamCount > 0)) then 4
						--when (@intCorrectExamCount  > 0 and (@intPartialSuccessExamCount = 0)) then 3 
						--end as 'Import_Status'

                                     UPDATE tbl_Import_Exams
                                       SET
                                           Error_Codes_Desc = NULL,
                                           Error_Codes_JSON = NULL,
                                           Correct_ExamCount = @intCorrectExamCount,
                                           InCorrect_ExamCount = @intInCorrectExamCount
                                           ,

			--old code--- 
                                           Import_Status = CASE
                                                               WHEN(@intCorrectExamCount = 0)
                                                               THEN 5
                                                               WHEN(@intCorrectExamCount > 0
                                                                    AND @intInCorrectExamCount > 0)
                                                                   OR (@intPartialSuccessExamCount > 0)
                                                               THEN 4
                                                               WHEN(@intCorrectExamCount > 0
                                                                    AND (@intPartialSuccessExamCount > 0))
                                                               THEN 4
                                                               WHEN(@intCorrectExamCount > 0
                                                                    AND (@intPartialSuccessExamCount = 0))
                                                               THEN 3
                                                           END
                                           ,
		
			--,Import_Status =case when ((@intCorrectExamCount  = 0 ) AND (@intCorrectWarningExamCount=0) ) then 5
			--			when (((@intCorrectExamCount  > 0) OR (@intCorrectWarningExamCount>0) )  and ((@intInCorrectExamCount > 0) OR (@intInCorrectExclusionExamCount>0))or (@intPartialSuccessExamCount > 0)) then 4
			--			when (((@intCorrectExamCount  > 0) OR (@intCorrectWarningExamCount>0) )  and (@intPartialSuccessExamCount > 0)) then 4
			--			when (((@intCorrectExamCount  > 0) OR (@intCorrectWarningExamCount>0) )  and (@intPartialSuccessExamCount = 0)) then 3 
			--			end 
                                           No_of_Errors = @No_of_Errors,
                                           [Correct_ExamWith_WarningCount] = @intCorrectWarningExamCount,
                                           InCorrect_ExamWith_ExclusionCount = @intInCorrectExclusionExamCount
                                     WHERE ExamsID = @ExamsID;
                                 END;
  --   print('validate-8 started'+CONVERT( VARCHAR(24), GETDATE(), 113));	
  ----- Change #2: 
--  IF (  (select    COUNT(*)
--    from tbl_Import_Exams es left join  tbl_Import_Exam e on es.ExamsID=e.Import_ExamsID

--  left join tbl_Import_Exam_Measure_Data m on e.Import_examID=m.Import_ExamID
--  left join tbl_Import_Measure_Data_Extension md on m.Import_Exam_MeasureID=md.[Import_Measure_Data_ID]

-- where
-- es.ExamsID=@ExamsID and
-- es.Error_Codes_Desc is  null and
--e.Error_Codes_Desc is null and
-- m.Error_Codes_Desc is  null)>0)
--  BEGIN
--  Print('--no error Found for examsID ['+convert(varchar(20),@ExamsID)+']')
--  END

--  ELSE
--  BEGIN
                             INSERT INTO [dbo].[tbl_Data_Error]
([Exam_Date],
 [Exam_TIN],
 [Physician_NPI],
 [Patient_ID],
 [Patient_Age],
 [Patient_Gender],
 [Patient_Medicare_Beneficiary],
 [Patient_Medicare_Advantage],
 [Measure_Num],
 [Denominator_Proc_code],
 [Denominator_Diag_code],
 [Numerator_Response_Value],
 [Measure_Extension_Number],
 [Extension_Response_value],
 [Exam_Unique_ID],
 [Error_Msg],
 [DataSource_Id],
 [CMS_Submission_Year],
 [File_ID],
 [Transaction_ID],
 [Created_Date],
 [Created_By],
 [Warning],
 [Exclusion]
)
                                    SELECT e.Import_Exam_DateTime,
                                           e.Import_Physician_Group_TIN,
                                           e.Import_Physician_NPI,
                                           e.Import_Patient_ID,
                                           e.Import_Patient_Age,
                                           e.Import_Patient_Gender,
                                           e.Import_Patient_Medicare_Beneficiary,
                                           e.Import_Patient_Medicare_Advantage,
                                           m.Import_Measure_num,
                                           m.Import_CPT_Code,
                                           m.Import_Diagnosis_code,
                                           m.Import_Numerator_code,
                                           md.Import_Measure_Extension_Num,
                                           md.Import_Measure_Extension_Reponse_Code,
                                           e.Import_Exam_Unique_ID,
                                           ISNULL(r.Error_Codes, '')+ISNULL(es.Error_Codes_Desc, '')+' - '+ISNULL(e.Error_Codes_Desc, '')+' - '+ISNULL(m.Error_Codes_Desc, '')+' - '+ISNULL(md.Error_Codes_Desc, '') AS errorcode,
                                           1
                                           ,--,[DataSource_Id]
                                           CASE
                                               WHEN ISDATE(e.Import_Exam_DateTime) = 1
                                               THEN YEAR(e.Import_Exam_DateTime)
                                               ELSE YEAR(GETDATE())
                                           END
                                           , --[CMS_Submission_Year]  
                                           @RawData_Id
                                           ,--  ,[File_ID] 
                                           es.Transaction_ID,
                                           GETDATE(),
                                           'ImportWorkFlow'
                                           ,--[Created_By] 
                                           m.Warning_Codes_Desc,
                                           m.Exclusion_Codes_Desc
                                    FROM tbl_Import_Raw R
                                         INNER JOIN tbl_Import_Exams es ON es.RawData_Id = r.ImportID
                                         LEFT JOIN tbl_Import_Exam e ON es.ExamsID = e.Import_ExamsID
                                         LEFT JOIN tbl_Import_Exam_Measure_Data m ON e.Import_examID = m.Import_ExamID
                                         LEFT JOIN tbl_Import_Measure_Data_Extension md ON m.Import_Exam_MeasureID = md.[Import_Measure_Data_ID]
 -- where es.ExamsID=94
                                    WHERE es.ExamsID = @ExamsID
                                          AND (ISNULL(r.Error_Codes, '') <> ''
                                               OR ISNULL(es.Error_Codes_Desc, '') <> ''
                                               OR ISNULL(e.Error_Codes_Desc, '') <> ''
                                               OR ISNULL(m.Error_Codes_Desc, '') <> ''
                                               OR ISNULL(md.Error_Codes_Desc, '') <> ''
                                               OR (ISNULL(m.Exclusion_Codes_Desc, '') <> '')
                                               OR (ISNULL(m.Warning_Codes_Desc, '') <> ''))
                                          AND (e.Import_ExamsID IS NOT NULL)
                                    ORDER BY es.ExamsID;



  --END

  --   print('validate-9 started'+CONVERT( VARCHAR(24), GETDATE(), 113));	
                         END;
                     INSERT INTO #Exams
                     VALUES(@ExamsID);
                     FETCH NEXT FROM Cursor_Imports INTO @ExamsID, @Transaction_ID, @Transaction_DateTime, @Num_of_exams_Included, @PartnerId, @Appid, @Prev_Transction_ID, @Import_Facility_ID, @RawData_Id;
                 END;
             CLOSE Cursor_Imports;
             DEALLOCATE Cursor_Imports;


-- Change #7
             UPDATE dbo.tbl_Import_Raw
               SET
                   [Status] = @AcceptableStatusID,
                   Data_Status = @AcceptableStatusID
             WHERE ImportID IN(SELECT DISTINCT
                                      CONVERT(INT, RawData_Id)
                               FROM tbl_Import_Exams e
                                    INNER JOIN #Exams ON e.ExamsID = #Exams.ExamsID
                               WHERE e.Import_Status = @AcceptableStatusID);
             PRINT('validate-10 started'+CONVERT(VARCHAR(24), GETDATE(), 113));
             DECLARE Cursor_RawData CURSOR
             FOR SELECT DISTINCT
                        RawData_Id
                 FROM tbl_Import_Exams e
                      INNER JOIN #Exams ON e.ExamsID = #Exams.ExamsID
                 WHERE e.Import_Status != @AcceptableStatusID;-- Change #7

             OPEN Cursor_RawData;
             FETCH NEXT FROM Cursor_RawData INTO @RawData_Id;
             WHILE @@FETCH_STATUS = 0
                 BEGIN
                     PRINT('no future date exams :inside Cursor_RawData');	
		 --select * from tbl_Import_Raw where tbl_Import_Raw.ImportID = CONVERT(int,@RawData_Id);
                     SET @intCorrectEXAMSCount = 0;
                     SET @intInCorrectEXAMSCount = 0;
                     SET @intSuccessEXAMSCount = 0;
                     SET @intPartialSuccessEXAMSCount = 0;
                     SET @intValidationFailedEXAMSCount = 0;

		--old code--
                     SELECT @intCorrectEXAMSCount = CASE
                                                        WHEN((Error_Codes_Desc IS NULL)
                                                             AND ((Import_Status = 3)
                                                                  OR (Import_Status = 4)))
                                                        THEN(@intCorrectEXAMSCount + 1)
                                                        ELSE @intCorrectEXAMSCount
                                                    END,
                            @intInCorrectEXAMSCount = CASE
                                                          WHEN((Error_Codes_Desc IS NOT NULL)
                                                               OR ((Import_Status <> 3)
                                                                   AND (Import_Status <> 4)))
                                                          THEN(@intInCorrectEXAMSCount + 1)
                                                          ELSE @intInCorrectEXAMSCount
                                                      END,
                            @intSuccessEXAMSCount = CASE Import_Status
                                                        WHEN 3
                                                        THEN(@intSuccessEXAMSCount + 1)
                                                        ELSE @intSuccessEXAMSCount
                                                    END,
                            @intPartialSuccessEXAMSCount = CASE Import_Status
                                                               WHEN 4
                                                               THEN(@intPartialSuccessEXAMSCount + 1)
                                                               ELSE @intPartialSuccessEXAMSCount
                                                           END,
                            @intValidationFailedEXAMSCount = CASE Import_Status
                                                                 WHEN 5
                                                                 THEN(@intValidationFailedEXAMSCount + 1)
                                                                 ELSE @intValidationFailedEXAMSCount
                                                             END
                     FROM tbl_Import_Exams
                     WHERE RawData_Id = @RawData_Id; 
					
				--select  @intCorrectEXAMSCount = case  when (( Error_Codes_Desc  is null) and (ISNULL(Correct_ExamWith_WarningCount,0) = 0) and ((Import_Status  = 3)or (Import_Status  = 4)) ) then (@intCorrectEXAMSCount + 1) else @intCorrectEXAMSCount end,
				--		@intInCorrectEXAMSCount = case  when ((( Error_Codes_Desc  is not null) OR(InCorrect_ExamCount>0) AND (ISNULL(InCorrect_ExamWith_ExclusionCount,0) = 0)) AND ((Import_Status  <> 3) and (Import_Status  <> 4))) then (@intInCorrectEXAMSCount + 1) else @intInCorrectEXAMSCount end,
				--       @InCorrect_ExamsWith_ExclusionCount = case  when (( InCorrect_ExamWith_ExclusionCount>0 )   AND (Import_Status  <> 3) and (Import_Status  <> 4)) then (@InCorrect_ExamsWith_ExclusionCount + 1) else @InCorrect_ExamsWith_ExclusionCount end,
				--		@intSuccessEXAMSCount = case Import_Status when 3 then (@intSuccessEXAMSCount + 1) else @intSuccessEXAMSCount end,
				--		@intPartialSuccessEXAMSCount = case Import_Status when 4 then (@intPartialSuccessEXAMSCount + 1) else @intPartialSuccessEXAMSCount end,
				--		@intValidationFailedEXAMSCount = case Import_Status when 5 then (@intValidationFailedEXAMSCount + 1) else @intValidationFailedEXAMSCount end,
				--		@Correct_ExamsWith_WarningCount= case  when ((Correct_ExamWith_WarningCount > 0) and ((Import_Status  = 3)or (Import_Status  = 4)) ) then (@Correct_ExamsWith_WarningCount + 1) else   @Correct_ExamsWith_WarningCount end
						
				--		from tbl_Import_Exams where RawData_Id = @RawData_Id 



                     UPDATE dbo.tbl_Import_Raw
                       SET
                           [Status] = CASE
                                          WHEN((@intCorrectEXAMSCount = 0)
                                               AND (@intValidationFailedEXAMSCount > 0))
                                          THEN 9
                                          ELSE 2
                                      END,
                           Correct_ExamsCount = @intCorrectEXAMSCount,
                           InCorrect_ExamsCount = @intInCorrectEXAMSCount,
                           Data_Status = CASE
                                             WHEN(@intCorrectEXAMSCount = 0)
                                             THEN 5
                                             WHEN(@intCorrectEXAMSCount > 0
                                                  AND (@intInCorrectEXAMSCount > 0)
                                                  OR (@intPartialSuccessEXAMSCount > 0))
                                             THEN 4
                                             WHEN(@intCorrectEXAMSCount > 0
                                                  AND (@intPartialSuccessEXAMSCount > 0))
                                             THEN 4
                                             WHEN(@intCorrectEXAMSCount > 0
                                                  AND (@intPartialSuccessEXAMSCount = 0))
                                             THEN 3
                                         END,

			--Data_Status = case when (@intCorrectEXAMSCount  = 0  AND @Correct_ExamsWith_WarningCount=0) then 5
			--			when ((@intCorrectEXAMSCount  > 0  OR @Correct_ExamsWith_WarningCount>0 ) and ((@intInCorrectEXAMSCount > 0) OR( @InCorrect_ExamsWith_ExclusionCount>0)) or (@intPartialSuccessEXAMSCount > 0)) then 4
			--			when ((@intCorrectEXAMSCount  > 0  OR @Correct_ExamsWith_WarningCount>0 ) and (@intPartialSuccessEXAMSCount > 0)) then 4
			--			when ((@intCorrectEXAMSCount  > 0  OR @Correct_ExamsWith_WarningCount>0 ) and (@intPartialSuccessEXAMSCount = 0)) then 3 
			--			end,
                           Correct_ExamsWith_WarningCount = @Correct_ExamsWith_WarningCount,
                           InCorrect_ExamsWith_ExclusionCount = @InCorrect_ExamsWith_ExclusionCount
                     WHERE ImportID = CONVERT(INT, @RawData_Id);
                     FETCH NEXT FROM Cursor_RawData INTO @RawData_Id;
                 END;
             CLOSE Cursor_RawData;
             DEALLOCATE Cursor_RawData;
         END;


