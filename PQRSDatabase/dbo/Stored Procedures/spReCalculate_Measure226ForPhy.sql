
-- =============================================
-- Author:		Hari J
-- Create date: 27th,Dec,2018
-- Description:	Used to calculate performance of measure 226 and physician
-- Change#1:hari j on Jan,10th 2019
--Change#1: CPT code validation at patient level
-- Change#2:hari j on Jan,18th 2019
--Change#2:ignoring the numirator code null values
-- Change#3:hari j on Feb,14th 2019
--Change#3:validtaion part will done at only night shedular
-- Change#4:hari j on Mar,03 2019
--Change#4 :JIRA#673  
-- Change#5:hari j on Mar,15 2019
--Change#5 :JIRA#678  
-- Change#6:hari j on Mar,28 2019
--Change#6 :include C2 in eligible population since the patient is a tobacco user.  
-- Change#8 : JIRA#973  , pranay on July 15,2021
 ---------- We don’t need to validate the exam date when determining eligible population
-- =============================================

CREATE PROCEDURE [dbo].[spReCalculate_Measure226ForPhy]
@NPI varchar(11),
@TIN varchar(10),
@intCurActiveYear int,
@strMeasure_num varchar(50),
@blnGPRO bit,
@isReqFromShedular bit=1
AS
BEGIN

  DECLARE @initPatientPopulation AS INT
       
        DECLARE @DenominatorExclusionCount AS INT
        DECLARE @DenominatorExceptionCount AS INT
        DECLARE @ReportingNumerator AS INT
        DECLARE @ReportingDenominatorCount AS INT

        DECLARE @performanceNumerator AS INT
        DECLARE @performanceDenoCount AS INT
        DECLARE @performanceMetCount AS INT	
        DECLARE @performanceNotMetCount AS INT
     --   DECLARE @strMeasure_num AS VARCHAR(20) ;


        DECLARE @reportingRate AS FLOAT ;
        DECLARE @performanceRate AS FLOAT ;


        DECLARE @blnSelectedForSubmission BIT
        DECLARE @intTotalCasesReviewed INT
        DECLARE @blnHundredPercentSubmit BIT

        DECLARE @First_Encounter_date DATETIME
        DECLARE @Last_Encounter_Date DATETIME
		
		-- King Lo 2/28/2015
		DECLARE @performanceDenominator AS INT;
		
		DECLARE @benchmarkMet AS NVARCHAR(1);
	

		--Hari 1/5-2018 for decilevalue

		DECLARE @decile_Val as varchar(100);

		declare @TotalExamsCount int ;
		 DECLARE @Agg_Id int
--curser CUR_PatientIds startd
DECLARE @CRITERIA1 varchar(30) = 'CRITERIA1'
DECLARE @CRITERIA2 varchar(30) = 'CRITERIA2'
DECLARE @CRITERIA3 varchar(30) = 'CRITERIA3'
DECLARE @TubaccoUserCode varchar(30)='G9902'
print('measure 226 related stratum line 59')		

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
DELETE from tbl_Physician_Aggregation_Year where CMS_Submission_Year=@intCurActiveYear   
AND Physician_NPI = @NPI 
AND   Exam_TIN = @TIN   
AND Measure_num = @strMeasure_num
AND Is_90Days=0
 --and  Stratum_Id =CASE WHEN @isReqFromShedular <>1 then  4 ELSE Stratum_Id END;
IF(@isReqFromShedular=1)-- --Change#3

BEGIN
----------------------*********** Validation Part Start *******-----------------------------------------
--STEP #0: Delete previous data
DELETE from tbl_Physician_Aggregation_For_226 where CMS_Submission_Year=@intCurActiveYear   AND Physician_NPI = @NPI AND
   Exam_TIN = @TIN   AND Measure_num = @strMeasure_num
print('measure 226 related stratum line 68')		


IF OBJECT_ID('tempdb..#tmptbl_Physician_Aggregation_For_226') IS NOT NULL  
DROP TABLE #tmptbl_Physician_Aggregation_For_226

CREATE TABLE #tmptbl_Physician_Aggregation_For_226(
	
	[Physician_NPI] [varchar](50) NULL,
	[Exam_TIN] [varchar](10) NULL,
	[Patient_ID] [varchar](500) NULL,
	[Exam_Date] [datetime] NULL,
	[CMS_Submission_Year] [int] NULL,
	[Measure_ID] [int] NULL,
	[Measure_Num] [varchar](50) NULL,
	[Denominator_proc_code] [varchar](50) NULL,
	[Numerator_Code] [varchar](100) NULL,
	[Created_Date] [datetime] NULL,
	[Created_By] [varchar](50) NULL,
	[Criteria] [varchar](20) NULL,
	[CPT_Code_Validation] [bit] NULL,
	[CPT_Code_Validation_Message] [varchar](max) NULL,
	[Is_Most_Recent_Exam] [bit] NULL,
	[Criteria_Validation] [bit] NULL,
	[Criteria_Validation_Message] [varchar](max) NULL,
	[Performance_Met] [bit] NULL,
	[Performance_NotMet] [bit] NULL,
	[Denominator_Exception] [bit] NULL,
	[Is_TobaccoUser] [bit] NULL,
	[Is_EligiblePopulation] [bit] NULL)


--STEP #1: Insert Raw Data
INSERT INTO #tmptbl_Physician_Aggregation_For_226
           ([Physician_NPI]
           ,[Exam_TIN]
           ,[Patient_ID]
           ,[Exam_Date]
           ,[CMS_Submission_Year]
           ,[Measure_ID]
           ,[Measure_Num]
           ,[Denominator_proc_code]
           ,[Numerator_Code]
           ,[Created_Date]
           ,[Created_By]
           ,[Criteria]
          -- ,[CPT_Code_Validation]
          -- ,[CPT_Code_Validation_Message]
          -- ,[Is_Most_Recent_Exam]
          -- ,[Criteria_Validation]
          -- ,[Criteria_Validation_Message]
           --,[Performance_Met]
       --    ,[Performance_NotMet]
        --   ,[Denominator_Exception]
)
	
	select  

 e.Physician_NPI,
 e.Exam_TIN,
 e.Patient_ID,
 e.Exam_Date,
 e.CMS_Submission_Year,
 md.Measure_ID,
 N.Measure_num,
 md.Denominator_proc_code,
 md.Numerator_Code,
 e.Created_Date,
 e.Created_By,
 md.Criteria

 FROM    tbl_Exam e WITH ( NOLOCK )  
 INNER JOIN tbl_Exam_Measure_Data md    WITH ( NOLOCK ) ON md.Exam_Id = e.Exam_Id 
 INNER JOIN  tbl_Lookup_Measure N WITH ( NOLOCK ) ON N.Measure_ID = md.Measure_ID
   WHERE  
  e.CMS_Submission_Year = @intCurActiveYear
  AND N.CMSYear=@intCurActiveYear
    AND e.Physician_NPI = @NPI AND
   e.Exam_TIN = @TIN   AND N.Measure_num = @strMeasure_num
     -- AND N.Numerator_response_Value = md.Numerator_response_value    AND 
  and    md.[Status] IN ( 2, 3 )  
  and (md.Numerator_Code IS  NULL OR md.Numerator_Code <> '' OR md.Criteria <> 'NA')   --Change#2
  and (e.Exam_Date IS  NULL OR e.Exam_Date <> '')
  --AND md.Numerator_Code=N.Numerator_Code

  print('measure 226 related stratum line 123')		

  --Step#2:cpt code validation




    print('measure 226 related stratum line 144:NPI'+convert(varchar ,ISNULL(@NPI,''))+',TIN:'+@TIN+',@strMeasure_num:'+convert(varchar ,ISNULL(@strMeasure_num,''))+'@intCurActiveYear:'+convert(varchar ,ISNULL(@intCurActiveYear,''))+'')
  DECLARE @Cur_Patient_ID [varchar](500)
  DECLARE @CUR_Criteria varchar(20)
  DECLARE @CPT_Code_Validation bit
 DECLARE @CPT_Code_Validation_Message varchar (max)
   DECLARE @Criteria_Validation bit
 DECLARE @Criteria_Validation_Message varchar (max)

 DECLARE @MostRecentExamDateofC1 date 



