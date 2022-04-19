



-- =============================================
--  Author:		Prashanth kumar Garlapally
-- Create date: 17-jul-2014
-- Description:	
-- Change #1 Author:	 Yarannaidu
-- Change #1 Create date: 31-Jan-2017
-- Change #1 Description:	having count > 0

-- Change #2 Author:	 Yarannaidu
-- Change #2 Create date: 31-Jan-2017
-- Change #2 Description:	@No_of_Errors

-- Change #3 Author:	 Yarannaidu
-- Change #3 Create date: 24-May-2017
-- Change #3 Description: Age_Restriction

-- Change #4 Author:	 Hari Jubburu
-- Change #4 Create date: 24-Feb-2018
-- Change #4 Description:Jira#471

-- Change #5:  Hari J
-- Change Date: 25-May-18
-- Change Desc: add logic for Gender Restriction logic for measure number
-- Change #6:  Hari J
-- Change Date: 28-May-18
-- Change Desc: add logic for acceptable date range logic for measure number
-- Change #7:  Hari J
-- Change Date: 30-May-18
-- Change Desc: add logic for Gender Restriction logic for CPT code

-- Change #8:  Hari J
-- Change Date: 22-June-18
-- Change Desc: add logic for Denominator_Exclusion for tbl_Lookup_Denominator_Diag_Code

-- Change #9:  Hari J
-- Change Date: 22-June-18
-- Change Desc: add logic for Warning Massages for Numirator responce Code .JIRA#566

-- Change #10:  Hari J
-- Change Date: 10-July-18
-- Change Desc: add logic for CPT_Code and Denom_exclusion for tbl_Lookup_Denominator_Proc_Code logic.JIRA#548
--               In this logic the Change #7: was overwritten
-- Change #11:  Hari J
-- Change Date: 16-July-18
-- Change Desc: add Denom_exclusion related errors in superate column is [Exclusion_Codes_Desc] IN  [tbl_Import_Exam_Measure_Data] FOR logic.JIRA#565
--               In this logic the Change #8: was overwritten
-- Change #12:  Hari J
-- Change Date: 07-AUG-18
-- Change Desc: add logic for if measure number empty .fill using cpt and num_code

-- Change #13:  Hari J
-- Change Date: 07-SEPT-18
-- Change Desc: add logic for Measue 226. Criteria colum added

-- Change #14:  Hari J
-- Change Date: 27-SEPT-18
-- Change Desc: add logic for PQRS-595 --- Remove the code for duplicate measure validation and checking at migration time

-- Change #15:  Hari J
-- Change Date: 27-SEPT-18
-- Change Desc: not required to display warning even if record is invalid

-- Change #16:  Hari J
-- Change Date: Feb 5th, 2019
-- Change Desc:instead of checking  ForCMSSubmission we need to check  Allow_Portal_Submit == true

-- Change #17:  Hari J
-- Change Date: April 5th, 2019
-- Change Desc:JIRA#684

-- Change #18:  Hari J
-- Change Date: Aug 22nd, 2019
-- Change Desc:JIRA#722
-- Change #19:  Hari J
-- Change Date: Sept 11, 2020
-- Change Desc:JIRA#812

--Change #20

-- Change Desc:JIRA#806
-- =============================================
Create PROCEDURE [dbo].[spValidateImportExamMeasureData_BYTwoActiveYears] @ExamID     INT          = 0,
                                                        @ParentNode VARCHAR(MAX) = ''
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;
             DECLARE @Import_Exam_MeasureID INT, @Import_ExamID INT, @Import_Measure_num VARCHAR(50), @Import_CPT_Code VARCHAR(50), @Import_Diagnosis_code VARCHAR(50), @Import_Numerator_code VARCHAR(50);
             DECLARE @message VARCHAR(MAX);
             DECLARE @messageJSON VARCHAR(MAX);
             DECLARE @iParentNode VARCHAR(MAX);
             DECLARE @intMeasuresDataExtCount INT;
             DECLARE @blnMeasureDataExtExists BIT;
             DECLARE @intCorrectMeasureExtCount INT;
             DECLARE @intInCorrectMeasureExtCount INT;
             DECLARE @intLocalMeasureID INT, @intDiagCodeMandatory BIT;
             DECLARE @validCPTCode VARCHAR(30);
             DECLARE @validDiagCode VARCHAR(30);
             DECLARE @mandatoryDiagCode INT;
             DECLARE @validNumeratorCode VARCHAR(30);
             DECLARE @No_of_Errors INT;
             DECLARE @intLookupMeasureAge INT;
             DECLARE @intReceivedMeasureAge INT;
             DECLARE @dteExamDate AS DATETIME;
             DECLARE @intExamYear AS INT;

		--<change # 2017>
             DECLARE @strTin VARCHAR(20);
             DECLARE @strNPI AS VARCHAR(20);
             DECLARE @strExamUniqueID AS VARCHAR(500);
             DECLARE @strPatientID AS VARCHAR(50);
		

		--</change #2017>


             DECLARE @ImportGender VARCHAR(5);
             DECLARE @CPT_CODE_Gender_Restriction VARCHAR(5);
             DECLARE @Gender_Restriction VARCHAR(5);
             DECLARE @IsAcceptableDateRange BIT;
             DECLARE @Denominator_Exclusion BIT;

		--
             DECLARE @CPT_CODE_Denom_Exclusion BIT;

		--
             DECLARE @Warningmessage VARCHAR(MAX);
             DECLARE @No_of_Warnings INT;
             DECLARE @Exclusionmessage VARCHAR(MAX);
             DECLARE @No_of_Exclusion INT;
		    -- Change #12:
             DECLARE @MeasureNumList_tbl TABLE(Measure_num VARCHAR(50));
             DECLARE @MeasureListCount INT;
             DECLARE @ConcatMeasureNumListString VARCHAR(4000);

		    -- Change #13:
             DECLARE @Criteria VARCHAR(50);

		    ---- Change #15: 
             DECLARE @ISValidMeasureRecord BIT;

		    -- Change #17:
             DECLARE @CurrentActive_Year INT;
             DECLARE @CPT_CODE_CRITERIA VARCHAR(30);
             DECLARE @CRITERIA1 VARCHAR(20)= 'CRITERIA1';
             DECLARE @CRITERIA2 VARCHAR(20)= 'CRITERIA2';
             --SELECT TOP 1 @CurrentActive_Year = Submission_Year
             --FROM tbl_Lookup_Active_Submission_Year
             --WHERE IsActive = 1;


