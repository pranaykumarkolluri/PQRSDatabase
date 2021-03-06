


    -- =============================================
    -- Author:		Hari J
    -- Create date: 10th Oct,2019
    -- Description:	Used to calculate performance of measure 143 and TIN
	-- Change#1 : JIRA#973  , pranay on July 15,2021

    -- =============================================

CREATE PROCEDURE [dbo].[spReCalculate_Measure143ForTin] @strCurTIN         VARCHAR(10),
                                                       @intCurActiveYear  INT,
                                                       @strMeasure_num    VARCHAR(50),
                                                       @blnGPRO           BIT,
                                                       @isReqFromShedular BIT         = 1
AS
         BEGIN
             DECLARE @initPatientPopulation AS INT;
             DECLARE @DenominatorExclusionCount AS INT;
             DECLARE @DenominatorExceptionCount AS INT;
             DECLARE @ReportingNumerator AS INT;
             DECLARE @ReportingDenominatorCount AS INT;
             DECLARE @performanceNumerator AS INT;
		--  DECLARE @performanceDenoCount AS INT
             DECLARE @performanceMetCount AS INT;
             DECLARE @performanceNotMetCount AS INT;
	    --   DECLARE @strMeasure_num AS VARCHAR(20) ;


             DECLARE @reportingRate AS FLOAT;
             DECLARE @performanceRate AS FLOAT;
             DECLARE @blnSelectedForSubmission BIT;
             DECLARE @intTotalCasesReviewed INT;
             DECLARE @intGPROTotalCasesReviewed INT;
             DECLARE @blnHundredPercentSubmit BIT;
             DECLARE @First_Encounter_date DATETIME;
             DECLARE @Last_Encounter_Date DATETIME;
		
		    -- King Lo 2/28/2015
             DECLARE @performanceDenominator AS INT;
             DECLARE @benchmarkMet AS NVARCHAR(1);
	

		    --Hari 1/5-2018 for decilevalue

             DECLARE @decile_Val AS VARCHAR(100);
             DECLARE @TotalExamsCount INT;
             DECLARE @totalPhysiansSubmittedCount INT;

             DECLARE @CRITERIA1 VARCHAR(30)= 'CRITERIA1';
             DECLARE @CRITERIA2 VARCHAR(30)= 'CRITERIA2';
             DECLARE @CRITERIA3 VARCHAR(30)= 'CRITERIA3';
             DELETE FROM tbl_TIN_Aggregation_Year
             WHERE Exam_TIN = @strCurTIN
                   AND Measure_Num = @strMeasure_num
                   AND CMS_Submission_Year = @intCurActiveYear
                   AND Is_90Days = 0;
    ----------------------***********Aggrigation Calculation Start *******-----------------------------------------


             SET @intTotalCasesReviewed = 0;
             SELECT @TotalExamsCount = COUNT(1)
             FROM tbl_Physician_Aggregation_For_143 A
             WHERE A.CMS_Submission_Year = @intCurActiveYear
                   AND A.Exam_TIN = @strCurTIN
                   AND A.Measure_Num = @strMeasure_num
                   AND A.Is_EligiblePopulation = 1;
             SET @totalPhysiansSubmittedCount =
(
    SELECT COUNT(DISTINCT A.Physician_NPI)
    FROM tbl_Physician_Aggregation_For_143 A
    WHERE A.CMS_Submission_Year = @intCurActiveYear
          AND A.Exam_TIN = @strCurTIN
          AND A.Measure_Num = @strMeasure_num
);
 

										-- Default its selected some time back
             SET @blnSelectedForSubmission = 0;
             SET @intTotalCasesReviewed = NULL;
             SET @blnHundredPercentSubmit = 0;		
									--	SET @intTotalCasesReviewed_C2 = NULL ;
										--SET @blnHundredPercentSubmit_C2 = 0 ;						


             SELECT @blnSelectedForSubmission = isnull(g.SelectedForSubmission, 0),
                    @intTotalCasesReviewed = g.TotalCasesReviewed,
                    @blnHundredPercentSubmit = isnull(g.HundredPercentSubmit, 0)
             FROM [dbo].[tbl_GPRO_TIN_Selected_Measures] g
             WHERE g.TIN = @strCurTIN
                   AND g.Submission_year = @intCurActiveYear
                   AND g.Measure_Num = @strMeasure_num
                   AND g.Is_Active = 1 -- Change #14
                   AND g.Is_90Days = 0; -- Change #15 

             IF(@blnHundredPercentSubmit = 1)
                 BEGIN
                     SELECT @initPatientPopulation = @TotalExamsCount;
                 END;