DECLARE @Atleast1 varchar(10)='Atleast1'
DECLARE @Atleast2 varchar(10)='Atleast2'

DECLARE @Atleast1_ValidMsg varchar(100)='Satisfied Atleast1 CPT CODE Condition'
DECLARE @Atleast2_ValidMsg varchar(100)='Satisfied Atleast2 CPT CODE Condition'

UPDATE PA
   SET PA.CPT_Code_Validation = 1,
	   PA.CPT_Code_Validation_Message = @Atleast1_ValidMsg
  FROM #tmptbl_Physician_Aggregation_For_226 PA
       INNER JOIN tbl_lookup_Denominator_Proc_Code P ON 
	            --                                              PA.CMS_Submission_Year = @intCurActiveYear   
													--AND PA.Physician_NPI = @NPI 
													--AND PA.Exam_TIN = @TIN   
													--AND PA.Measure_num = @strMeasure_num  AND 
													PA.Denominator_proc_code = P.Proc_code
                                                    AND PA.CMS_Submission_Year = P.CMSYear													  
												    AND PA.Measure_Num = P.Measure_num
												    AND P.Atleast_Condition_226 = @Atleast1
												   
												    --AND EXISTS(SELECT 1 
																--		 FROM #tmptbl_Physician_Aggregation_For_226 PA1
																--		WHERE PA1.CMS_Submission_Year = PA.CMS_Submission_Year    
																--		  AND PA1.Physician_NPI = PA.Physician_NPI 
																--		  AND PA1.Exam_TIN = PA.Exam_TIN
																--		  AND PA1.Measure_num = PA.Measure_num
																--		  AND PA1.Patient_ID = PA.Patient_ID
																--		  AND PA1.Criteria=PA.Criteria
																--		 )
											
UPDATE PA
   SET PA.CPT_Code_Validation = 1,
	   PA.CPT_Code_Validation_Message = @Atleast1_ValidMsg
  FROM #tmptbl_Physician_Aggregation_For_226 PA 
  
  WHERE PA.Patient_ID in (SELECT p.Patient_ID FROM #tmptbl_Physician_Aggregation_For_226 P
                                     WHERE P.CPT_Code_Validation=1 ) 

												  

UPDATE PA
   SET PA.CPT_Code_Validation = 1,
	   PA.CPT_Code_Validation_Message = @Atleast2_ValidMsg
  FROM #tmptbl_Physician_Aggregation_For_226 PA
       INNER JOIN tbl_lookup_Denominator_Proc_Code P ON        
	            --                                               PA.CMS_Submission_Year = @intCurActiveYear   
													--AND PA.Physician_NPI = @NPI 
													--AND PA.Exam_TIN = @TIN   
													--AND PA.Measure_num = @strMeasure_num AND 
													PA.CPT_Code_Validation IS NULL
												    AND PA.Denominator_proc_code = P.Proc_code
                                                    AND PA.CMS_Submission_Year = P.CMSYear
												    AND PA.Measure_Num = P.Measure_num
												    AND P.Atleast_Condition_226 = @Atleast2
													AND EXISTS (SELECT 1 
																  FROM #tmptbl_Physician_Aggregation_For_226 PA1
																	   INNER JOIN tbl_lookup_Denominator_Proc_Code P1 ON PA1.Denominator_proc_code = P1.Proc_code
																												   AND PA1.CMS_Submission_Year = P1.CMSYear													  
																												   AND PA1.Measure_Num = P1.Measure_num
																												   AND P1.Atleast_Condition_226 = @Atleast2
																												   AND PA1.CMS_Submission_Year = PA.CMS_Submission_Year    
																												   AND PA1.Physician_NPI = PA.Physician_NPI 
																												   AND PA1.Exam_TIN = PA.Exam_TIN
																												   AND PA1.Measure_num = PA.Measure_num
																												   AND PA.Patient_ID = PA1.Patient_ID

																												   AND ((PA.Denominator_proc_code = PA1.Denominator_proc_code  
																												   AND CONVERT(DATE,PA.Exam_Date) <> CONVERT(DATE, PA1.Exam_Date)  
																												   OR PA.Denominator_proc_code <> PA1.Denominator_proc_code
																												   )
																												  ) --Change#5
																												 --  AND PA.Criteria=PA1.Criteria
																												   )
--													 --AND EXISTS(SELECT 1 
--														--				 FROM #tmptbl_Physician_Aggregation_For_226 PA2
--														--				WHERE PA2.CMS_Submission_Year = PA.CMS_Submission_Year    
--														--				  AND PA2.Physician_NPI = PA.Physician_NPI 
--														--				  AND PA2.Exam_TIN = PA.Exam_TIN
--														--				  AND PA2.Measure_num = PA.Measure_num
--														--				  AND PA2.Patient_ID = PA.Patient_ID
--														--				  AND PA2.Criteria=PA.Criteria
--														--				 )															   








UPDATE PA
   SET PA.CPT_Code_Validation = 1,
	   PA.CPT_Code_Validation_Message = @Atleast2_ValidMsg
  FROM #tmptbl_Physician_Aggregation_For_226 PA 
  
  WHERE PA.CPT_Code_Validation IS NULL
  AND  PA.Patient_ID in (SELECT p.Patient_ID FROM #tmptbl_Physician_Aggregation_For_226 P
                                     WHERE P.CPT_Code_Validation=1  
                                     AND P.CPT_Code_Validation_Message = @Atleast2_ValidMsg) 

UPDATE PA
   SET PA.CPT_Code_Validation = 0,
       PA.CPT_Code_Validation_Message = 'Failed the CPT Code validation'
  FROM #tmptbl_Physician_Aggregation_For_226 PA
 WHERE 
 --PA.CMS_Submission_Year = @intCurActiveYear   
 --  AND PA.Physician_NPI = @NPI 
 --  AND PA.Exam_TIN = @TIN   
 --  AND PA.Measure_num = @strMeasure_num
 --  AND    
   PA.CPT_Code_Validation IS NULL




--Is_Most_Recent_Exam POPULATION FOR  C1,C3 AND C2 

UPDATE PA
   SET PA.Is_Most_Recent_Exam=1
  -- , PA.Is_EligiblePopulation=1
  FROM #tmptbl_Physician_Aggregation_For_226 PA
 WHERE 
   --PA.CMS_Submission_Year = @intCurActiveYear   
   --AND PA.Physician_NPI = @NPI 
   --AND PA.Exam_TIN = @TIN   
   --AND PA.Measure_num = @strMeasure_num  AND
    PA.CPT_Code_Validation = 1
   AND CONVERT(date,Exam_Date) =  (SELECT CONVERT(date,MAX(Exam_Date))
                                     FROM #tmptbl_Physician_Aggregation_For_226 A
									WHERE 
									A.CMS_Submission_Year = PA.CMS_Submission_Year
									  AND A.Physician_NPI = PA.Physician_NPI 
									  AND A.Exam_TIN = PA.Exam_TIN   
									  AND A.Measure_Num = PA.Measure_num AND
									   A.Patient_ID = PA.Patient_ID 
									  AND A.Criteria = @CRITERIA1
									  AND A.CPT_Code_Validation=1)