---



             DECLARE Cursor_Imp_Mes_Data CURSOR
             FOR SELECT m.Import_Exam_MeasureID,
                        m.Import_ExamID,
                        m.Import_Measure_num,
                        m.Import_CPT_Code,
                        m.Import_Diagnosis_code,
                        m.Import_Numerator_code
	    --,e.Import_Patient_Gender,
     --   e.Import_Exam_DateTime

                 FROM tbl_Import_Exam_Measure_Data m 
	   --inner join  tbl_Import_Exam e on m.Import_ExamID =e.Import_examID 
                 WHERE m.Import_ExamID = @ExamID;
             OPEN Cursor_Imp_Mes_Data;
             FETCH NEXT FROM Cursor_Imp_Mes_Data INTO @Import_Exam_MeasureID, @Import_ExamID, @Import_Measure_num, @Import_CPT_Code, @Import_Diagnosis_code, @Import_Numerator_code;
             WHILE @@FETCH_STATUS = 0
                 BEGIN
                     SET @message = '';
                     SET @Warningmessage = '';
                     SET @No_of_Errors = 0;
                     SET @iParentNode = @ParentNode+' Measure Num ['+ISNULL(@Import_Measure_num, '<missing>')+']';
                     SET @intLocalMeasureID = 0;
                     SET @intDiagCodeMandatory = 0;
                     SET @validCPTCode = '';
                     SET @validDiagCode = '';
                     SET @validNumeratorCode = '';
                     SET @mandatoryDiagCode = 0;
                     SET @intLookupMeasureAge = 0;
                     SET @intReceivedMeasureAge = 0;
                     SET @intExamYear = 0;
                     SET @dteExamDate = ' 1900-01-01';
                     SET @Denominator_Exclusion = 0;
                     SET @No_of_Warnings = 0;
                     SET @CPT_CODE_Gender_Restriction = '';
                     SET @CPT_CODE_Denom_Exclusion = 0;
                     SET @Exclusionmessage = '';
                     SET @No_of_Exclusion = 0;
                     SET @Criteria = '';
                     SET @ISValidMeasureRecord = 1;
                     SET @CPT_CODE_CRITERIA = '';
	       
    --#1 Measure Number Validation
    
     --b : Validate Passed Measure_Num
				-- check measure is allowed for year of exam by date of exam

                    
                     SELECT @dteExamDate = Import_Exam_DateTime,
                            @strTin = Import_Physician_Group_TIN,
                            @strNPI = Import_Physician_NPI,
                            @strExamUniqueID = Import_Exam_Unique_ID,
                            @strPatientID = Import_Patient_ID,
                            @ImportGender = ISNULL(Import_Patient_Gender, '')
                     FROM tbl_Import_Exam WITH (nolock)
                     WHERE Import_examID = @ExamID
                           AND ISDATE(Import_Exam_DateTime) = 1;

						SELECT @intExamYear = YEAR(@dteExamDate);

						    SELECT @IsAcceptableDateRange = ISNULL(IsAcceptableDateRange, 0)
                     FROM tbl_Lookup_Measure WITH (NOLOCK)
                     WHERE Measure_num = @Import_Measure_num
                           AND CMSYear = @intExamYear;  --Change#20 
  -- Change #17:
  /*
                     IF(@IsAcceptableDateRange = 1)
                         BEGIN
                             SET @intExamYear = @CurrentActive_Year;
                         END;
                         ELSE
                         BEGIN
                             SELECT @intExamYear = YEAR(@dteExamDate);
						 END;
						 */
						 --Change#20  above code commented. To two active year functionality , measure related getting based on the examdate
						 
				
					
					--a : Does it exists?
                     IF(@Import_Measure_num IS NULL)
                       OR (ISNULL(@Import_Measure_num, '') = '')
                         BEGIN
                             SET @MeasureListCount = 0;

				--dO MISSING MEASURENUMBER RELATED LOGIC
                             IF((ISNULL(@Import_CPT_Code, '') <> '')
                                AND (ISNULL(@Import_Numerator_code, '') <> ''))
                                 BEGIN
                                     INSERT INTO @MeasureNumList_tbl
                                     EXEC dbo.SPGet_Measurenum_helpofProc_NumreratorCodes
                                          @intExamYear,
                                          @Import_Numerator_code,
                                          @Import_CPT_Code;
                                     SELECT @MeasureListCount = COUNT(*)
                                     FROM @MeasureNumList_tbl;
                                     IF(@MeasureListCount = 1)
                                         BEGIN
                                             SELECT @Import_Measure_num = Measure_num
                                             FROM @MeasureNumList_tbl;
                                             UPDATE tbl_Import_Exam_Measure_Data
                                               SET
                                                   Import_Measure_num = @Import_Measure_num
                                             WHERE Import_Exam_MeasureID = @Import_Exam_MeasureID;
                                             SET @Warningmessage = @Warningmessage+'Warning:P4032-Missing measure#. Populated measure#['+@Import_Measure_num+'] based on CPT code ['+@Import_CPT_Code+'], CMSYear['+CONVERT(VARCHAR(10), @intExamYear)+'] and Numerator_Response value ['+@Import_Numerator_code+'].'+CHAR(10);
                                             SET @No_of_Warnings = @No_of_Warnings + 1;
                                             PRINT('display warning for Missing Measure NUmber');
                                         END;
                                         ELSE
                                     IF((@MeasureListCount > 1))
                                         BEGIN
                                             SELECT @ConcatMeasureNumListString = COALESCE(@ConcatMeasureNumListString+', ', '')+Measure_num
                                             FROM @MeasureNumList_tbl;
                                             PRINT('display Error for Missing Measure NUmber');
                                             SET @message = @message+'P4033:Missing measure#. Unable to determine measure#.Found More than one measures#['+@ConcatMeasureNumListString+']  based on CPT code ['+@Import_CPT_Code+'], CMSYear['+CONVERT(VARCHAR(10), @intExamYear)+'] and Numerator_Response value ['+@Import_Numerator_code+'].'+CHAR(10);
                                             SET @No_of_Errors = @No_of_Errors + 1;
                                             SET @ISValidMeasureRecord = 0;
                                         END;
                                         ELSE    --(@MeasureListCount=0)
                                         BEGIN
                                             PRINT('display Error for Missing Measure NUmber');
                                             SET @message = @message+'P4034:Missing measure#. Unable to determine measure#  based on CPT code ['+@Import_CPT_Code+'], CMSYear['+CONVERT(VARCHAR(10), @intExamYear)+'] and Numerator_Response value ['+@Import_Numerator_code+'].'+CHAR(10);
                                             SET @No_of_Errors = @No_of_Errors + 1;
                                             SET @ISValidMeasureRecord = 0;
                                         END;
                                 END;
                                 ELSE
                                 BEGIN
                                     SET @message = @message+'P4035:Missing measure#. Unable to determine measure#  based on CPT code ['+@Import_CPT_Code+'], CMSYear['+CONVERT(VARCHAR(10), @intExamYear)+'] and Numerator_Response value ['+@Import_Numerator_code+'].'+CHAR(10);
                                     SET @No_of_Errors = @No_of_Errors + 1;
                                     SET @ISValidMeasureRecord = 0;
                                 END;
                         END;
                     SET @CPT_CODE_CRITERIA =
