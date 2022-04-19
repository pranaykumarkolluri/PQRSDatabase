

-- =============================================
-- Author:		Hari J
-- Create date: 10th, OCT 2019
-- Description:	Used to calculate performance of measure 143 and physician
-- Change#1 : JIRA#973  , pranay on July 15,2021
-- =============================================

CREATE PROCEDURE [dbo].[spReCalculate_Measure143ForPhy] @NPI              VARCHAR(11),
                                                       @TIN              VARCHAR(10),
                                                       @intCurActiveYear INT,
                                                       @strMeasure_num   VARCHAR(50),
                                                       @blnGPRO          BIT
AS
    BEGIN
    DECLARE @initPatientPopulation AS INT;
    DECLARE @DenominatorExclusionCount AS INT;
    DECLARE @DenominatorExceptionCount AS INT;
    DECLARE @ReportingNumerator AS INT;
    DECLARE @ReportingDenominatorCount AS INT;
    DECLARE @performanceNumerator AS INT;
    DECLARE @performanceDenoCount AS INT;
    DECLARE @performanceMetCount AS INT;
    DECLARE @performanceNotMetCount AS INT;
    DECLARE @reportingRate AS FLOAT;
    DECLARE @performanceRate AS FLOAT;
    DECLARE @blnSelectedForSubmission BIT;
    DECLARE @intTotalCasesReviewed INT;
    DECLARE @blnHundredPercentSubmit BIT;
    DECLARE @First_Encounter_date DATETIME;
    DECLARE @Last_Encounter_Date DATETIME;
    DECLARE @performanceDenominator AS INT;
    DECLARE @benchmarkMet AS NVARCHAR(1);
    DECLARE @decile_Val AS VARCHAR(100);
    DECLARE @TotalExamsCount INT;
    DECLARE @Agg_Id INT;
    DECLARE @CRITERIA1 VARCHAR(30)= 'CRITERIA1';
    DECLARE @CRITERIA2 VARCHAR(30)= 'CRITERIA2';
    PRINT('measure 143 related stratum line 59');
    DELETE FROM tbl_Physician_Aggregation_Year
    WHERE CMS_Submission_Year = @intCurActiveYear
          AND Physician_NPI = @NPI
          AND Exam_TIN = @TIN
          AND Measure_num = @strMeasure_num
          AND Is_90Days = 0;


----------------------*********** Validation Part Start *******-----------------------------------------


--STEP #0: Delete previous data
    DELETE FROM tbl_Physician_Aggregation_For_143
    WHERE CMS_Submission_Year = @intCurActiveYear
          AND Physician_NPI = @NPI
          AND Exam_TIN = @TIN
          AND Measure_num = @strMeasure_num;
    PRINT('measure 143 related stratum line 68');
    IF OBJECT_ID('tempdb..#tmptbl_Physician_Aggregation_For_143') IS NOT NULL
        DROP TABLE #tmptbl_Physician_Aggregation_For_143;
    CREATE TABLE #tmptbl_Physician_Aggregation_For_143
([Physician_NPI]         [VARCHAR](50) NULL,
 [Exam_TIN]              [VARCHAR](10) NULL,
 [Patient_ID]            [VARCHAR](500) NULL,
 [Exam_Date]             [DATETIME] NULL,
 [CMS_Submission_Year]   [INT] NULL,
 [Measure_ID]            [INT] NULL,
 [Measure_Num]           [VARCHAR](50) NULL,
 [Denominator_proc_code] [VARCHAR](50) NULL,
 [Numerator_Code]        [VARCHAR](100) NULL,
 [Created_Date]          [DATETIME] NULL,
 [Created_By]            [VARCHAR](50) NULL,
 [Criteria]              [VARCHAR](20) NULL,
 [IsMain_ProcCode]       [BIT] NULL,
 [Performance_Met]       [BIT] NULL,
 [Performance_NotMet]    [BIT] NULL,
 [Denominator_Exception] [BIT] NULL,
 [Is_EligiblePopulation] [BIT] NULL,
 [Is_ValidRecord]        [BIT] NULL,
 [Validation_Msg]        [VARCHAR](500) NULL,
 [IS_PreDateExist]       [BIT] NULL,
 [IS_PostDateExist]      [BIT] NULL,
);


--STEP #1: Insert Raw Data
    INSERT INTO #tmptbl_Physician_Aggregation_For_143