--eligible population FOR C1 AND C3
UPDATE PA
   SET PA.Is_EligiblePopulation=1
  -- , PA.Is_EligiblePopulation=1
  FROM #tmptbl_Physician_Aggregation_For_226 PA
 WHERE 
   --PA.CMS_Submission_Year = @intCurActiveYear   
   --AND PA.Physician_NPI = @NPI 
   --AND PA.Exam_TIN = @TIN   
   --AND PA.Measure_num = @strMeasure_num  AND
    PA.CPT_Code_Validation = 1
    AND (PA.Criteria=@CRITERIA1 OR PA.Criteria=@CRITERIA3)

--eligible population FOR C2
--UPDATE A
--   SET A.Is_EligiblePopulation=1
--  -- , PA.Is_EligiblePopulation=1
--  FROM  #tmptbl_Physician_Aggregation_For_226 A  
--                                                WHERE   
--                                                         --  A.CMS_Submission_Year=@intCurActiveYear
--                                                          --      AND A.Physician_NPI = @NPI 
--														  --AND  A.Exam_TIN = @TIN 
--																  --AND A.Measure_Num = @strMeasure_num 
--																   A.Criteria=@CRITERIA2 
--																-- AND A.Is_EligiblePopulation=1
--															     AND A.CPT_Code_Validation=1
--															      AND A.Patient_ID NOT IN (SELECT PA1.Patient_ID
--																		 FROM #tmptbl_Physician_Aggregation_For_226 PA1
--																		WHERE PA1.CMS_Submission_Year = A.CMS_Submission_Year    
--																		  AND PA1.Physician_NPI = A.Physician_NPI 
--																		  AND PA1.Exam_TIN = A.Exam_TIN
--																		  AND PA1.Measure_num = A.Measure_num
--																	     AND PA1.Patient_ID = A.Patient_ID
--																	     AND PA1.Criteria=@CRITERIA1
--																	     AND PA1.Is_Most_Recent_Exam=1
--																		  AND PA1.CPT_Code_Validation=A.CPT_Code_Validation
--																		   AND PA1.Numerator_Code<>@TubaccoUserCode


--	Populating C2 if C1 as tobacco user --																 );	 
UPDATE A
   SET A.Is_EligiblePopulation=1
  -- , PA.Is_EligiblePopulation=1
  FROM  #tmptbl_Physician_Aggregation_For_226 A  
                                                WHERE   
                                                         --  A.CMS_Submission_Year=@intCurActiveYear
                                                          --      AND A.Physician_NPI = @NPI 
														  --AND  A.Exam_TIN = @TIN 
																  --AND A.Measure_Num = @strMeasure_num 
																   A.Criteria=@CRITERIA2 
																-- AND A.Is_EligiblePopulation=1
															     AND A.CPT_Code_Validation=1
															    -- AND A.Is_Most_Recent_Exam=1 --Change#6
															      AND A.Patient_ID IN (SELECT DISTINCT PA1.Patient_ID
																		 FROM #tmptbl_Physician_Aggregation_For_226 PA1
																		WHERE PA1.CMS_Submission_Year = A.CMS_Submission_Year    
																		  AND PA1.Physician_NPI = A.Physician_NPI 
																		  AND PA1.Exam_TIN = A.Exam_TIN
																		  AND PA1.Measure_num = A.Measure_num
																	     AND PA1.Patient_ID = A.Patient_ID
																	     AND PA1.Criteria=@CRITERIA1
																	    -- AND PA1.Is_Most_Recent_Exam=1 --Change#6
																		  AND PA1.CPT_Code_Validation=A.CPT_Code_Validation
																		   AND PA1.Numerator_Code=@TubaccoUserCode
																		 );  
--	Populating C2 if  C1 NOT EXISTS 																	  
 UPDATE A
   SET A.Is_EligiblePopulation=1
  -- , PA.Is_EligiblePopulation=1
  FROM  #tmptbl_Physician_Aggregation_For_226 A  
                                                          WHERE   
                                                         --  A.CMS_Submission_Year=@intCurActiveYear
                                                          --      AND A.Physician_NPI = @NPI 
														  --AND  A.Exam_TIN = @TIN 
																  --AND A.Measure_Num = @strMeasure_num 
																   A.Criteria=@CRITERIA2 
																-- AND A.Is_EligiblePopulation=1
															     AND A.CPT_Code_Validation=1
															     AND (A.Is_EligiblePopulation IS NULL OR   A.Is_EligiblePopulation=0)
															      AND A.Patient_ID NOT IN (SELECT DISTINCT PA1.Patient_ID
																		 FROM #tmptbl_Physician_Aggregation_For_226 PA1
																		WHERE PA1.CMS_Submission_Year = A.CMS_Submission_Year    
																		  AND PA1.Physician_NPI = A.Physician_NPI 
																		  AND PA1.Exam_TIN = A.Exam_TIN
																		  AND PA1.Measure_num = A.Measure_num
																	     AND PA1.Patient_ID = A.Patient_ID
																	     AND PA1.Criteria=@CRITERIA1
																	     --AND PA1.Is_Most_Recent_Exam=1
																	     AND PA1.CPT_Code_Validation=A.CPT_Code_Validation
																	     );   



--------ISTOBACOO CONDITION
UPDATE PA
   SET PA.Is_TobaccoUser = 1
  FROM #tmptbl_Physician_Aggregation_For_226 PA
 WHERE 
 --PA.CMS_Submission_Year = @intCurActiveYear   
 --  AND PA.Physician_NPI = @NPI 
 --  AND PA.Exam_TIN = @TIN   
 --  AND PA.Measure_num = @strMeasure_num  AND 
   PA.CPT_Code_Validation = 1
   AND PA.Is_Most_Recent_Exam = 1
   AND PA.Criteria = @CRITERIA1
   AND PA.Numerator_Code = @TubaccoUserCode
   --AND EXISTS (SELECT 1 
			--	 FROM #tmptbl_Physician_Aggregation_For_226 PA1
			--	WHERE 
			--	PA1.CMS_Submission_Year = PA.CMS_Submission_Year    
			--	  AND PA1.Physician_NPI = PA.Physician_NPI 
			--	  AND PA1.Exam_TIN = PA.Exam_TIN
			--	  AND PA1.Measure_num = PA.Measure_num	 
			--	  AND PA1.Patient_ID = PA.Patient_ID
			--	  AND PA1.Is_Most_Recent_Exam=PA.Is_Most_Recent_Exam
			--	  AND PA1.Criteria = @CRITERIA3)
   

UPDATE PA
   SET PA.Criteria_Validation = 1,
       PA.Criteria_Validation_Message = 'Success: This patient exists the G9902 code,CRITERIA2 and CRITERIA3'
  FROM #tmptbl_Physician_Aggregation_For_226 PA
 WHERE 
 --PA.CMS_Submission_Year = @intCurActiveYear   
 --  AND PA.Physician_NPI = @NPI 
 --  AND PA.Exam_TIN = @TIN   
 --  AND PA.Measure_num = @strMeasure_num   AND 
  PA.CPT_Code_Validation = 1
   AND PA.Is_Most_Recent_Exam = 1
   AND EXISTS (SELECT 1 
				 FROM #tmptbl_Physician_Aggregation_For_226 PA1
				WHERE PA1.CMS_Submission_Year = PA.CMS_Submission_Year    
				  AND PA1.Physician_NPI = PA.Physician_NPI 
				  AND PA1.Exam_TIN = PA.Exam_TIN
				  AND PA1.Measure_num = PA.Measure_num
				  AND PA1.Patient_ID = PA.Patient_ID
				  AND PA1.Is_Most_Recent_Exam=PA.Is_Most_Recent_Exam
				 AND PA1.Is_TobaccoUser = 1
				  )
  AND EXISTS (SELECT 1 
				 FROM #tmptbl_Physician_Aggregation_For_226 PA2
				WHERE PA2.CMS_Submission_Year = PA.CMS_Submission_Year    
				  AND PA2.Physician_NPI = PA.Physician_NPI 
				  AND PA2.Exam_TIN = PA.Exam_TIN
				  AND PA2.Measure_num = PA.Measure_num
				  AND PA2.Patient_ID = PA.Patient_ID
				  AND PA2.Is_Most_Recent_Exam=PA.Is_Most_Recent_Exam
				  AND PA2.Criteria = @CRITERIA2)
				  
 AND EXISTS (SELECT 1 
				 FROM #tmptbl_Physician_Aggregation_For_226 PA2
				WHERE PA2.CMS_Submission_Year = PA.CMS_Submission_Year    
				  AND PA2.Physician_NPI = PA.Physician_NPI 
				  AND PA2.Exam_TIN = PA.Exam_TIN
				  AND PA2.Measure_num = PA.Measure_num
				  AND PA2.Patient_ID = PA.Patient_ID
				  AND PA2.Is_Most_Recent_Exam=PA.Is_Most_Recent_Exam
				  AND PA2.Criteria = @CRITERIA3)