(
    SELECT Proc_Criteria
    FROM tbl_lookup_Denominator_Proc_Code
    WHERE Measure_num = @Import_Measure_num
          AND CMSYear = @intExamYear
          AND Proc_code = @Import_CPT_Code
);
                     SELECT @intLocalMeasureID = Measure_ID,
                            @intDiagCodeMandatory = Mandatory_Diagnos_Code,
                            @intLookupMeasureAge = Age_Restriction_From,
                            @Gender_Restriction = ISNULL(Gender_Restriction, 'NA'),
                            @IsAcceptableDateRange = ISNULL(IsAcceptableDateRange, 0)
                     FROM tbl_Lookup_Measure WITH (NOLOCK)
                     WHERE Measure_num = @Import_Measure_num
                           AND CMSYear = @intExamYear 
                ---and ForCMSSubmission = 1; -- This is important to control active measures for year
                           AND Allow_Portal_Submit = 1; ---- Change #16:

                     IF(ISNULL(@Import_Measure_num, '') <> '')
                         BEGIN
                             IF(@intLocalMeasureID = 0)
                                 BEGIN
                                     IF ISNULL(@Import_Measure_num, '') <> ''
                                         BEGIN
                                             IF @intExamYear = 1900
                                                 BEGIN
                                                     SET @message = @message+'P4002:Invalid Measure_Num ['+ISNULL(@Import_Measure_num, '')+'] entered.'+CHAR(10);
                                                     SET @No_of_Errors = @No_of_Errors + 1;
                                                     SET @ISValidMeasureRecord = 0;
                                                 END;
                                                 ELSE
                                                 BEGIN
                                                     SET @message = @message+'P4005: Entered Measure_Num ['+ISNULL(@Import_Measure_num, '')+'] with exam date '+CONVERT(VARCHAR(11), @dteExamDate)+' is not active for CMS Year '+CONVERT(VARCHAR(10), @intExamYear)+'. '+CHAR(10);
                                                     SET @No_of_Errors = @No_of_Errors + 1;
                                                     SET @ISValidMeasureRecord = 0;
                                                 END;
                                         END;
                                 END;
                                 ELSE
                             IF(@intLookupMeasureAge > 0)
                                 BEGIN
                                     SELECT @intReceivedMeasureAge = Import_Patient_Age
                                     FROM tbl_Import_Exam WITH (nolock)
                                     WHERE Import_examID = @ExamID
                                           AND dbo.IsInteger(Import_Patient_Age) = 1;
                                     IF @intLookupMeasureAge > @intReceivedMeasureAge
                                         BEGIN
                                             SET @message = @message+'P4003: Patient must be ['+CONVERT(VARCHAR(10), @intLookupMeasureAge)+'] and older to be eligible for measure ['+@Import_Measure_num+']. Submitted patient age value is ('+LTRIM(RTRIM(ISNULL(@intReceivedMeasureAge, '')))+').'+CHAR(10);
                                             SET @No_of_Errors = @No_of_Errors + 1;
                                             SET @ISValidMeasureRecord = 0;
                                         END;
                                 END;

