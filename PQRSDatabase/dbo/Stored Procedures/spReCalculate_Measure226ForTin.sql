

    -- =============================================
    -- Author:		Hari J
    -- Create date: 27th,Dec,2018
    -- Description:	Used to calculate performance of measure 226 and TIN
	-- Change#1 : JIRA#973  , pranay on July 15,2021

    -- =============================================

    CREATE PROCEDURE [dbo].[spReCalculate_Measure226ForTin]

    @strCurTIN varchar(10),
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
		--  DECLARE @performanceDenoCount AS INT
		  DECLARE @performanceMetCount AS INT	
		  DECLARE @performanceNotMetCount AS INT
	    --   DECLARE @strMeasure_num AS VARCHAR(20) ;


		  DECLARE @reportingRate AS FLOAT ;
		  DECLARE @performanceRate AS FLOAT ;


		  DECLARE @blnSelectedForSubmission BIT
		  DECLARE @intTotalCasesReviewed INT
		  DECLARE @intGPROTotalCasesReviewed INT
		  DECLARE @blnHundredPercentSubmit BIT

		  DECLARE @First_Encounter_date DATETIME
		  DECLARE @Last_Encounter_Date DATETIME
		
		    -- King Lo 2/28/2015
		    DECLARE @performanceDenominator AS INT;
		
		    DECLARE @benchmarkMet AS NVARCHAR(1);
	

		    --Hari 1/5-2018 for decilevalue

		    DECLARE @decile_Val as varchar(100);

		    declare @TotalExamsCount int ;
		    DECLARE @totalPhysiansSubmittedCount INT
		

	--	DECLARE @intTotalCasesReviewed_C2 int
--DECLARE @blnHundredPercentSubmit_C2 bit

DECLARE @CRITERIA1 varchar(30) = 'CRITERIA1'
DECLARE @CRITERIA2 varchar(30) = 'CRITERIA2'
DECLARE @CRITERIA3 varchar(30) = 'CRITERIA3'


delete from tbl_TIN_Aggregation_Year where Exam_TIN=@strCurTIN 
and Measure_Num=@strMeasure_num 
and CMS_Submission_Year=@intCurActiveYear
and Is_90Days=0
 --and  Stratum_Id =CASE WHEN @isReqFromShedular <>1 then  4 ELSE Stratum_Id END;
    ----------------------***********Aggrigation Calculation Start *******-----------------------------------------

		 --curser CUR_CRITERIAS startd


    DECLARE @Cur_Stratum_Id int
    DECLARE @Cur_Agg_Criteria varchar(20)

    DECLARE CUR_CRITERIAS CURSOR READ_ONLY FOR  
    --
    SELECT Stratum_Id,Criteria from tbl_Lookup_Stratum where Measure_Num=@strMeasure_num 

    OPEN CUR_CRITERIAS   

    FETCH NEXT FROM CUR_CRITERIAS INTO @Cur_Stratum_Id,@Cur_Agg_Criteria

    WHILE @@FETCH_STATUS = 0   
    BEGIN 
    set @intTotalCasesReviewed =0;
								
									

									    --print 'physician count='+Convert(varchar, @totalPhysiansSubmittedCount)+'cms year='+Convert(varchar,@intCurActiveYear)+ 'Tin ='+@strCurTIN + 'measure num='+@strMeasure_num;