UPDATE PA
   SET PA.Criteria_Validation = 0,
       PA.Criteria_Validation_Message = 'Failure: This patient exists the G9902 code but missing the CRITERIA2'
  FROM #tmptbl_Physician_Aggregation_For_226 PA
 WHERE 
 --PA.CMS_Submission_Year = @intCurActiveYear   
 --  AND PA.Physician_NPI = @NPI 
 --  AND PA.Exam_TIN = @TIN   
 --  AND PA.Measure_num = @strMeasure_num   AND 
   PA.CPT_Code_Validation = 1
   AND PA.Is_Most_Recent_Exam = 1
   AND PA.Criteria_Validation IS NULL
   AND EXISTS (SELECT 1 
				 FROM #tmptbl_Physician_Aggregation_For_226 PA1
				WHERE PA1.CMS_Submission_Year = PA.CMS_Submission_Year    
				  AND PA1.Physician_NPI = PA.Physician_NPI 
				  AND PA1.Exam_TIN = PA.Exam_TIN
				  AND PA1.Measure_num = PA.Measure_num
				  AND PA1.Patient_ID = PA.Patient_ID
				  AND PA1.Is_Most_Recent_Exam=PA.Is_Most_Recent_Exam
				 AND PA1.Is_TobaccoUser = 1
				  )
 AND EXISTS (SELECT 1 
				 FROM #tmptbl_Physician_Aggregation_For_226 PA2
				WHERE PA2.CMS_Submission_Year = PA.CMS_Submission_Year    
				  AND PA2.Physician_NPI = PA.Physician_NPI 
				  AND PA2.Exam_TIN = PA.Exam_TIN
				  AND PA2.Measure_num = PA.Measure_num
				  AND PA2.Patient_ID = PA.Patient_ID
				  AND PA2.Is_Most_Recent_Exam=PA.Is_Most_Recent_Exam
				  AND PA2.Criteria = @CRITERIA3)				  



UPDATE PA
   SET PA.Criteria_Validation = 1,
       PA.Criteria_Validation_Message = 'Success: Both CRITERIA1 and CRITERIA3 are exists with out G9902 code for this patient'
  FROM #tmptbl_Physician_Aggregation_For_226 PA
 WHERE 
 --PA.CMS_Submission_Year = @intCurActiveYear   
 --  AND PA.Physician_NPI = @NPI 
 --  AND PA.Exam_TIN = @TIN   
 --  AND PA.Measure_num = @strMeasure_num   AND
    PA.CPT_Code_Validation = 1
   AND PA.Is_Most_Recent_Exam = 1
   AND PA.Criteria_Validation IS NULL
   AND EXISTS (SELECT 1 
				 FROM #tmptbl_Physician_Aggregation_For_226 PA1
				WHERE PA1.CMS_Submission_Year = PA.CMS_Submission_Year    
				  AND PA1.Physician_NPI = PA.Physician_NPI 
				  AND PA1.Exam_TIN = PA.Exam_TIN
				  AND PA1.Measure_num = PA.Measure_num
				  AND PA1.Patient_ID = PA.Patient_ID
				  AND PA1.Is_Most_Recent_Exam=PA.Is_Most_Recent_Exam
				  AND PA1.Criteria = @CRITERIA3)

UPDATE PA
   SET PA.Criteria_Validation = 0,
       PA.Criteria_Validation_Message = 'Failure: Either CRITERIA1 or CRITERIA3 is missing for this patient'
  FROM #tmptbl_Physician_Aggregation_For_226 PA
 WHERE 
 --PA.CMS_Submission_Year = @intCurActiveYear   
 --  AND PA.Physician_NPI = @NPI 
 --  AND PA.Exam_TIN = @TIN   
 --  AND PA.Measure_num = @strMeasure_num   AND 
   PA.CPT_Code_Validation = 1
   AND PA.Is_Most_Recent_Exam = 1
   AND PA.Criteria_Validation IS NULL


--curser CUR_PatientIds Ended


--Step-6: Aggregation Calculation: Only considering the CRITERIA Validation "TRUE"

-------update c1 and c3 values for performance
UPDATE A 

SET Performance_Met=CASE WHEN  EXISTS(SELECT 1 from tbl_lookup_Numerator_Code where CMSYear=@intCurActiveYear and Measure_num=@strMeasure_num and Numerator_Code=A.Numerator_Code AND Performance_Met IN('Y','y')) THEN 1
                     ELSE 0 END
,Performance_NotMet=CASE WHEN EXISTS(SELECT 1 from tbl_lookup_Numerator_Code where CMSYear=@intCurActiveYear and Measure_num=@strMeasure_num and Numerator_Code=A.Numerator_Code AND Performance_Met IN('N','n')) THEN 1
                   ELSE 0 END
,Denominator_Exception=CASE WHEN  EXISTS(SELECT 1 from tbl_lookup_Numerator_Code where CMSYear=@intCurActiveYear and Measure_num=@strMeasure_num and Numerator_Code=A.Numerator_Code AND Denominator_Exceptions IN('Y','y')) THEN 1
                   ELSE 0 END
from #tmptbl_Physician_Aggregation_For_226 A 
where 
--A.CMS_Submission_Year=@intCurActiveYear   
--AND A.Physician_NPI = @NPI
-- AND   A.Exam_TIN = @TIN  
--  AND A.Measure_Num = @strMeasure_num  AND 
  A.CPT_Code_Validation=1
AND A.Is_Most_Recent_Exam=1
AND A.Criteria_Validation=1
AND (A.Criteria=@CRITERIA1 OR A.Criteria=@CRITERIA3)

-------update c2 values for performance
UPDATE A 

SET Performance_Met=CASE WHEN  EXISTS(SELECT 1 from tbl_lookup_Numerator_Code where CMSYear=@intCurActiveYear and Measure_num=@strMeasure_num and Numerator_Code=A.Numerator_Code AND Performance_Met IN('Y','y')) THEN 1
                     ELSE 0 END
,Performance_NotMet=CASE WHEN EXISTS(SELECT 1 from tbl_lookup_Numerator_Code where CMSYear=@intCurActiveYear and Measure_num=@strMeasure_num and Numerator_Code=A.Numerator_Code AND Performance_Met IN('N','n')) THEN 1
                   ELSE 0 END
,Denominator_Exception=CASE WHEN  EXISTS(SELECT 1 from tbl_lookup_Numerator_Code where CMSYear=@intCurActiveYear and Measure_num=@strMeasure_num and Numerator_Code=A.Numerator_Code AND Denominator_Exceptions IN('Y','y')) THEN 1
                   ELSE 0 END
from #tmptbl_Physician_Aggregation_For_226 A 
where 
--A.CMS_Submission_Year=@intCurActiveYear   
--AND A.Physician_NPI = @NPI
-- AND   A.Exam_TIN = @TIN  
--  AND A.Measure_Num = @strMeasure_num  AND 
  A.CPT_Code_Validation=1