--1.1 Measure and Gender validation
                             PRINT(CONVERT(DATETIME, @dteExamDate, 105));
                             IF(@intLocalMeasureID > 0)
                                 BEGIN
                                     IF((@Gender_Restriction <> 'NA')
                                        AND 
										(NOT EXISTS(select 1 from tbl_Lookup_Measure where Gender_Restriction like '%'+@ImportGender+'%' and Measure_num=@Import_Measure_num and CMSYear=@CurrentActive_Year))     -- Change #18
										--(@Gender_Restriction <> @ImportGender)
										)
                                         BEGIN
                                             SET @message = @message+'P4013:Invalid  Gender[ '+ISNULL(@ImportGender, '')+']	  entered for  Measure Number ['+@Import_Measure_num+'].'+CHAR(10);
                                             SET @No_of_Errors = @No_of_Errors + 1;
                                             SET @ISValidMeasureRecord = 0;
                                         END;
                                     IF(@IsAcceptableDateRange = 1)
                                         BEGIN
                                             IF(NOT EXISTS
(
    SELECT 1
    FROM tbl_Lookup_Acceptable_DateRange
    WHERE Measure_Num = @Import_Measure_num
          AND CMSYear = @intExamYear --Change#20
          AND CONVERT(DATETIME, acceptable_date_start, 105) <= CONVERT(DATETIME, @dteExamDate, 105)
          AND CONVERT(DATETIME, acceptable_date_end, 105) >= CONVERT(DATETIME, @dteExamDate, 105)
)
                                                AND (@CPT_CODE_CRITERIA = @CRITERIA1))
                                                 BEGIN
                                                     SET @message = @message+'P4013: Exam Date [ '+CONVERT(VARCHAR(11), @dteExamDate)+'] not in Acceptable Date range for  Measure Number ['+@Import_Measure_num+'],CPT CODE ['+@Import_CPT_Code+'] .'+CHAR(10);
                                                     SET @No_of_Errors = @No_of_Errors + 1;
                                                     SET @ISValidMeasureRecord = 0;
                                                 END;
                                                 ELSE
                                             IF((NOT EXISTS
(
    SELECT 1
    FROM tbl_Lookup_Active_Submission_Year
    WHERE Submission_Year = YEAR(@dteExamDate)
          AND IsActive = 1
)
                                                 AND (@CPT_CODE_CRITERIA = @CRITERIA2)--CHANGE#17			  
					  
					  
                                             ))
                                                 BEGIN
                                                     SET @message = @message+'P4013: Exam Date [ '+CONVERT(VARCHAR(11), @dteExamDate)+'] not in Acceptable Date range for  Measure Number ['+@Import_Measure_num+'],CPT CODE ['+@Import_CPT_Code+'] .'+CHAR(10);
                                                     SET @No_of_Errors = @No_of_Errors + 1;
                                                     SET @ISValidMeasureRecord = 0;
                                                 END;
                                                 ELSE
                                             IF((NOT EXISTS
(
    SELECT 1
    FROM tbl_Lookup_Acceptable_DateRange
    WHERE Measure_Num = @Import_Measure_num
          AND CMSYear = @intExamYear --Change#20
          AND CONVERT(DATETIME, acceptable_date_start, 105) <= CONVERT(DATETIME, @dteExamDate, 105)
          AND CONVERT(DATETIME, acceptable_date_end, 105) >= CONVERT(DATETIME, @dteExamDate, 105)
)
                                                 AND ((@CPT_CODE_CRITERIA = '')
                                                      OR (@CPT_CODE_CRITERIA IS NULL))--CHANGE#17			  
					  
					  
                                             ))
                                                 BEGIN
                                                     SET @message = @message+'P4013: Exam Date [ '+CONVERT(VARCHAR(11), @dteExamDate)+'] not in Acceptable Date range for  Measure Number ['+@Import_Measure_num+'].'+CHAR(10);
                                                     SET @No_of_Errors = @No_of_Errors + 1;
                                                     SET @ISValidMeasureRecord = 0;
                                                 END;
                                         END;
                                 END;
    
    --#2 Measure CPT code Validation
    --a : Any value?
                             IF(@Import_CPT_Code IS NULL)
                               OR (ISNULL(@Import_CPT_Code, '') = '')
                                 BEGIN
                                     SET @message = @message+'P4011:Missing CPT_Code.'+CHAR(10);
                                     SET @No_of_Errors = @No_of_Errors + 1;
                                     SET @ISValidMeasureRecord = 0;
                                 END;
                                 ELSE
                                 BEGIN
		--b : VAlid Cope of  Measure Num
                                     SELECT @validCPTCode = Proc_code
                                     FROM tbl_lookup_Denominator_Proc_Code
                                     WHERE CMSYear = @intExamYear and Measure_num = @Import_Measure_num
                                           AND Proc_code = @Import_CPT_Code;
                                     IF(ISNULL(@validCPTCode, '') = '')
                                         BEGIN
                                             SET @message = @message+'P4012:Invalid CPT_Code[ '+ISNULL(@Import_CPT_Code, '')+'] entered for  Measure Number ['+@Import_Measure_num+'].'+CHAR(10);
                                             SET @No_of_Errors = @No_of_Errors + 1;
                                             SET @ISValidMeasureRecord = 0;
                                         END
					   		--:CPT_CODE , Gender_Restriction code and Denominator Exclusion validation-- Change #10:;
                                         ELSE
                                         BEGIN
					   --SELECT  @CPT_CODE_Gender_Restriction = ISNULL(Gender_Restriction,'NA'),
					   --@CPT_CODE_Denom_Exclusion=ISNULL(Denominator_Exclusion,0)
        --                FROM    tbl_lookup_Denominator_Proc_Code
        --                WHERE   Measure_num = @Import_Measure_num
        --                        AND Proc_code = @Import_CPT_Code and Gender_Restriction =@ImportGender
			
                        --IF ( (@CPT_CODE_Gender_Restriction <> 'NA') AND (@CPT_CODE_Gender_Restriction <> @ImportGender)) 
                                             IF(
(
    SELECT COUNT(*)
    FROM tbl_lookup_Denominator_Proc_Code
    WHERE  CMSYear = @intExamYear and Measure_num = @Import_Measure_num
          AND Proc_code = @Import_CPT_Code
          AND Denominator_Exclusion = 1

		  
          --AND Gender_Exclusion = @ImportGender
) > 0) -- Change #10:

                                                 BEGIN
                                                     --SET @Exclusionmessage = @Exclusionmessage+'P4036: CPT_Code[ '+ISNULL(@Import_CPT_Code, '')+']  is excluded from the initial patient population.'+CHAR(10);
                                                     --SET @No_of_Exclusion = @No_of_Exclusion + 1;
										    SET @message = @message+'P4036:The cpt code [ '+ISNULL(@Import_CPT_Code, '')+']  matches the denominator exclusion code'+CHAR(10);
                                             SET @No_of_Errors = @No_of_Errors + 1;---- Change #19
                                                     SET @ISValidMeasureRecord = 0;
                                                 END;
                                         END;
                                 END;
                             SELECT @mandatoryDiagCode = Mandatory_Diagnos_Code
                             FROM tbl_Lookup_Measure
                             WHERE CMSYear = @intExamYear and Measure_num = @Import_Measure_num;
							 
                             IF(((@Import_Diagnosis_code IS NULL)
                                 OR (ISNULL(@Import_Diagnosis_code, '') = ''))
                                AND (@mandatoryDiagCode = 1))
                                 BEGIN
                                     SET @message = @message+'P4021:Missing Diagnosis_Code.'+CHAR(10);
                                     SET @message = @message;
                                 END;
                                 ELSE
                                 BEGIN
                                     SELECT @validDiagCode = code,
                                            @Denominator_Exclusion = ISNULL(Denominator_Exclusion, 0)
                                     FROM tbl_Lookup_Denominator_Diag_Code
                                     WHERE Measure_num = @Import_Measure_num
                                           AND code = @Import_Diagnosis_code;
                                     IF((ISNULL(@validDiagCode, '') = '')
                                        AND (@mandatoryDiagCode = 1))
                                         BEGIN
                                             SET @message = @message+'P4022:Invalid Diagnosis_Code[ '+ISNULL(@Import_Diagnosis_code, '')+'] entered for  Measure Number ['+@Import_Measure_num+'].'+CHAR(10);
                                             SET @No_of_Errors = @No_of_Errors + 1;
                                             SET @ISValidMeasureRecord = 0;
                                         END