--------------Ended initial population ------------


             IF(@ReportingDenominatorCount < 1)
                 BEGIN
                     SET @ReportingDenominatorCount = NULL;
                 END;
             SET @performanceDenominator = 0;
             SET @performanceNumerator = 0;
             SET @performanceNotMetCount = 0;
             SET @performanceMetCount = 0;
             SET @DenominatorExclusionCount = 0;
             SET @DenominatorExceptionCount = 0;
             SET @ReportingNumerator = 0;
             SELECT @ReportingNumerator = SUM(isnull(Reporting_Numerator, 0))
             FROM dbo.tbl_Physician_Aggregation_Year a
             WHERE a.Exam_TIN = @strCurTIN
                   AND a.Measure_Num = @strMeasure_num
                   AND a.CMS_Submission_Year = @intCurActiveYear
                   AND a.Is_90Days = 0;
             SELECT @performanceDenominator = SUM(isnull(Performance_denominator, 0)),
                    @performanceNumerator = SUM(isnull(Performance_Numerator, 0)),
                    @performanceNotMetCount = SUM(isnull(Performance_Not_Met, 0)),
                    @performanceMetCount = SUM(isnull(Performance_Met, 0)),
                    @Last_Encounter_Date = MAX(Encounter_To_Date),
                    @First_Encounter_date = MIN(Encounter_From_Date),
                    @DenominatorExclusionCount = SUM(isnull(Denominator_Exclusions, 0)),
                    @DenominatorExceptionCount = SUM(isnull(Denominator_Exceptions, 0))
             FROM dbo.tbl_Physician_Aggregation_Year a
             WHERE a.Exam_TIN = @strCurTIN
                   AND a.Measure_Num = @strMeasure_num
                   AND a.CMS_Submission_Year = @intCurActiveYear
                   AND a.Is_90Days = 0;
             SET @ReportingDenominatorCount = @initPatientPopulation - @DenominatorExclusionCount;		
								
								 
             SET @reportingRate = NULL;
								    --</change#12>
             IF((@ReportingNumerator > 0)
                AND (ISNULL(@ReportingDenominatorCount, 0) > 0))
                 BEGIN
                     SET @reportingRate = CAST(@ReportingNumerator AS FLOAT) / @ReportingDenominatorCount;
                     SET @reportingRate = @reportingRate * 100.00;
                 END;

							 --<change#12> initialize @performanceRate
             SET @performanceRate = NULL;
								    --</change#12>

             IF(@performanceNumerator >= 0)
                 BEGIN
					
                     SET @performanceDenominator = @ReportingNumerator - @DenominatorExceptionCount;
                     IF(@performanceDenominator > 0)
                         BEGIN
                             SET @performanceRate = (CAST(@performanceNumerator AS FLOAT) / @performanceDenominator) * 100;
                         END
										   --<change#11> handle case when @performanceDenominator = 0;
                         ELSE
                         BEGIN
                             SET @performanceRate = NULL;
                         END;
										    --</change#11>
                 END
								    --<change#8>;
                 ELSE
             IF((@performanceNumerator = 0)
                AND (@performanceDenominator > 0))
                 BEGIN
                     SET @performanceRate = (CAST(0.00001 AS FLOAT));
                 END;
             SELECT @decile_Val = dbo.fnYearwiseDecileLogic(@strMeasure_num, @performanceRate, @intCurActiveYear, @reportingRate, @TotalExamsCount); 

-- Insert into tbl_TIN_Aggregation_year  from PQRS Aggregated
             INSERT INTO [dbo].[tbl_TIN_Aggregation_Year]