AND A.Is_Most_Recent_Exam=1
AND A.Criteria_Validation=1
AND A.Is_EligiblePopulation=1
AND A.Criteria=@CRITERIA2
--AND  A.Patient_ID IN (SELECT PA1.Patient_ID	 FROM tbl_Physician_Aggregation_For_226 PA1
--																		WHERE PA1.CMS_Submission_Year = A.CMS_Submission_Year    
--																		  AND PA1.Physician_NPI = A.Physician_NPI 
--																		  AND PA1.Exam_TIN = A.Exam_TIN
--																		  AND PA1.Measure_num = A.Measure_num
--																	     AND PA1.Patient_ID = A.Patient_ID
--																	     AND PA1.Criteria=@CRITERIA1
--																		  AND PA1.Is_EligiblePopulation=A.Is_EligiblePopulation
--																		   AND PA1.Numerator_Code=@TubaccoUserCode
--																		 );	

-----eligible population for Criteria 2
--Update A   set A.Is_EligiblePopulation=1 FROM  #tmptbl_Physician_Aggregation_For_226 A  where   A.Criteria=@CRITERIA2 
--																  AND  A.CPT_Code_Validation=1 
--															      AND A.Criteria_Validation=1-----Means C1 & C3 exists.
															
-----eligible population for Criteria 1 and Criterta 3
--update A set A.Is_EligiblePopulation=1 from #tmptbl_Physician_Aggregation_For_226 A  where  A.CPT_Code_Validation=1 
--                                                                                  AND A.Criteria_Validation=1
--																  AND EXISTS(SELECT 1 
--																	    FROM #tmptbl_Physician_Aggregation_For_226 PA1
--																	   WHERE PA1.CMS_Submission_Year = A.CMS_Submission_Year    
--																		AND PA1.Physician_NPI = A.Physician_NPI 
--																		AND PA1.Exam_TIN = A.Exam_TIN
--																		AND PA1.Measure_num = A.Measure_num
--																		AND PA1.Patient_ID = A.Patient_ID
--																		and PA1.CPT_Code_Validation=A.CPT_Code_Validation
--																		AND PA1.Criteria = @CRITERIA3)
--																  AND EXISTS(SELECT 1 
--																	    FROM #tmptbl_Physician_Aggregation_For_226 PA1
--																	   WHERE PA1.CMS_Submission_Year = A.CMS_Submission_Year    
--																		AND PA1.Physician_NPI = A.Physician_NPI 
--																		AND PA1.Exam_TIN = A.Exam_TIN
--																		AND PA1.Measure_num = A.Measure_num
--																		AND PA1.Patient_ID = A.Patient_ID
--																		and PA1.CPT_Code_Validation=A.CPT_Code_Validation
--																		AND PA1.Criteria = @CRITERIA1)
																  

------------insert the validated temptable data into main table--
INSERT INTO tbl_Physician_Aggregation_For_226
select * from  #tmptbl_Physician_Aggregation_For_226


---after use of temp drop the table
DROP TABLE #tmptbl_Physician_Aggregation_For_226

----------------------*********** Validation Part Ends *******-----------------------------------------

END

----------------------***********Aggrigation Calculation Start *******-----------------------------------------

       --curser CUR_CRITERIAS startd

--DECLARE @intTotalCasesReviewed_C2 int
--DECLARE @blnHundredPercentSubmit_C2 bit

DECLARE @Cur_Stratum_Id int
DECLARE @Cur_Agg_Criteria varchar(20)
print('measure 226 related stratum line h444')	
DECLARE CUR_CRITERIAS CURSOR READ_ONLY FOR  
--
SELECT Stratum_Id,Criteria from tbl_Lookup_Stratum where Measure_Num=@strMeasure_num --and  Stratum_Id =CASE WHEN @isReqFromShedular <>1 then  4 ELSE Stratum_Id END;
OPEN CUR_CRITERIAS   

FETCH NEXT FROM CUR_CRITERIAS INTO @Cur_Stratum_Id,@Cur_Agg_Criteria

WHILE @@FETCH_STATUS = 0   
BEGIN 
--SET @intTotalCasesReviewed_C2=0;
--SET @blnHundredPercentSubmit_C2 =0;
SET @initPatientPopulation=0;
SET @blnSelectedForSubmission=0;
SET @blnHundredPercentSubmit=0;
print('measure 226 related stratum line h444s')	
	               SELECT                       @blnSelectedForSubmission = SelectedForSubmission ,
				                              @initPatientPopulation =CASE 
										                          WHEN @Cur_Agg_Criteria=@CRITERIA2 THEN TotalCasesReviewed_C2 
															--  WHEN @Cur_Agg_Criteria=@CRITERIA3 THEN TotalCasesReviewed_C3 
															  ELSE  TotalCasesReviewed END
										,@blnHundredPercentSubmit = CASE 
										                          WHEN @Cur_Agg_Criteria=@CRITERIA2 THEN isnull(HundredPercentSubmit_C2,0) 
															--  WHEN @Cur_Agg_Criteria=@CRITERIA3 THEN isnull(HundredPercentSubmit_C3,0)  
															  ELSE  isnull(HundredPercentSubmit,0)  END
				--@initPatientPopulation = CASE WHEN @Cur_Agg_Criteria=@CRITERIA2 then TotalCasesReviewed_C2 ELSE  TotalCasesReviewed END ,
				--@blnHundredPercentSubmit = HundredPercentSubmit,
				--@intTotalCasesReviewed_C2=TotalCasesReviewed_C2,
				--@blnHundredPercentSubmit_C2=HundredPercentSubmit_C2

		  FROM    dbo.tbl_Physician_Selected_Measures
		  WHERE   NPI = @NPI
				AND TIN = @TIN
				AND Submission_year = @intCurActiveYear
				AND Measure_num_ID = @strMeasure_num
				AND Is_Active=1 --Change #10
				AND Is_90Days=0 -- Change #11

                         
SET @TotalExamsCount=0;


  --SET @TotalExamsCount=( SELECT  COUNT(*)  FROM  tbl_Physician_Aggregation_For_226 A  where  A.CMS_Submission_Year=@intCurActiveYear
  --                                                                                AND A.Physician_NPI = @NPI 
		--														  AND  A.Exam_TIN = @TIN 
		--														  AND A.Measure_Num = @strMeasure_num 
		--														  AND A.Criteria=@Cur_Agg_Criteria 
		--														 AND A.Is_EligiblePopulation=1
		--														  )
																  