-- Change #8;
                                         ELSE
                                     IF((@Denominator_Exclusion = 1)
                                        AND (@mandatoryDiagCode = 1))
                                         BEGIN
			   --SET @message = @message
      --                              + 'P4023:Diagnosis code is excluded for Diagnosis_Code[ '
      --                              + ISNULL(@Import_Diagnosis_code, '')
      --                              + '] and Measure Number ['
      --                              + @Import_Measure_num + '].' + CHAR(10) ;
      --                          SET @No_of_Errors = @No_of_Errors + 1 ;


                                             SET @Exclusionmessage = @Exclusionmessage+'Exclusion: P4023:Diagnosis code is excluded. This exam is excluded from initial population for Diagnosis_Code[ '+ISNULL(@Import_Diagnosis_code, '')+'] and Measure Number ['+@Import_Measure_num+'].'+CHAR(10);
                                             SET @No_of_Exclusion = @No_of_Exclusion + 1;
                                             SET @ISValidMeasureRecord = 0;
                                         END;
                                 END;
    
    --PRINT('@Import_Numerator_code :LineNo:369'+CONVERT(Varchar(10),ISNULL(@Import_Numerator_code,'um NUll')))

                             IF(((@Import_Numerator_code IS NULL)
                                 OR (ISNULL(@Import_Numerator_code, '') = ''))
                                AND (ISNULL(@Import_Measure_num, '') <> '')
                                AND (ISNULL(@ISValidMeasureRecord, 1) = 1))
                                 BEGIN
                        --SET @Warningmessage = ISNULL(@Warningmessage,'')
                        --    + 'P4031:Missing Numerator_Value.' + CHAR(10) ;

                                     SET @Warningmessage = @Warningmessage+'Warning:P4031-The numerator response value[ '+ISNULL(@Import_Numerator_code, '')+'] is missing for this  Measure Number ['+@Import_Measure_num+']  but will be included in the eligible population.'+CHAR(10);
                                     SET @No_of_Warnings = @No_of_Warnings + 1;
                                 END;
                                 ELSE
                                 BEGIN
		--  PRINT('@Import_Numerator_code :LineNo:369'+CONVERT(Varchar(10),@Import_Numerator_code))
                                     SELECT @validNumeratorCode = Numerator_Code,
                                            @Criteria = Criteria
                                     FROM tbl_lookup_Numerator_Code
                                     WHERE Measure_Num = @Import_Measure_num
                                           AND Numerator_Code = @Import_Numerator_code;
 --PRINT('@@Import_Measure_num,@Import_Numerator_code :LineNo:385'+CONVERT(Varchar(10),@Import_Measure_num)+','+CONVERT(Varchar(10),@Import_Numerator_code)+','+CONVERT(Varchar(10),ISNULL(@validNumeratorCode,'HariValidNum')))
                                     IF(((ISNULL(@validNumeratorCode, '') = '')
                                         OR (@validNumeratorCode IS NULL))
                                        AND (ISNULL(@Import_Measure_num, '') <> '')
                                        AND (ISNULL(@ISValidMeasureRecord, 1) = 1))
                                         BEGIN
					   -- PRINT('inside if')
					   --Warning, the numerator response value is missing or incorrect but will be included in the eligible population
                                --SET @Warningmessage = @Warningmessage
                                --    + 'P4032:Invalid Numerator_Value[ '
                                --    + ISNULL(@Import_Numerator_code, '')
                                --    + '] entered for  Measure Number ['
                                --    + @Import_Measure_num + '].' + CHAR(10) ;

                                             SET @Warningmessage = @Warningmessage+'Warning:P4031-The numerator response value[ '+ISNULL(@Import_Numerator_code, '')+'] is incorrect for this  Measure Number ['+@Import_Measure_num+']  but will be included in the eligible population.'+CHAR(10);
                                             SET @No_of_Warnings = @No_of_Warnings + 1;
                                         END;
                                 END;
		
		
  --              IF ( ISNULL(@Import_Measure_num, '') <> '' ) 
  --                  BEGIN
		
		---- Note: this query runs under @Import_Examid not @ImportMeasure_ID to reject.
		---- this is not in spValidateImportExam in order to allow other measure numbers,if correct can be posted.
  --                      SELECT  @message = @message
  --                              + 'P4004: Duplicate measures found. Measure number['
  --                              + CONVERT(VARCHAR(10), Import_measure_num)
  --                              + '].' + CHAR(10) ,
  --                              @No_of_Errors = @No_of_Errors + 1
  --                      FROM    tbl_Import_Exam_Measure_Data
  --                      WHERE   Import_ExamID = @Import_ExamID
  --                              AND Import_Measure_num = @Import_Measure_num
		--		--group by Import_ExamID,Import_measure_num
  --                      GROUP BY Import_ExamID ,
  --                              Import_measure_num ,
  --                              Import_CPT_Code
  --                      HAVING  COUNT(Import_measure_num) > 1
						
    
  --                  END
					
					--<change 2017>
					--<change 1>
					--<change 2>
					-- Change #4
				--	if exists (select top 1 physician_npi, exam_tin, patient_id,
				--	 patient_age, patient_gender, exam_date, measure_id, 
				--	denominator, denominator_proc_code, denominator_diag_code, 
				--	numerator_response_value,Criteria
				--	--exam_unique_id, facility_id      
				--	from vw_exam_data
				--	group by physician_npi, exam_tin, patient_id, patient_age, patient_gender, exam_date, measure_id, 
				--	denominator, denominator_proc_code, denominator_diag_code, numerator_response_value,Criteria
				--	--exam_unique_id, facility_id
				--	--having count(*) > 1
				--	having count(*) > 0
				--	and ltrim(rtrim(isnull(vw_Exam_Data.Physician_NPI,'123'))) = ltrim(rtrim(isnull(@strNPI,'abc')))
				--	and ltrim(rtrim(isnull(vw_Exam_Data.Exam_TIN,'123')))= ltrim(rtrim(isnull(@strTin,'abc')))
				--  --  and ltrim(rtrim(isnull(vw_Exam_Data.Exam_Unique_ID,'123'))) = ltrim(rtrim(isnull(@strExamUniqueID,'abc')))
				--    and vw_Exam_Data.Exam_Date = @dteExamDate
				--    and ltrim(rtrim(isnull(vw_Exam_Data.Patient_ID,'123'))) = ltrim(rtrim(isnull(@strPatientID,'abc')))
				--    and ltrim(rtrim(isnull(vw_Exam_Data.Measure_ID,'123'))) = ltrim(rtrim(isnull(@intLocalMeasureID,'abc')))
				--    and ltrim(rtrim(isnull(vw_Exam_Data.Denominator_proc_code,'123'))) = ltrim(rtrim(isnull(@Import_CPT_Code,'abc')))
				--    --@Criteria
				--       and ltrim(rtrim(isnull(vw_Exam_Data.Criteria,'123'))) = ltrim(rtrim(isnull(@Criteria,'abc')))--- Change 13#
				--	 )
				--BEGIN
				-- SELECT  @message = @message
    --                            + 'P4005: Duplicate measure. A valid record with matching measure data is already validated and posted  for cms. Measure number['
    --                            + CONVERT(VARCHAR(10), ISNULL(@Import_Measure_num, ''))
    --                            + '].' + CHAR(10)
				--		, @No_of_Errors = @No_of_Errors + 1
				

				--END
				--else 
				--Begin
				-- select 'not going into trap' as error_type

				-- select top 1 'full filter' as test , physician_npi, exam_tin, patient_id,
				--	 patient_age, patient_gender, exam_date, measure_id, 
				--	denominator, denominator_proc_code, denominator_diag_code, 
				--	numerator_response_value, exam_unique_id, facility_id
				--	from vw_exam_data
				--	group by physician_npi, exam_tin, patient_id, patient_age, patient_gender, exam_date, measure_id, 
				--	denominator, denominator_proc_code, denominator_diag_code, numerator_response_value, exam_unique_id, facility_id
				--	having count(*) > 1 
				--	and vw_Exam_Data.Physician_NPI = @strNPI
				--	and vw_Exam_Data.Exam_TIN = @strTin
				--    and vw_Exam_Data.Exam_Unique_ID = @strExamUniqueID
				--	and vw_Exam_Data.Exam_Date = @dteExamDate
				--	and vw_Exam_Data.Patient_ID = @strPatientID
				--	and vw_Exam_Data.Measure_ID = @intLocalMeasureID 
				--	and vw_Exam_Data.Denominator_proc_code = @Import_CPT_Code

				--	select  'part filter' as test , 
				--	ltrim(rtrim(isnull(vw_Exam_Data.Patient_ID,''))),
				--	ltrim(rtrim(isnull(@strPatientID,'')))
				--	physician_npi, exam_tin, patient_id,
				--	 patient_age, patient_gender, exam_date, measure_id, 
				--	denominator, denominator_proc_code, denominator_diag_code, 
				--	numerator_response_value, exam_unique_id, facility_id
				--	from vw_exam_data
				--	group by physician_npi, exam_tin, patient_id, patient_age, patient_gender, exam_date, measure_id, 
				--	denominator, denominator_proc_code, denominator_diag_code, numerator_response_value, exam_unique_id, facility_id
				--	having count(*) > 1 
				--	and ltrim(rtrim(isnull(vw_Exam_Data.Physician_NPI,'123'))) = ltrim(rtrim(isnull(@strNPI,'abc')))
				--	and ltrim(rtrim(isnull(vw_Exam_Data.Exam_TIN,'123')))= ltrim(rtrim(isnull(@strTin,'abc')))
				--    and ltrim(rtrim(isnull(vw_Exam_Data.Exam_Unique_ID,'123'))) = ltrim(rtrim(isnull(@strExamUniqueID,'abc')))
				--    and vw_Exam_Data.Exam_Date = @dteExamDate
				--    and ltrim(rtrim(isnull(vw_Exam_Data.Patient_ID,'123'))) = ltrim(rtrim(isnull(@strPatientID,'abc')))
				--    and ltrim(rtrim(isnull(vw_Exam_Data.Measure_ID,'123'))) = ltrim(rtrim(isnull(@intLocalMeasureID,'abc')))
				--    and ltrim(rtrim(isnull(vw_Exam_Data.Denominator_proc_code,'123'))) = ltrim(rtrim(isnull(@Import_CPT_Code,'abc')))
				--End

				--</change 2>
				--</change 1>
				--</change 2017>

                             SET @blnMeasureDataExtExists = 1;
                             SET @intMeasuresDataExtCount = 0;
                             SET @intCorrectMeasureExtCount = 0;
                             SET @intInCorrectMeasureExtCount = 0;
                             IF NOT EXISTS