([CMS_Submission_Year], --1											  
 [Exam_TIN], --2 
 [Measure_Num], --3 
 [Strata_num], --4 
 [SelectedForCMSSubmission], --5 
 [GPRO], --6 
 [Init_Patient_Population], --7 
 [Reporting_Denominator], --8 
 [Reporting_Numerator], --9 
 [Exclusion], --10 
 [Performance_denominator], --11 
 [Performance_Numerator], --12 
 [Denominator_Exceptions], --13 
 [Denominator_Exclusions], --14 
 [Performance_Not_Met], --15 
 [Performance_Met], --16 
 [Reporting_Rate], --17 
 [Performance_rate], --18 
 [Created_Date], --19 
 [Created_By], -- 20 
 [Last_Mod_Date], -- 21 
 [Last_Mod_By], -- 22 
 [Encounter_From_Date], --23 
 [Encounter_To_Date], --24 
 [Benchmark_met], --25
 [Decile_Val], --26 
 [Is_90Days], -- Change #15 
 [TotalExamsCount], --Change #16 
 [totalPhysiansSubmittedCount] --Change #17
											 
)
             VALUES
(@intCurActiveYear, --1											   
 @strCurTIN, --2 
 @strMeasure_num, --3 
 1, --4 <Strata_num, int,> 
 @blnSelectedForSubmission, --5<SelectedForCMSSubmission, bit,> 
 @blnGPRO, --6 <GPRO, int,> 
 @initPatientPopulation, --7 <Init_Patient_Population, int,> 
 @ReportingDenominatorCount, --8<Reporting_Denominator, int,> 
 @ReportingNumerator, --9 <Reporting_Numerator, int,> 
 1, -- 10 <Exclusion, int,> 
 isnull(@performanceDenominator, 0), -- 11 <Performance_denominator, int,> 
 @performanceNumerator, --12 <Performance_Numerator, int,> 
 @DenominatorExceptionCount, --13 <Denominator_Exceptions, int,> 
 @DenominatorExclusionCount, -- 14 <Denominator_Exclusions, int,> 
 @performanceNotMetCount, -- 15 <Performance_Not_Met, int,> 
 @performanceMetCount, -- 16<Performance_Met, int,>
 CASE
     WHEN @ReportingNumerator IS NULL
     THEN NULL
													 --WHEN @performanceRate = 0
														--THEN NULL
     ELSE ROUND(@reportingRate * 1.000, 2)
 END, -- 17<Reporting_Rate, decimal(18,4),>
 CASE
     WHEN @performanceRate IS NULL
     THEN NULL
													 --WHEN @performanceRate = 0
														--THEN NULL
     ELSE ROUND(@performanceRate * 1.000, 2)
 END, -- 18<Performance_rate, decimal(18,4),> 
 GETDATE(), --<Created_Date, datetime,> 
 0, --<Created_By, int,> 
 GETDATE(), --<Last_Mod_Date, datetime,> 
 0, --<Last_Mod_By, int,> 
 @First_Encounter_date,
 @Last_Encounter_Date,
 @benchmarkMet,
 @decile_Val, --26 
 0, -- Change #15 
 @TotalExamsCount, --Change #16 
 @totalPhysiansSubmittedCount --Change #17
								  
);

-- Change#1
IF (@reportingRate > 100)
BEGIN
					INSERT INTO [dbo].[tbl_ReportingRateGreaterThan100] 
					(Exam_TIN,Physician_NPI
					,Measure_Num
					,Original_Reporting_Denominator
					,Original_Reporting_Numerator,
					Original_Reporting_Rate
					,Reporting_Denominator
					,Reporting_Numerator
					,Reporting_Rate
					)
					VALUES(
					@strCurTIN,
					'--',
					@strMeasure_num,
					@ReportingDenominatorCount,
					@ReportingNumerator,
					@reportingRate,
					@ReportingDenominatorCount,
					@ReportingNumerator,
					@reportingRate					
					)
END
	
    ----------------------***********Aggrigation Calculation End *******-----------------------------------------



         END;