--SELECT @TotalExamsCount=COUNT(*) 
--FROM (
--SELECT  DISTINCT A.CMS_Submission_Year, A.Physician_NPI, A.Exam_TIN, A.Measure_Num, A.Patient_ID,  A.Criteria, A.Is_EligiblePopulation  
--                                                FROM  tbl_Physician_Aggregation_For_226 A  
--                                                WHERE  A.CMS_Submission_Year=@intCurActiveYear
--                                                                   AND A.Physician_NPI = @NPI 
--																  AND  A.Exam_TIN = @TIN 
--																  AND A.Measure_Num = @strMeasure_num 
--																  AND A.Criteria=@Cur_Agg_Criteria 
--																 AND A.Is_EligiblePopulation=1) AS TotalExamsCount;
																 

	IF(@Cur_Agg_Criteria=@CRITERIA2)		
	BEGIN
	SELECT @TotalExamsCount=COUNT( DISTINCT A.Patient_ID)  
                                                FROM  tbl_Physician_Aggregation_For_226 A  
                                                WHERE  A.CMS_Submission_Year=@intCurActiveYear
                                                                   AND A.Physician_NPI = @NPI 
																  AND  A.Exam_TIN = @TIN 
																  AND A.Measure_Num = @strMeasure_num 
																  AND A.Criteria=@Cur_Agg_Criteria 
																 AND A.Is_EligiblePopulation=1
															    -- AND A.Criteria_Validation=1----Change#4
															   --   AND A.Patient_ID NOT IN (SELECT PA1.Patient_ID
																		-- FROM tbl_Physician_Aggregation_For_226 PA1
																		--WHERE PA1.CMS_Submission_Year = A.CMS_Submission_Year    
																		--  AND PA1.Physician_NPI = A.Physician_NPI 
																		--  AND PA1.Exam_TIN = A.Exam_TIN
																		--  AND PA1.Measure_num = A.Measure_num
																	 --    AND PA1.Patient_ID = A.Patient_ID
																	 --    AND PA1.Criteria=@CRITERIA1
																		--  AND PA1.Is_EligiblePopulation=A.Is_EligiblePopulation
																		--   AND PA1.Numerator_Code<>@TubaccoUserCode
																		-- );	
	--   ----ONLY C2 EXISTS
 --                  SELECT @TotalExamsCount=COUNT( DISTINCT A.Patient_ID)  
 --                                                 FROM  tbl_Physician_Aggregation_For_226 A  
 --                                               WHERE  A.CMS_Submission_Year=@intCurActiveYear
 --                                                                  AND A.Physician_NPI = @NPI 
	--															  AND  A.Exam_TIN = @TIN 
	--															  AND A.Measure_Num = @strMeasure_num 
	--															--   AND A.Criteria<>@CRITERIA1 
	--															 -- AND A.Criteria<>@CRITERIA3 
	--														    AND A.Criteria=@CRITERIA2
	--															 AND A.Is_EligiblePopulation=1
	--															 AND A.Patient_ID NOT IN (SELECT PA1.Patient_ID
	--																	 FROM tbl_Physician_Aggregation_For_226 PA1
	--																	WHERE PA1.CMS_Submission_Year = A.CMS_Submission_Year    
	--																	  AND PA1.Physician_NPI = A.Physician_NPI 
	--																	  AND PA1.Exam_TIN = A.Exam_TIN
	--																	  AND PA1.Measure_num = A.Measure_num
	--																	--  AND PA1.Patient_ID = A.Patient_ID
	--																	  AND (PA1.Criteria=@CRITERIA1 OR PA1.Criteria=@CRITERIA3)
	--																	  AND PA1.Is_EligiblePopulation=A.Is_EligiblePopulation
	--																	 )
																		 
	---------ONLY C2 and C3
	--SELECT @TotalExamsCount+=COUNT( DISTINCT A.Patient_ID)  
 --                                               FROM  tbl_Physician_Aggregation_For_226 A  
 --                                               WHERE  A.CMS_Submission_Year=@intCurActiveYear
 --                                                                  AND A.Physician_NPI = @NPI 
	--															  AND  A.Exam_TIN = @TIN 
	--															  AND A.Measure_Num = @strMeasure_num 
	--															  AND A.Criteria=@CRITERIA2 
	--															 -- AND A.Criteria=@CRITERIA3 
	--															  AND A.Is_EligiblePopulation=1
	--															   AND EXISTS(SELECT 1 
	--																	 FROM tbl_Physician_Aggregation_For_226 PA1
	--																	WHERE PA1.CMS_Submission_Year = A.CMS_Submission_Year    
	--																	  AND PA1.Physician_NPI = A.Physician_NPI 
	--																	  AND PA1.Exam_TIN = A.Exam_TIN
	--																	  AND PA1.Measure_num = A.Measure_num
	--																	  AND PA1.Patient_ID = A.Patient_ID
	--																	  AND PA1.Criteria=@CRITERIA3
	--																	  AND PA1.Is_EligiblePopulation=A.Is_EligiblePopulation
	--																	 )
																		 
	--	-----Only	C1(tobacco) and C2
	--	SELECT @TotalExamsCount+=COUNT( DISTINCT A.Patient_ID)  
 --                                               FROM  tbl_Physician_Aggregation_For_226 A  
 --                                               WHERE  A.CMS_Submission_Year=@intCurActiveYear
 --                                                                  AND A.Physician_NPI = @NPI 
	--															  AND  A.Exam_TIN = @TIN 
	--															  AND A.Measure_Num = @strMeasure_num 
	--															  AND A.Criteria=@CRITERIA2 
	--															 -- AND A.Criteria=@CRITERIA3 
	--															  AND A.Is_EligiblePopulation=1
	--															   AND EXISTS(SELECT 1 
	--																	 FROM tbl_Physician_Aggregation_For_226 PA1
	--																	WHERE PA1.CMS_Submission_Year = A.CMS_Submission_Year    
	--																	  AND PA1.Physician_NPI = A.Physician_NPI 
	--																	  AND PA1.Exam_TIN = A.Exam_TIN
	--																	  AND PA1.Measure_num = A.Measure_num
	--																	  AND PA1.Patient_ID = A.Patient_ID
	--																	  AND PA1.Criteria=@CRITERIA1
	--																	  AND PA1.Is_EligiblePopulation=A.Is_EligiblePopulation
	--																	  AND PA1.Is_TobaccoUser=1
	--																	 )		
																		 
																		 
																		 													 
	
																		 
	END		
	
	ELSE
	BEGIN
	 ----ONLY C1 AND C3 EXISTS
	SELECT @TotalExamsCount=COUNT( DISTINCT A.Patient_ID)  
                                                FROM  tbl_Physician_Aggregation_For_226 A  
                                                WHERE  A.CMS_Submission_Year=@intCurActiveYear
                                                                   AND A.Physician_NPI = @NPI 
																  AND  A.Exam_TIN = @TIN 
																  AND A.Measure_Num = @strMeasure_num 
																  AND A.Criteria=@CRITERIA1 
																 -- AND A.Criteria=@CRITERIA3 
																  AND A.Is_EligiblePopulation=1
																   AND EXISTS(SELECT 1 
																		 FROM tbl_Physician_Aggregation_For_226 PA1
																		WHERE PA1.CMS_Submission_Year = A.CMS_Submission_Year    
																		  AND PA1.Physician_NPI = A.Physician_NPI 
																		  AND PA1.Exam_TIN = A.Exam_TIN
																		  AND PA1.Measure_num = A.Measure_num
																		  AND PA1.Patient_ID = A.Patient_ID
																		  AND PA1.Criteria=@CRITERIA3
																		  AND PA1.Is_EligiblePopulation=A.Is_EligiblePopulation
																		 )

				 ----ONLY C1 EXISTS
				SELECT @TotalExamsCount+=COUNT( DISTINCT A.Patient_ID)  
                                                FROM  tbl_Physician_Aggregation_For_226 A  
                                                WHERE  A.CMS_Submission_Year=@intCurActiveYear
                                                                   AND A.Physician_NPI = @NPI 
																  AND  A.Exam_TIN = @TIN 
																  AND A.Measure_Num = @strMeasure_num 
																  AND A.Criteria=@CRITERIA1 
																 -- AND A.Criteria<>@CRITERIA3 
																  AND A.Is_EligiblePopulation=1
																     AND A.Patient_ID NOT IN (SELECT PA1.Patient_ID
																		 FROM tbl_Physician_Aggregation_For_226 PA1
																		WHERE PA1.CMS_Submission_Year = A.CMS_Submission_Year    
																		  AND PA1.Physician_NPI = A.Physician_NPI 
																		  AND PA1.Exam_TIN = A.Exam_TIN
																		  AND PA1.Measure_num = A.Measure_num
																		--  AND PA1.Patient_ID = A.Patient_ID
																		  AND PA1.Criteria=@CRITERIA3
																		  AND PA1.Is_EligiblePopulation=A.Is_EligiblePopulation
																		 )
                      ----ONLY C3 EXISTS
                    SELECT @TotalExamsCount+=COUNT( DISTINCT A.Patient_ID)  
                                                FROM  tbl_Physician_Aggregation_For_226 A  
                                                WHERE  A.CMS_Submission_Year=@intCurActiveYear
                                                                   AND A.Physician_NPI = @NPI 
																  AND  A.Exam_TIN = @TIN 
																  AND A.Measure_Num = @strMeasure_num 
																 -- AND A.Criteria<>@CRITERIA1 
																  AND A.Criteria=@CRITERIA3 
																  AND A.Is_EligiblePopulation=1
																    AND A.Patient_ID NOT IN (SELECT PA1.Patient_ID
																		 FROM tbl_Physician_Aggregation_For_226 PA1
																		WHERE PA1.CMS_Submission_Year = A.CMS_Submission_Year    
																		  AND PA1.Physician_NPI = A.Physician_NPI 
																		  AND PA1.Exam_TIN = A.Exam_TIN
																		  AND PA1.Measure_num = A.Measure_num
																		--  AND PA1.Patient_ID = A.Patient_ID
																		  AND PA1.Criteria=@CRITERIA1
																		  AND PA1.Is_EligiblePopulation=A.Is_EligiblePopulation
																		 )
                ----ONLY C2 EXISTS
                   SELECT @TotalExamsCount+=COUNT( DISTINCT A.Patient_ID)  
                                                  FROM  tbl_Physician_Aggregation_For_226 A  
                                                WHERE  A.CMS_Submission_Year=@intCurActiveYear
                                                                   AND A.Physician_NPI = @NPI 
																  AND  A.Exam_TIN = @TIN 
																  AND A.Measure_Num = @strMeasure_num 
																--   AND A.Criteria<>@CRITERIA1 
																 -- AND A.Criteria<>@CRITERIA3 
															    AND A.Criteria=@CRITERIA2
																 AND A.Is_EligiblePopulation=1
																 AND A.Patient_ID NOT IN (SELECT PA1.Patient_ID
																		 FROM tbl_Physician_Aggregation_For_226 PA1
																		WHERE PA1.CMS_Submission_Year = A.CMS_Submission_Year    
																		  AND PA1.Physician_NPI = A.Physician_NPI 
																		  AND PA1.Exam_TIN = A.Exam_TIN
																		  AND PA1.Measure_num = A.Measure_num
																		--  AND PA1.Patient_ID = A.Patient_ID
																		  AND (PA1.Criteria=@CRITERIA1 OR PA1.Criteria=@CRITERIA3)
																		  AND PA1.Is_EligiblePopulation=A.Is_EligiblePopulation
																		 )




	END											 
	