([Physician_NPI],
 [Exam_TIN],
 [Patient_ID],
 [Exam_Date],
 [CMS_Submission_Year],
 [Measure_ID],
 [Measure_Num],
 [Denominator_proc_code],
 [Numerator_Code],
 [Created_Date],
 [Created_By]
      --,[Criteria]
      --,[IsMain_ProcCode]
      --,[Performance_Met]
      --,[Performance_NotMet]
      --,[Denominator_Exception]
      --,[Is_EligiblePopulation]
      --,[Is_ValidRecord]
      --,[Validation_Msg]
	--   ,[IS_PreDateExist]
    --  ,[IS_PostDateExist]
)
           SELECT e.Physician_NPI,
                  e.Exam_TIN,
                  e.Patient_ID,
                  e.Exam_Date,
                  e.CMS_Submission_Year,
                  md.Measure_ID,
                  N.Measure_num,
                  md.Denominator_proc_code,
                  md.Numerator_Code,
                  e.Created_Date,
                  e.Created_By
           FROM tbl_Exam e WITH (NOLOCK)
                INNER JOIN tbl_Exam_Measure_Data md WITH (NOLOCK) ON md.Exam_Id = e.Exam_Id
                INNER JOIN tbl_Lookup_Measure N WITH (NOLOCK) ON N.Measure_ID = md.Measure_ID
           WHERE e.CMS_Submission_Year = @intCurActiveYear
                 AND N.CMSYear = @intCurActiveYear
                 AND e.Physician_NPI = @NPI
                 AND e.Exam_TIN = @TIN
                 AND N.Measure_num = @strMeasure_num
                 AND md.[Status] IN(2, 3)
                AND (e.Exam_Date IS NULL
                     OR e.Exam_Date <> '');



  --#STEP 2:populate Criteria and Main Procedure Code

    UPDATE A
      SET
          --A.Denominator_proc_code = P.Proc_code,
          A.IsMain_ProcCode = P.IsMain_ProcCode,
          A.Criteria = P.Proc_Criteria
    FROM #tmptbl_Physician_Aggregation_For_143 A
         INNER JOIN tbl_lookup_Denominator_Proc_Code P ON A.Measure_ID = P.Measure_ID
                                                          AND A.Denominator_proc_code = P.Proc_code;
--STEP 2.1: Checking main cpt in active year

  Update #tmptbl_Physician_Aggregation_For_143 
    SET Is_ValidRecord=0,
         IsMain_ProcCode=0,
        Validation_Msg='Main cpt is not in current active year'
        where IsMain_ProcCode =1 
        and   (YEAR(Exam_Date) > @intCurActiveYear OR YEAR(Exam_Date) < @intCurActiveYear )
        
        
 --#STEP 3: NO Validation Required for Criteria2 and directly eligible for Performance

    UPDATE #tmptbl_Physician_Aggregation_For_143
      SET
          Is_EligiblePopulation = 1,
          Is_ValidRecord = 1
    WHERE Criteria = @CRITERIA2 
    and   Is_ValidRecord is null 
    AND (Validation_Msg is NULL  OR Validation_Msg='') 
          


--STEP#4: Check  Pre 30days  EXISTS of Main Procedure code 

    UPDATE A
      SET
          A.IS_PreDateExist = 1
    FROM #tmptbl_Physician_Aggregation_For_143 A
    WHERE A.IsMain_ProcCode = 1
          AND EXISTS
(
    SELECT 1
    FROM #tmptbl_Physician_Aggregation_For_143 B
    WHERE A.Exam_TIN = B.Exam_TIN
          AND A.Physician_NPI = B.Physician_NPI
          AND A.Patient_ID = B.Patient_ID
          AND B.Criteria = @CRITERIA1
          AND (B.IsMain_ProcCode IS NULL
               OR B.IsMain_ProcCode = 0)
          AND B.Exam_Date BETWEEN DATEADD(DAY, -30, A.Exam_Date) AND A.Exam_Date--Before 30 Days
);


--STEP#5: Check  Post 30days of Main Procedure code 


    UPDATE A
      SET
          A.IS_PostDateExist = 1
    FROM #tmptbl_Physician_Aggregation_For_143 A
    WHERE A.IsMain_ProcCode = 1
          AND EXISTS
(
    SELECT 1
    FROM #tmptbl_Physician_Aggregation_For_143 B
    WHERE A.Exam_TIN = B.Exam_TIN
          AND A.Physician_NPI = B.Physician_NPI
          AND A.Patient_ID = B.Patient_ID
          AND B.Criteria = @CRITERIA1
          AND (B.IsMain_ProcCode IS NULL
               OR B.IsMain_ProcCode = 0)
          AND B.Exam_Date BETWEEN A.Exam_Date AND DATEADD(DAY, 30, A.Exam_Date)---After 30 Days
);