--SET @TotalExamsCount=( SELECT  COUNT(*) 
--                   FROM  tbl_Physician_Aggregation_For_226 A  where  A.CMS_Submission_Year=@intCurActiveYear
--                      AND A.Exam_TIN = @strCurTIN  
--                       AND A.Measure_Num = @strMeasure_num 
--                       AND A.Criteria=@Cur_Agg_Criteria
--                       AND A.CPT_Code_Validation=1
--                       AND 
--                     ---  AND A.Criteria_Validation=1
--                       )
--SELECT @TotalExamsCount=COUNT(*) 
--FROM (
--SELECT  DISTINCT A.CMS_Submission_Year, A.Physician_NPI, A.Exam_TIN, A.Measure_Num, A.Patient_ID,  A.Criteria, A.Is_EligiblePopulation  
--                                                FROM  tbl_Physician_Aggregation_For_226 A  
--                                                WHERE  A.CMS_Submission_Year=@intCurActiveYear
                                                                 
--																  AND  A.Exam_TIN = @strCurTIN 
--																  AND A.Measure_Num = @strMeasure_num 
--																  AND A.Criteria=@Cur_Agg_Criteria 
--																 AND A.Is_EligiblePopulation=1) AS TotalExamsCount;
	IF(@Cur_Agg_Criteria=@CRITERIA2)		
	BEGIN
	SELECT @TotalExamsCount=COUNT( DISTINCT A.Patient_ID)  
                                                FROM  tbl_Physician_Aggregation_For_226 A  
                                                WHERE  A.CMS_Submission_Year=@intCurActiveYear
                                                                 --  AND A.Physician_NPI = @NPI 
																  AND  A.Exam_TIN = @strCurTIN
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
																		--   AND PA1.Numerator_Code<>'G9902'
																		-- );	
	END		
	
	ELSE
	BEGIN
	 ----ONLY C1 AND C3 EXISTS
	SELECT @TotalExamsCount=COUNT( DISTINCT A.Patient_ID)  
                                                FROM  tbl_Physician_Aggregation_For_226 A  
                                                WHERE  A.CMS_Submission_Year=@intCurActiveYear
                                                                  -- AND A.Physician_NPI = @NPI 
																  AND  A.Exam_TIN = @strCurTIN 
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
                                                                 --- AND A.Physician_NPI = @NPI 
																  AND  A.Exam_TIN =@strCurTIN 
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
                                                                  -- AND A.Physician_NPI = @NPI 
																  AND  A.Exam_TIN = @strCurTIN 
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
                                                                   --AND A.Physician_NPI = @NPI 
																  AND  A.Exam_TIN = @strCurTIN  
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
	
  SET @totalPhysiansSubmittedCount=( SELECT  COUNT(Distinct A.Physician_NPI) 
                   FROM  tbl_Physician_Aggregation_For_226 A  where  A.CMS_Submission_Year=@intCurActiveYear
                      AND A.Exam_TIN = @strCurTIN  
                       AND A.Measure_Num = @strMeasure_num 
                       AND A.Criteria=@Cur_Agg_Criteria
                      -- AND A.Criteria_Validation=1
                       );
 

										-- Default its selected some time back
										SET @blnSelectedForSubmission = 0 ;
										SET @intTotalCasesReviewed = NULL ;
										SET @blnHundredPercentSubmit = 0 ;		
									--	SET @intTotalCasesReviewed_C2 = NULL ;
										--SET @blnHundredPercentSubmit_C2 = 0 ;						
							

										SELECT @blnSelectedForSubmission = isnull(g.SelectedForSubmission,0)
										,@intTotalCasesReviewed =CASE 
										                          WHEN @Cur_Agg_Criteria=@CRITERIA2 THEN g.TotalCasesReviewed_C2 
															 -- WHEN @Cur_Agg_Criteria=@CRITERIA3 THEN g.TotalCasesReviewed_C3 
															  ELSE  g.TotalCasesReviewed END
										,@blnHundredPercentSubmit = CASE 
										                          WHEN @Cur_Agg_Criteria=@CRITERIA2 THEN isnull(g.HundredPercentSubmit_C2,0) 
															--  WHEN @Cur_Agg_Criteria=@CRITERIA3 THEN isnull(g.HundredPercentSubmit_C3,0)  
															  ELSE  isnull(g.HundredPercentSubmit,0)  END
										
										
										
										--,@intTotalCasesReviewed_C2 = g.TotalCasesReviewed_C2
										--,@blnHundredPercentSubmit_C2 = isnull(g.HundredPercentSubmit_C2,0) 
										FROM    [dbo].[tbl_GPRO_TIN_Selected_Measures] g
										WHERE g.TIN = @strCurTIN
										AND  g.Submission_year= @intCurActiveYear
										AND g.Measure_Num = @strMeasure_num 
										  and g.Is_Active=1 -- Change #14
										  and g.Is_90Days=0 -- Change #15 

IF(@blnHundredPercentSubmit=1)
BEGIN
select @initPatientPopulation =@TotalExamsCount;