(
    SELECT TOP 1 *
    FROM tbl_Import_Measure_Data_Extension
    WHERE  Import_Measure_Data_ID = @Import_Exam_MeasureID
)
                                 BEGIN
                                     SET @blnMeasureDataExtExists = 0;
                                 END;
                                 ELSE
                                 BEGIN
                                     EXEC dbo.spValidateImportExamMeasureDataExtension
                                          @Import_Exam_MeasureID;
                                     SELECT @intCorrectMeasureExtCount = COUNT(*)
                                     FROM tbl_Import_Measure_Data_Extension
                                     WHERE Import_Measure_Data_ID = @Import_Exam_MeasureID
                                           AND (Error_Codes_Desc IS NULL);
                                     SELECT @intInCorrectMeasureExtCount = COUNT(*)
                                     FROM tbl_Import_Measure_Data_Extension
                                     WHERE Import_Measure_Data_ID = @Import_Exam_MeasureID
                                           AND (Error_Codes_Desc IS NOT NULL);
                                 END;
                         END;
                     IF((ISNULL(@message, '') <> '')
                        OR (ISNULL(@Exclusionmessage, '') <> ''))
                         BEGIN
		-- here only one possiblity possbilities of status  : ValidationFailed
		-- Note for measure Data: Partial Failure is not allowed