--IF(@Cur_Agg_Criteria=@CRITERIA2)
--BEGIN



--  SET @TotalExamsCount=( SELECT  COUNT(*)  FROM  tbl_Physician_Aggregation_For_226 A  where  A.CMS_Submission_Year=@intCurActiveYear
--                                                                                  AND A.Physician_NPI = @NPI 
--																  AND  A.Exam_TIN = @TIN 
--																  AND A.Measure_Num = @strMeasure_num 
--																  AND A.Criteria=@Cur_Agg_Criteria 
--																 AND A.Is_EligiblePopulation=1
--																  )
	

--END

--ELSE
--BEGIN
--SET @TotalExamsCount= ( SELECT  COUNT(*)  FROM  tbl_Physician_Aggregation_For_226 A  where  A.CMS_Submission_Year=@intCurActiveYear
--                                                                                  AND A.Physician_NPI = @NPI 
--																  AND  A.Exam_TIN = @TIN 
--																  AND A.Measure_Num = @strMeasure_num 
--																  AND A.Criteria<>@CRITERIA2 
--																 AND A.Is_EligiblePopulation=1
--																  )
	
--END

               --IF ((@blnSelectedForSubmission = 1) AND( @blnHundredPercentSubmit = 1 or @blnHundredPercentSubmit_C2=1) )  
        IF(@blnHundredPercentSubmit = 1 )
	       BEGIN
              SET @initPatientPopulation = @TotalExamsCount;
         END

PRINT('Initial population : '+convert(varchar , @initPatientPopulation)+'@Cur_Agg_Criteria: '+@Cur_Agg_Criteria)


  --IF ( @blnSelectedForSubmission = 1 AND (@Cur_Agg_Criteria=@CRITERIA3 )OR @Cur_Agg_Criteria=@CRITERIA1) --THIS IS FOR OVERALL/screenedForUse --eligible population same for CRITERIA1 and CRITERIA3
  --   BEGIN
					
  --     IF ISNULL(@intTotalCasesReviewed, 0) > 0 
  --       BEGIN
  --        SET @initPatientPopulation = @intTotalCasesReviewed ;
		--			--select @initPatientPopulation as 'Init pop', @intTotalCasesReviewed as 'T Cases Received'
  --          END
  --         ELSE 
  --         IF ( @blnHundredPercentSubmit = 1 ) 
  --         BEGIN
  --            SET @initPatientPopulation = (SELECT COUNT(*) from tbl_Physician_Aggregation_For_226 A where  A.CMS_Submission_Year=@intCurActiveYear 
		--								                                                          AND A.Physician_NPI = @NPI 
		--																			   AND A.Exam_TIN = @TIN  
		--																			   AND A.Measure_Num = @strMeasure_num  
		--																			   AND A.CPT_Code_Validation=1
		--																			   AND A.Is_Most_Recent_Exam=1
		--																		    --AND A.Criteria_Validation=1
		--																			   AND A.Criteria=@Cur_Agg_Criteria) ;
  --       END
  --    END
  --ELSE IF ( @blnSelectedForSubmission = 1  AND  (@Cur_Agg_Criteria=@CRITERIA2 )) --this is for  CRITERIA2 :TODO:add new column in selected measure tables and maintain values for this
  --                                  BEGIN
					
  --                                    IF ISNULL(@intTotalCasesReviewed_C2, 0) > 0 
  --                                          BEGIN
  --                                              SET @initPatientPopulation = @intTotalCasesReviewed_C2 ;
		--			--select @initPatientPopulation as 'Init pop', @intTotalCasesReviewed as 'T Cases Received'
  --                                          END
  --                                      ELSE 
  --                                          IF ( @blnHundredPercentSubmit_C2 = 1 ) 
  --                                              BEGIN
  --                    SET @initPatientPopulation = (SELECT COUNT(*) from tbl_Physician_Aggregation_For_226 A where  A.CMS_Submission_Year=@intCurActiveYear 
		--		                                                                                            AND A.Physician_NPI = @NPI 
		--																				  AND A.Exam_TIN = @TIN  
		--																				  AND A.Measure_Num = @strMeasure_num  
		--																				  AND A.CPT_Code_Validation=1
		--																			       AND A.Is_Most_Recent_Exam=1
		--																			     --AND A.Criteria_Validation=1
		--																			      AND A.Criteria=@Cur_Agg_Criteria) ;
  --                                                END

		--					 END





SET  @ReportingDenominatorCount=0
SET @DenominatorExclusionCount=0--always 0 for this 226 measure
SET  @ReportingDenominatorCount = ISNULL(@initPatientPopulation,0) - @DenominatorExclusionCount;


  SET @performanceNumerator =0;
  SET @performanceMetCount=0;
  SET @performanceDenoCount=0;
  SET @performanceNotMetCount=0;


  SET @performanceMetCount=(SELECT COUNT(Distinct Patient_ID) from tbl_Physician_Aggregation_For_226 A  where  A.CMS_Submission_Year=@intCurActiveYear   AND A.Physician_NPI = @NPI AND
   A.Exam_TIN = @TIN   AND A.Measure_Num = @strMeasure_num AND A.Performance_Met=1  AND A.Criteria=@Cur_Agg_Criteria)

   SET @performanceNotMetCount=(SELECT COUNT(Distinct Patient_ID) from tbl_Physician_Aggregation_For_226 A  where  A.CMS_Submission_Year=@intCurActiveYear   AND A.Physician_NPI = @NPI AND
   A.Exam_TIN = @TIN   AND A.Measure_Num = @strMeasure_num AND A.Performance_NotMet=1 AND A.Criteria=@Cur_Agg_Criteria)



  SET @performanceDenoCount = @performanceMetCount  + @performanceNotMetCount ;	