--STEP #6 'Pre and Post Dates Exam Data not exists'
    UPDATE A
      SET
          A.Validation_Msg = 'Pre and Post Exam Date Data not exists',
          A.Is_ValidRecord = 0
    FROM #tmptbl_Physician_Aggregation_For_143 A
    WHERE A.IsMain_ProcCode = 1
          AND A.Criteria = @CRITERIA1
          AND (A.IS_PostDateExist IS NULL
               OR A.IS_PostDateExist = 0)
          AND (A.IS_PreDateExist IS NULL
               OR A.IS_PreDateExist = 0);
                 
  --STEP #7 'Pre Exam Date Data not exists'
    UPDATE A
      SET
          A.Validation_Msg = 'Pre Exam Date Data not exists',
          A.Is_ValidRecord = 0
    FROM #tmptbl_Physician_Aggregation_For_143 A
    WHERE A.IsMain_ProcCode = 1
          AND A.Criteria = @CRITERIA1
          AND (A.IS_PreDateExist IS NULL
               OR A.IS_PreDateExist = 0)
          AND (A.IS_PostDateExist=1 );
		                    
  --STEP #7 'POST Exam Date Data not exists'
    UPDATE A
      SET
          A.Validation_Msg = 'Post Exam Date Data not exists',
          A.Is_ValidRecord = 0
    FROM #tmptbl_Physician_Aggregation_For_143 A
    WHERE A.IsMain_ProcCode = 1
          AND A.Criteria = @CRITERIA1
          AND (A.IS_PostDateExist IS NULL
               OR A.IS_PostDateExist = 0)
          AND (A.IS_PreDateExist=1);

       

--Populate eligible population for Criteria 1

    UPDATE A
      SET
          A.Is_EligiblePopulation = 1,
          A.Is_ValidRecord = 1
    FROM #tmptbl_Physician_Aggregation_For_143 A
    WHERE A.IsMain_ProcCode = 1
          AND A.Criteria = @CRITERIA1
          AND A.IS_PostDateExist = 1
          AND A.IS_PreDateExist = 1;


--Populate Performance Met 


    UPDATE A
      SET
          Performance_Met = CASE
                                WHEN EXISTS
(
    SELECT 1
    FROM tbl_lookup_Numerator_Code
    WHERE CMSYear = @intCurActiveYear
          AND Measure_num = @strMeasure_num
          AND Numerator_Code = A.Numerator_Code
          AND Performance_Met IN('Y', 'y')
)
                                THEN 1
                                ELSE 0
                            END,
          Performance_NotMet = CASE
                                   WHEN EXISTS
(
    SELECT 1
    FROM tbl_lookup_Numerator_Code
    WHERE CMSYear = @intCurActiveYear
          AND Measure_num = @strMeasure_num
          AND Numerator_Code = A.Numerator_Code
          AND Performance_Met IN('N', 'n')
)
                                   THEN 1
                                   ELSE 0
                               END,
          Denominator_Exception = CASE
                                      WHEN EXISTS
(
    SELECT 1
    FROM tbl_lookup_Numerator_Code
    WHERE CMSYear = @intCurActiveYear
          AND Measure_num = @strMeasure_num
          AND Numerator_Code = A.Numerator_Code
          AND Denominator_Exceptions IN('Y', 'y')
)
                                      THEN 1
                                      ELSE 0
                                  END
    FROM #tmptbl_Physician_Aggregation_For_143 A
    WHERE Is_EligiblePopulation = 1;




------------insert the validated temptable data into main table--
    INSERT INTO tbl_Physician_Aggregation_For_143
           SELECT *
           FROM #tmptbl_Physician_Aggregation_For_143;

---------------Validation END--------------