--    set @message = 'Errors In Import exam Measure Data : '+ CONVERT(varchar(10),@Import_Exam_MeasureID)+ CHAR(10) +  @message;
                             IF(ISNULL(@message, '') <> '')
                                 BEGIN
                                     SET @messageJSON = @message;
                                     SET @message = 'Errors In Import Exam Measure Data '+@iParentNode+CHAR(10)+@message;
                                 END;
                             IF(ISNULL(@Exclusionmessage, '') <> '')
                                 BEGIN
                                     SET @Exclusionmessage = 'Exclusions In Import Exam Measure Data '
                            --+ @iParentNode + CHAR(10) 
                                     +@Exclusionmessage;
                                 END;
                             IF(ISNULL(@Warningmessage, '') <> '')-- Change #9:
                                 BEGIN
                                     SET @Warningmessage = 'Warnings In Import Exam Measure Data '
                            --+ @iParentNode + CHAR(10) 
                                     +@Warningmessage;
                                 END;
                             UPDATE tbl_Import_Exam_Measure_Data
                               SET
                                   Error_Codes_Desc = CASE
                                                          WHEN @message = ''
                                                          THEN NULL
                                                          ELSE @message
                                                      END,
                                   Error_Codes_JSON = CASE
                                                          WHEN @messageJSON = ''
                                                          THEN NULL
                                                          ELSE @messageJSON
                                                      END,
                                   Warning_Codes_Desc = CASE
                                                            WHEN @Warningmessage = ''
                                                            THEN NULL
                                                            ELSE @Warningmessage
                                                        END,
                                   Exclusion_Codes_Desc = CASE
                                                              WHEN @Exclusionmessage = ''
                                                              THEN NULL
                                                              ELSE @Exclusionmessage
                                                          END,
                                   Correct_Data_Extensions = @intCorrectMeasureExtCount,
                                   InCorrect_Data_Extensions = @intInCorrectMeasureExtCount,
                                   [Status] = 5
                                   , -- validation Failed 
                                   No_of_Errors = @No_of_Errors,
                                   [No_of_Warnings] = @No_of_Warnings,
                                   No_of_Exclusions = @No_of_Exclusion

			
		--where  Import_examID = @Import_examID
                             WHERE Import_Exam_MeasureID = @Import_Exam_MeasureID;
                             PRINT '-------- Measure Data Report WITH ERROR BLOCK --------';
                             PRINT @message;
                             PRINT @Exclusionmessage;
                             PRINT @Warningmessage;
                             PRINT '-------- Measure Data Report End --------';
                         END;
                         ELSE
                     IF(ISNULL(@Warningmessage, '') <> '')-- Change #9:
                         BEGIN
                             UPDATE tbl_Import_Exam_Measure_Data
                               SET
                                   Error_Codes_Desc = NULL,
                                   Error_Codes_JSON = NULL,
                                   Warning_Codes_Desc = CASE
                                                            WHEN @Warningmessage = ''
                                                            THEN NULL
                                                            ELSE @Warningmessage
                                                        END,
                                   Exclusion_Codes_Desc = CASE
                                                              WHEN @Exclusionmessage = ''
                                                              THEN NULL
                                                              ELSE @Exclusionmessage
                                                          END,
                                   Correct_Data_Extensions = @intCorrectMeasureExtCount,
                                   InCorrect_Data_Extensions = @intInCorrectMeasureExtCount,
                                   [Status] = CASE
                                                  WHEN(@intInCorrectMeasureExtCount > 0)
                                                  THEN 5 -- validation failed
                                                  ELSE 3  -- successfull
                                              END,
                                   No_of_Errors = @No_of_Errors,
                                   [No_of_Warnings] = @No_of_Warnings,
                                   No_of_Exclusions = @No_of_Exclusion		
		--where  Import_examID = @Import_examID
                             WHERE Import_Exam_MeasureID = @Import_Exam_MeasureID;
                         END;
                         ELSE
                         BEGIN
                             UPDATE tbl_Import_Exam_Measure_Data
                               SET
                                   Error_Codes_Desc = NULL,
                                   Error_Codes_JSON = NULL,
                                   Correct_Data_Extensions = @intCorrectMeasureExtCount,
                                   InCorrect_Data_Extensions = @intInCorrectMeasureExtCount,
                                   [Status] = CASE
                                                  WHEN(@intInCorrectMeasureExtCount > 0)
                                                  THEN 5 -- validation failed
                                                  ELSE 3  -- successfull
                                              END,
                                   No_of_Errors = @No_of_Errors,
                                   [No_of_Warnings] = @No_of_Warnings,
                                   Warning_Codes_Desc = CASE
                                                            WHEN @Warningmessage = ''
                                                            THEN NULL
                                                            ELSE @Warningmessage
                                                        END,
                                   No_of_Exclusions = @No_of_Exclusion,
                                   Exclusion_Codes_Desc = CASE
                                                              WHEN @Exclusionmessage = ''
                                                              THEN NULL
                                                              ELSE @Exclusionmessage
                                                          END
		--where  Import_examID = @Import_examID
                             WHERE Import_Exam_MeasureID = @Import_Exam_MeasureID;
                         END;
                     FETCH NEXT FROM Cursor_Imp_Mes_Data INTO @Import_Exam_MeasureID, @Import_ExamID, @Import_Measure_num, @Import_CPT_Code, @Import_Diagnosis_code, @Import_Numerator_code;
                 END;
             CLOSE Cursor_Imp_Mes_Data;
             DEALLOCATE Cursor_Imp_Mes_Data;
         END;