SET @DenominatorExceptionCount=0;

SET @DenominatorExceptionCount=(SELECT COUNT(Distinct Patient_ID) from tbl_Physician_Aggregation_For_226 A  where  A.CMS_Submission_Year=@intCurActiveYear   AND A.Physician_NPI = @NPI AND
   A.Exam_TIN = @TIN   AND A.Measure_Num = @strMeasure_num AND A.Denominator_Exception=1 AND A.Criteria=@Cur_Agg_Criteria)


     SET @ReportingNumerator=0;
	
 SET @performanceNumerator = @performanceMetCount ;
		
  SET @ReportingNumerator = @performanceNumerator + ISNULL(@DenominatorExceptionCount, 0)  + @performanceNotMetCount ;
				
				--Print('@initPatientPopulation' +cast(@initPatientPopulation as varchar(20)))
				--Print('@performanceMetCount' +cast(@performanceMetCount as varchar(20)))
				--Print('@performanceNotMetCount' +cast(@performanceNotMetCount as varchar(20)))
			 --  Print('@DenominatorExceptionCount' +cast(@DenominatorExceptionCount as varchar(20)))
			 --    Print('@ReportingNumerator' +cast(@ReportingNumerator as varchar(20)))
                                IF ( ( @ReportingNumerator > 0 )
                                     AND ( ISNULL(@ReportingDenominatorCount,
                                                  0) > 0 )
                                   ) 
                                    BEGIN
						
                                        SET @reportingRate = CAST(@ReportingNumerator AS FLOAT)
                                            / @ReportingDenominatorCount ;
                                        SET @reportingRate = @reportingRate
                                            * 100 ;
                                    END


                                    IF ( @performanceNumerator >= 0 ) 
                                    BEGIN
                                        -- SET @performanceRate = @ReportingNumerator - @DenominatorExceptionCount ;
										-- King Lo 2/28/2015: variable name performanceDenominator is more appropriate than performanceRate
										
										SET @performanceDenominator = @ReportingNumerator - @DenominatorExceptionCount ;
										
										IF ( @performanceDenominator > 0 )
											BEGIN
												SET @performanceRate = ( CAST(@performanceNumerator AS FLOAT)
																		/ @performanceDenominator ) * 100 ;
											END
									    --<change#11> handle case when @performanceDenominator = 0
										 ELSE
										    BEGIN
												SET @performanceRate = NULL
											END
                                  END
								 	--<change#5>
								Else IF (( @performanceNumerator = 0 ) and ( @performanceDenominator > 0 ))
										Begin
												SET @performanceRate = ( CAST(0.00001 AS FLOAT))
										
										End
								--</change#5>
                        

                                SELECT  @Last_Encounter_Date = MAX(Exam_Date) ,
                                        @First_Encounter_date = MIN(Exam_Date)
                   FROM  tbl_Physician_Aggregation_For_226 A  where  A.CMS_Submission_Year=@intCurActiveYear   AND A.Physician_NPI = @NPI AND
   A.Exam_TIN = @TIN   AND A.Measure_Num = @strMeasure_num AND A.Criteria=@Cur_Agg_Criteria


   SET @benchmarkMet=null;

   
				

				    select @decile_Val= dbo.fnYearwiseDecileLogic(@strMeasure_num,@performanceRate,@intCurActiveYear,@reportingRate,@TotalExamsCount) 



                                    -----------Insert Query---------------

                                INSERT  INTO [dbo].[tbl_Physician_Aggregation_Year]
                                        ( [CMS_Submission_Year]  --1)        
                                          ,
                                          [Physician_NPI] --2)
                                          ,
                                          [Exam_TIN] --3)
                                          ,
                                          [Init_Patient_Population] --4)
                                          ,
                                          [Reporting_Denominator] -- 5a
                                          ,
                                          [Performance_denominator] --5)
                                          ,
                                          [Measure_Num] --6)
                                          ,
                                          [Strata_num]  -- 7)
                                          ,
                                          [SelectedForCMSSubmission] -- 8)
                                          ,
                                          [Denominator_Exceptions] --9)
                                          ,
                                          [Reporting_Numerator] -- 10a
                                          ,
                                          [Performance_Numerator] --10b
                                          ,
                                          [Denominator_Exclusions] --10d
                                          ,
                                          [Performance_Not_Met] --11)
                                          ,
                                          [Performance_Met]  -- 12)
                                          ,
                                          [Reporting_Rate] -- 13)
                                          ,
                                          [Performance_rate]  -- 14)
                                          ,
                                          [Created_Date] ,
                                          [Created_By] ,
                                          [Last_Mod_Date] ,
                                          [Last_Mod_By] ,
                                          [Encounter_From_Date] ,
                                          [Encounter_To_Date],
                                          [Benchmark_met],
										  [GPRO],
										  [Decile_Val]--23
										  ,[Is_90Days]
										  ,[TotalExamsCount] --Change #16
										  ,[Stratum_Id]--26
           
                                        )

							
                                VALUES  ( @intCurActiveYear  --1)         
                                          ,
                                          @NPI --2)
                                          ,
                                          @TIN --3)
                                          ,
                                          @initPatientPopulation --4)
                                          ,
                                          @ReportingDenominatorCount -- 5a
                                          ,
                                          @performanceDenoCount --5)
                                          ,
                                          @strMeasure_num --6)
                                          ,
                                          1 --7)
                                          ,
                                          @blnSelectedForSubmission -- 8)
                                          ,
                                          @DenominatorExceptionCount --9)
                                          ,
                                          @ReportingNumerator  --10a        
                                          ,
                                          @performanceNumerator --10b			
                                          ,
                                          @DenominatorExclusionCount --10d                 
                                          ,
                                          @performanceNotMetCount --11
                                          ,
                                          @performanceMetCount --12)
                                          ,
                                          CASE WHEN @reportingRate IS NULL
                                               THEN NULL
                                               WHEN @reportingRate = 0
                                               THEN NULL
                                               ELSE ROUND(@reportingRate, 2)
                                          END --13)
                                          ,
                                          CASE WHEN @performanceRate IS NULL
                                               THEN NULL
                                                WHEN @performanceRate = 0
                                               THEN NULL
                                               ELSE ROUND(@performanceRate, 2)
                                          END  --14)
                                          ,
                                          GETDATE() ,
                                          0 ,
                                          GETDATE() ,
                                          0 ,
                                          @First_Encounter_date ,
                                          @Last_Encounter_Date,
                                          @benchmarkMet,
										  @blnGPRO,
										  @decile_Val
										  ,0
										  ,@TotalExamsCount --Change #16
										  ,@Cur_Stratum_Id--26
                                        )
-- Change#8
IF(@reportingRate > 100)
BEGIN
										INSERT INTO [dbo].[tbl_ReportingRateGreaterThan100] 
										(Exam_TIN
										,Physician_NPI
										,Measure_Num
										,Original_Reporting_Denominator
										,Original_Reporting_Numerator
										,Original_Reporting_Rate
										,Reporting_Denominator
										,Reporting_Numerator,
										Reporting_Rate)
										VALUES
										(@TIN,
										@NPI,
										@strMeasure_num,
										@ReportingDenominatorCount,
										@ReportingNumerator,
										@reportingRate,
										@ReportingDenominatorCount,
										@ReportingNumerator,
										@reportingRate
										)
END
							
				
FETCH NEXT FROM CUR_CRITERIAS INTO @Cur_Stratum_Id,@Cur_Agg_Criteria
END   
CLOSE CUR_CRITERIAS   
DEALLOCATE CUR_CRITERIAS
		
                               
----------------------***********Aggrigation Calculation End *******-----------------------------------------



    END