---------------Aggrigation Starts----------------------------------------
   
    SET @initPatientPopulation = 0;
    SET @blnSelectedForSubmission = 0;
    SET @blnHundredPercentSubmit = 0;
    PRINT('measure 143 related stratum line h444s');
    SELECT @blnSelectedForSubmission = SelectedForSubmission,
           @initPatientPopulation = TotalCasesReviewed,
           @blnHundredPercentSubmit = isnull(HundredPercentSubmit, 0)
    FROM dbo.tbl_Physician_Selected_Measures
    WHERE NPI = @NPI
          AND TIN = @TIN
          AND Submission_year = @intCurActiveYear
          AND Measure_num_ID = @strMeasure_num
          AND Is_Active = 1 --Change #10
          AND Is_90Days = 0; -- Change #11


    SET @TotalExamsCount = 0;
    SELECT @TotalExamsCount = COUNT(1)
    FROM tbl_Physician_Aggregation_For_143 A
    WHERE A.CMS_Submission_Year = @intCurActiveYear
          AND A.Physician_NPI = @NPI
          AND A.Exam_TIN = @TIN
          AND A.Measure_Num = @strMeasure_num
          AND A.Is_EligiblePopulation = 1;
    IF(@blnHundredPercentSubmit = 1)
        BEGIN
            SET @initPatientPopulation = @TotalExamsCount;
        END;
    SET @ReportingDenominatorCount = 0;
    SET @DenominatorExclusionCount = 0;--always 0 for this 226 measure
    SET @ReportingDenominatorCount = ISNULL(@initPatientPopulation, 0) - @DenominatorExclusionCount;
    SET @performanceNumerator = 0;
    SET @performanceMetCount = 0;
    SET @performanceDenoCount = 0;
    SET @performanceNotMetCount = 0;
    SET @performanceMetCount =
(
    SELECT COUNT(1)
    FROM tbl_Physician_Aggregation_For_143 A
    WHERE A.CMS_Submission_Year = @intCurActiveYear
          AND A.Physician_NPI = @NPI
          AND A.Exam_TIN = @TIN
          AND A.Measure_Num = @strMeasure_num
          AND A.Performance_Met = 1
       
);
    SET @performanceNotMetCount =
(
    SELECT COUNT(1)
    FROM tbl_Physician_Aggregation_For_143 A
    WHERE A.CMS_Submission_Year = @intCurActiveYear
          AND A.Physician_NPI = @NPI
          AND A.Exam_TIN = @TIN
          AND A.Measure_Num = @strMeasure_num
          AND A.Performance_NotMet = 1
         
);
    SET @performanceDenoCount = @performanceMetCount + @performanceNotMetCount;
    SET @DenominatorExceptionCount = 0;
    SET @DenominatorExceptionCount =
(
    SELECT COUNT(1)
    FROM tbl_Physician_Aggregation_For_143 A
    WHERE A.CMS_Submission_Year = @intCurActiveYear
          AND A.Physician_NPI = @NPI
          AND A.Exam_TIN = @TIN
          AND A.Measure_Num = @strMeasure_num
          AND A.Denominator_Exception = 1
        
);
    SET @ReportingNumerator = 0;
    SET @performanceNumerator = @performanceMetCount;
    SET @ReportingNumerator = @performanceNumerator + ISNULL(@DenominatorExceptionCount, 0) + @performanceNotMetCount;

    IF((@ReportingNumerator > 0)
       AND (ISNULL(@ReportingDenominatorCount, 0) > 0))
        BEGIN
            SET @reportingRate = CAST(@ReportingNumerator AS FLOAT) / @ReportingDenominatorCount;
            SET @reportingRate = @reportingRate * 100;
        END;
    IF(@performanceNumerator >= 0)
        BEGIN
                     
            SET @performanceDenominator = @ReportingNumerator - @DenominatorExceptionCount;
            IF(@performanceDenominator > 0)
                BEGIN
                    SET @performanceRate = (CAST(@performanceNumerator AS FLOAT) / @performanceDenominator) * 100;
                END
									
                ELSE
                BEGIN
                    SET @performanceRate = NULL;
                END;
        END
								 	
        ELSE
    IF((@performanceNumerator = 0)
       AND (@performanceDenominator > 0))
        BEGIN
            SET @performanceRate = (CAST(0.00001 AS FLOAT));
        END;
								--</change#5>


    SELECT @Last_Encounter_Date = MAX(Exam_Date),
           @First_Encounter_date = MIN(Exam_Date)
    FROM tbl_Physician_Aggregation_For_143 A
    WHERE A.CMS_Submission_Year = @intCurActiveYear
          AND A.Physician_NPI = @NPI
          AND A.Exam_TIN = @TIN
          AND A.Measure_Num = @strMeasure_num
       AND A.Is_EligiblePopulation=1
    SET @benchmarkMet = NULL;
    SELECT @decile_Val = dbo.fnYearwiseDecileLogic(@strMeasure_num, @performanceRate, @intCurActiveYear, @reportingRate, @TotalExamsCount); 

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
										--  ,[Stratum_Id]--26
           
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
										  --,@Cur_Stratum_Id--26
                                        )
-- Change#1
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
							

---------------Aggrigation Ends----------------------------------------		

END;