END

--------------Ended initial population ------------


										    -- Display for testing
										    --select 'false' as [GPRO] , @intTotalCasesReviewed as 'TINcases Total', @intCurActiveYear as [year],@strCurTIN as [tin], @strMeasure_num as [measure_Num]

										     IF ( @ReportingDenominatorCount < 1 ) 
										    BEGIN
											    SET @ReportingDenominatorCount = NULL ;
										    END

										    set @performanceDenominator = 0;
										      set @performanceNumerator = 0;
											 set @performanceNotMetCount = 0;
											 set @performanceMetCount = 0;
											  set @DenominatorExclusionCount =0;
											   set @DenominatorExceptionCount=0;
										    set @ReportingNumerator = 0;

										    select @ReportingNumerator=sum(isnull(Reporting_Numerator,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										    where a.Exam_TIN =@strCurTIN 
										    and a.Measure_Num = @strMeasure_num 
										    and a.CMS_Submission_Year = @intCurActiveYear
										    and a.Is_90Days=0
										    AND a.Stratum_Id=@Cur_Stratum_Id

							
									   
										    select @performanceDenominator =sum(isnull(Performance_denominator,0))
										    ,@performanceNumerator =sum(isnull(Performance_Numerator,0))
										    ,@performanceNotMetCount =sum(isnull(Performance_Not_Met,0))
										    ,@performanceMetCount =sum(isnull(Performance_Met,0))
										    ,@Last_Encounter_Date = MAX(Encounter_To_Date) ,
								    @First_Encounter_date = MIN(Encounter_From_Date)
								   , @DenominatorExclusionCount =sum(isnull(Denominator_Exclusions,0))
								   ,@DenominatorExceptionCount =sum(isnull(Denominator_Exceptions,0))
										    
										     from  dbo.tbl_Physician_Aggregation_Year a 
										    where a.Exam_TIN =@strCurTIN 
										    and a.Measure_Num = @strMeasure_num 
										    and a.CMS_Submission_Year = @intCurActiveYear
										    and a.Is_90Days=0 
										     AND a.Stratum_Id=@Cur_Stratum_Id								  
										
								 SET @ReportingDenominatorCount = @initPatientPopulation - @DenominatorExclusionCount ;		
								
								    -- @ReportingNumerator
								    --select @ReportingNumerator as ReportingNumerator,@ReportingDenominatorCount as ReportingDenominatorCount

								    --<change#12> initialize @reportingRate
								    SET @reportingRate = NULL
								    --</change#12>
								    IF ( ( @ReportingNumerator > 0 ) 
										AND ( ISNULL(@ReportingDenominatorCount, 0) > 0 )
							    ) 
								BEGIN
											
								    SET @reportingRate = CAST(@ReportingNumerator AS FLOAT)/@ReportingDenominatorCount ;											
								    SET @reportingRate = @reportingRate * 100.00 ;								
										
								END

							 --<change#12> initialize @performanceRate
								    SET @performanceRate = NULL
								    --</change#12>

							 IF ( @performanceNumerator >= 0 ) 
								BEGIN
								    -- SET @performanceRate = @ReportingNumerator - @DenominatorExceptionCount ;
										    -- King Lo 2/28/2015: variable name performanceDenominator is more appropriate than performanceRate
										
										    SET @performanceDenominator = @ReportingNumerator - @DenominatorExceptionCount ;
	
										    IF ( @performanceDenominator > 0 )
											    BEGIN
												    SET @performanceRate = ( CAST(@performanceNumerator AS FLOAT)/ @performanceDenominator ) * 100 ;
											    END
										   --<change#11> handle case when @performanceDenominator = 0
											ELSE
											   BEGIN
												    SET @performanceRate = NULL
											    END
										    --</change#11>
							 END
								    --<change#8>
								    Else IF (( @performanceNumerator = 0 ) and ( @performanceDenominator > 0 ))
										    Begin
												    SET @performanceRate = ( CAST(0.00001 AS FLOAT))
										    End
			
				    select @decile_Val= dbo.fnYearwiseDecileLogic(@strMeasure_num,@performanceRate,@intCurActiveYear,@reportingRate,@TotalExamsCount) 

-- Insert into tbl_TIN_Aggregation_year  from PQRS Aggregated
										INSERT INTO [dbo].[tbl_TIN_Aggregation_Year]
											   ([CMS_Submission_Year] --1											 
											   ,[Exam_TIN] --2
											   ,[Measure_Num] --3
											   ,[Strata_num] --4
											   ,[SelectedForCMSSubmission] --5
											   ,[GPRO] --6
											   ,[Init_Patient_Population] --7
											   ,[Reporting_Denominator] --8
											   ,[Reporting_Numerator] --9
											   ,[Exclusion] --10
											   ,[Performance_denominator] --11
											   ,[Performance_Numerator] --12
											   ,[Denominator_Exceptions] --13
											   ,[Denominator_Exclusions] --14
											   ,[Performance_Not_Met] --15
											   ,[Performance_Met] --16
											   ,[Reporting_Rate] --17
											   ,[Performance_rate] --18
											   ,[Created_Date] --19
											   ,[Created_By] -- 20
											   ,[Last_Mod_Date] -- 21
											   ,[Last_Mod_By] -- 22
											   ,[Encounter_From_Date] --23
											   ,[Encounter_To_Date] --24
											   ,[Benchmark_met] ,--25
											   [Decile_Val]--26
											   ,[Is_90Days] -- Change #15
											   ,[TotalExamsCount] --Change #16
											   ,[totalPhysiansSubmittedCount] --Change #17
											   ,Stratum_Id
											   )
										 VALUES
											   ( @intCurActiveYear --1											  
											   ,@strCurTIN --2
											   ,@strMeasure_num --3
											   , 1 --4 <Strata_num, int,>
											   ,@blnSelectedForSubmission --5<SelectedForCMSSubmission, bit,>
											   , @blnGPRO --6 <GPRO, int,>
											   ,@initPatientPopulation --7 <Init_Patient_Population, int,>
											   ,@ReportingDenominatorCount --8<Reporting_Denominator, int,>
											   ,@ReportingNumerator --9 <Reporting_Numerator, int,>
											   ,1 -- 10 <Exclusion, int,>
											   ,isnull(@performanceDenominator,0) -- 11 <Performance_denominator, int,>
											   ,@performanceNumerator --12 <Performance_Numerator, int,>
											   ,@DenominatorExceptionCount --13 <Denominator_Exceptions, int,>
											   ,@DenominatorExclusionCount -- 14 <Denominator_Exclusions, int,>
											   ,@performanceNotMetCount -- 15 <Performance_Not_Met, int,>
											   ,@performanceMetCount -- 16<Performance_Met, int,>
											   , CASE WHEN @ReportingNumerator IS NULL
														 THEN NULL
													 --WHEN @performanceRate = 0
														--THEN NULL
													 ELSE ROUND(@reportingRate*1.000, 2)
													END-- 17<Reporting_Rate, decimal(18,4),>
											   , CASE WHEN @performanceRate IS NULL
														THEN NULL
													 --WHEN @performanceRate = 0
														--THEN NULL
													ELSE ROUND(@performanceRate*1.000, 2)
												END -- 18<Performance_rate, decimal(18,4),>
											   ,getdate() --<Created_Date, datetime,>
											   ,0--<Created_By, int,>
											   ,getdate() --<Last_Mod_Date, datetime,>
											   ,0 --<Last_Mod_By, int,>
											   , @First_Encounter_date ,
                                          @Last_Encounter_Date,
                                          @benchmarkMet,
								  @decile_Val --26
								  ,0 -- Change #15
								  ,@TotalExamsCount --Change #16
								  ,@totalPhysiansSubmittedCount --Change #17
								   ,@Cur_Stratum_Id
								  )

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
					,Reporting_Rate)
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

				
    FETCH NEXT FROM CUR_CRITERIAS INTO @Cur_Stratum_Id,@Cur_Agg_Criteria
    END   
    CLOSE CUR_CRITERIAS   
    DEALLOCATE CUR_CRITERIAS
		
                               
    ----------------------***********Aggrigation Calculation End *******-----------------------------------------



	   END

