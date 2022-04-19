




-- =============================================
-- Author:		harikrishna
--created Date:Nov,12th,2018
--used to calculate performance for stratum measures based on AGE
-- Change #23: by hari :on Dec 12th, 2018
-- Change #23 JIRA#609
-- =============================================
CREATE PROCEDURE [dbo].[spReCalculate_StratumCalbyAgeforTIN] 
	-- Add the parameters for the stored procedure here
    @intCurActiveYear INT = 0 ,
  
    @strCurTIN varchar(50),
    @intCurMeasureId int,
   -- @blnSelectedForSubmission BIT,
    @strMeasure_num AS VARCHAR(20) ,
    @blnGPRO bit

AS 
    BEGIN
	-- 	DECLARE @intCurActiveYear AS INT
     --   DECLARE @intCurMeasureId AS INT

        DECLARE @intCurAggregationID AS INT
        DECLARE @strCurMeasure_num AS VARCHAR(20) ;


        DECLARE @intCurUserID AS INT
        --DECLARE @strCurNPI AS VARCHAR(10)
      --  DECLARE @strCurTIN AS VARCHAR(10)
		-- DECLARE @strMeasure_num AS VARCHAR(20) ;
		DECLARE @intTotalCasesReviewed as int;
		DECLARE @intGPROTotalCasesReviewed as int;

		DECLARE @initPatientPopulation AS INT
        DECLARE @totalValReportedCount AS INT
        DECLARE @DenominatorExclusionCount AS INT
        DECLARE @DenominatorExceptionCount AS INT
        DECLARE @ReportingNumerator AS INT
		DECLARE @performanceDenominator AS INT;		

        DECLARE @ReportingDenominatorCount AS INT

        DECLARE @performanceNumerator AS INT
        DECLARE @performanceDenoCount AS INT
        DECLARE @performanceMetCount AS INT	
        DECLARE @performanceNotMetCount AS INT
      

        DECLARE @intStrataNum AS INT ;

        DECLARE @reportingRate AS FLOAT ;
        DECLARE @performanceRate AS FLOAT ;

		DECLARE @First_Encounter_date DATETIME
        DECLARE @Last_Encounter_Date DATETIME

			-- King Lo 2/28/2015
		
		DECLARE @benchmarkMet AS NVARCHAR(1);
		--DECLARE @blnGPRO	as bit;


		 DECLARE @blnSelectedForSubmission BIT       
			DECLARE @blnHundredPercentSubmit BIT

			--Hari 1/5-2018 for decilevalue

		DECLARE @decile_Val as varchar(100);
		--added by raju g
			declare @TotalExamsCount int;
		DECLARE @totalPhysiansSubmittedCount int;
	
		DECLARE @CurStart_Age int ;
         DECLARE @CurEnd_Age int ;
		DECLARE @CurStratum_Id int ;


--Step#2 Get NPI's and TIN
		
				--Step#5 Calculate performance rate count count of this measure
				
			    
                                SET @initPatientPopulation = NULL ;
                                SET @totalValReportedCount = 0
                                SET @DenominatorExclusionCount = 0
                                SET @DenominatorExceptionCount = 0
				
                                SET @ReportingNumerator = 0 ; 
                                SET @ReportingDenominatorCount = NULL ;
				
                                SET @performanceNumerator = 0 ;
                                SET @performanceDenoCount = 0
				
                                SET @performanceMetCount = 0
                                SET @performanceNotMetCount = 0
				
                                SET @reportingRate = NULL ;
                                SET @performanceRate = NULL ;
								
								SET @performanceDenominator = NULL;
								
								SET @benchmarkMet = NULL;
				
				SET @TotalExamsCount =0; --Change #16
				
				print('measure 46 related stratum code:Before CURSUR')
				---STRATUM CURSUR Starts---
				 DECLARE CurStratum CURSOR FOR 
	
        SELECT s.Start_Age ,s.End_Age,s.Stratum_Id from tbl_Lookup_Stratum s inner join tbl_Lookup_Measure m

	   on s.Measure_Num=m.Measure_num where m.Measure_ID=@intCurMeasureId and m.CMSYear=@intCurActiveYear

        OPEN CurStratum

			FETCH NEXT FROM CurStratum 	INTO @CurStart_Age,@CurEnd_Age,@CurStratum_Id

        WHILE @@FETCH_STATUS = 0 
            BEGIN
		
		print('measure 46 related stratum code:inside  CURSUR')
		
									-- Step#4 Get info for received measure is selected for CMS submission		
								--IF selected by physician then get from tbl_Physician_Selected_Measures
								--addeby raju g
							set @intTotalCasesReviewed =0;
								
									
										  set  @totalPhysiansSubmittedCount=0;  --Change #17
										--  set  @totalPhysiansSubmittedCount=@intTotalCasesReviewed; --Change #17
										select @totalPhysiansSubmittedCount= count(*) from (select e.Physician_NPI from tbl_Exam e inner join
															 tbl_Exam_Measure_Data d on d.Exam_Id = e.Exam_Id 
																where Exam_TIN = @strCurTIN  and e.CMS_Submission_Year = @intCurActiveYear
																-- Change #15
															and d.Measure_ID in 
																( select top 1 m.Measure_ID from tbl_Lookup_Measure m 
																	where m.Measure_num = @strMeasure_num and  m.CMSYear = @intCurActiveYear
																		
																)
																AND e.Patient_Age >= @CurStart_Age
							                                            AND e.Patient_Age <= @CurEnd_Age
															and status =2
															group by e.Physician_NPI
															having COUNT(e.Physician_NPI) > 0)x
									--print 'physician count='+Convert(varchar, @totalPhysiansSubmittedCount)+'cms year='+Convert(varchar,@intCurActiveYear)+ 'Tin ='+@strCurTIN + 'measure num='+@strMeasure_num;

                                IF EXISTS 	( SELECT  1
                                            FROM    dbo.tbl_Physician_Selected_Measures
                                            WHERE   --NPI = @strCurNPI AND
													TIN = @strCurTIN
                                                    AND Submission_year = @intCurActiveYear
                                                    AND Measure_num_ID = @strMeasure_num 
										    and Is_Active=1 -- Change #14
										    and Is_90Days=0 -- Change #15
													) 
										BEGIN
                                       SET @intTotalCasesReviewed = 0;
									   set @TotalExamsCount=0; --Change #16

									   IF @blnGPRO = 1
										   BEGIN
									   
										   SELECT @blnSelectedForSubmission = isnull(g.SelectedForSubmission,0)
											,@intGPROTotalCasesReviewed = g.TotalCasesReviewed
											,@blnHundredPercentSubmit = isnull(g.HundredPercentSubmit,0) 
											FROM    [dbo].[tbl_GPRO_TIN_Selected_Measures] g
											WHERE g.TIN = @strCurTIN
											AND  g.Submission_year= @intCurActiveYear
											AND g.Measure_Num = @strMeasure_num 
											  and g.Is_Active=1 -- Change #14
											   and g.Is_90Days=0 -- Change #15
										   End	

										select 
										@intTotalCasesReviewed = @intTotalCasesReviewed + 
										isnull (case HundredPercentSubmit
										when 1 then (
											select count(*) from tbl_Exam e inner join
															 tbl_Exam_Measure_Data d on d.Exam_Id = e.Exam_Id 
																where Exam_TIN = @strCurTIN  and e.CMS_Submission_Year = @intCurActiveYear
															and d.Measure_ID in 
																( select top 1 m.Measure_ID from tbl_Lookup_Measure m 
																	where m.Measure_num = @strMeasure_num and  m.CMSYear = @intCurActiveYear
																		
																)
																AND e.Patient_Age >= @CurStart_Age
								                                         AND e.Patient_Age <= @CurEnd_Age
															and status in(2,3)
															and  e.[Physician_NPI] = tbl_Physician_Selected_Measures.npi
										 )
										else TotalCasesReviewed end,000) 
										from  tbl_Physician_Selected_Measures where Measure_num_ID = @strMeasure_num and Submission_year = @intCurActiveYear
										and tbl_Physician_Selected_Measures.TIN = @strCurTIN
										 and Is_Active=1 -- Change #14
										   and Is_90Days=0 -- Change #15

										--  set  @totalPhysiansSubmittedCount=0;  --Change #17
										--  set  @totalPhysiansSubmittedCount=@intTotalCasesReviewed; --Change #17


										  ----------------------Started--Change #16----------------------
										 	select @TotalExamsCount=count(*) from tbl_Exam e inner join
															 tbl_Exam_Measure_Data d on d.Exam_Id = e.Exam_Id 
																where Exam_TIN = @strCurTIN  and e.CMS_Submission_Year = @intCurActiveYear
															and d.Measure_ID in 
																( select top 1 m.Measure_ID from tbl_Lookup_Measure m 
																	where m.Measure_num = @strMeasure_num and  m.CMSYear = @intCurActiveYear
																	
																)
																AND e.Patient_Age >= @CurStart_Age
								                                       AND e.Patient_Age <= @CurEnd_Age
															and status in(2,3)
                                              -------------------------------Ended--Change #16-----------------------
										-- set @TotalExamsCount=@intTotalCasesReviewed; --Change #16
										 IF ISNULL(@intTotalCasesReviewed, 0) > 0 
                                            BEGIN
                                                SET @initPatientPopulation = @intTotalCasesReviewed ;										
                                            END

											if @blnGPRO = 1
											Begin
											  if @blnHundredPercentSubmit =0  and isnull(@intGPROTotalCasesReviewed,0) > 0
											  Begin
											  set @initPatientPopulation = isnull(@intGPROTotalCasesReviewed,0)
											  end
											End


										-- Display for testing
										--select 'false' as [GPRO] , @intTotalCasesReviewed as 'TINcases Total', @intCurActiveYear as [year],@strCurTIN as [tin], @strMeasure_num as [measure_Num]



										set @ReportingNumerator = 0;
										select @ReportingNumerator=sum(isnull(Reporting_Numerator,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										and a.Is_90Days=0 -- Change #15
										and a.Stratum_Id=@CurStratum_Id

							    --<change#4>
								--  set reportingDenominator
                                IF ISNULL(@initPatientPopulation, 0) > 0 
                                    BEGIN
										
											set @DenominatorExclusionCount =0;
											select @DenominatorExclusionCount =sum(isnull(Denominator_Exclusions,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										and a.Is_90Days=0 -- Change #15
										and a.Stratum_Id=@CurStratum_Id


											set @DenominatorExceptionCount=0;

										select @DenominatorExceptionCount =sum(isnull(Denominator_Exceptions,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										  and a.Is_90Days=0 -- Change #15
										and a.Stratum_Id=@CurStratum_Id


									   SET @ReportingDenominatorCount = @initPatientPopulation - @DenominatorExclusionCount ;
                                    END
                                 --</change#4>
									
									
									IF ( @ReportingDenominatorCount < 1 ) 
										BEGIN
											SET @ReportingDenominatorCount = NULL ;
										END

										set @performanceDenominator = 0;
										select @performanceDenominator =sum(isnull(Performance_denominator,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										and a.Is_90Days=0 -- Change #15
										and a.Stratum_Id=@CurStratum_Id

										set @performanceNumerator = 0;
										select @performanceNumerator =sum(isnull(Performance_Numerator,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										and a.Is_90Days=0 -- Change #15
										and a.Stratum_Id=@CurStratum_Id
									

									


										set @performanceNotMetCount = 0;
										select  @performanceNotMetCount =sum(isnull(Performance_Not_Met,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										  and a.Is_90Days=0 -- Change #15
										  and a.Stratum_Id=@CurStratum_Id


										set @performanceMetCount = 0;
										select  @performanceMetCount =sum(isnull(Performance_Met,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=0 -- Change #15
										 and a.Stratum_Id=@CurStratum_Id

										 SELECT  @Last_Encounter_Date = MAX(Encounter_To_Date) ,
                                        @First_Encounter_date = MIN(Encounter_From_Date)
										from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=0 -- Change #15
										 and a.Stratum_Id=@CurStratum_Id
										
								
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
								--</change#8>

									
			
				
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
								  ,@CurStratum_Id
								  )


										  	--if @strMeasure_num = '359' and @strCurTIN = '121212121'
													--Begin
													--select CAST(@ReportingNumerator AS FLOAT)/@ReportingDenominatorCount as 'A' , CAST(@ReportingNumerator AS FLOAT) as 'B' , @ReportingDenominatorCount as 'C',  * from tbl_TIN_Aggregation_Year where Measure_Num = @strMeasure_num
													--and Exam_TIN = @strCurTIN
													--end

									--print '####1 physician count='+Convert(varchar, @totalPhysiansSubmittedCount)+'cms year='+Convert(varchar,@intCurActiveYear)+ 'Tin ='+@strCurTIN + 'measure num='+@strMeasure_num;
                                    END
										--check if its GPRO then get from tbl_GPRO_TIN_Selected_Measures
								Else IF EXISTS ( SELECT  1
                                            FROM    dbo.tbl_GPRO_TIN_Selected_Measures
                                            WHERE  	TIN = @strCurTIN
                                                    AND Submission_year = @intCurActiveYear
                                                    AND Measure_num = @strMeasure_num 
										    and Is_Active=1  -- Change #14
										    and Is_90Days=0) -- Change #15 
                                    BEGIN

										-- Default its selected some time back
										SET @blnSelectedForSubmission = 0 ;
										SET @intTotalCasesReviewed = NULL ;
										SET @blnHundredPercentSubmit = 0 ;						
										
												select @TotalExamsCount = count(*) from tbl_Exam e inner join
													tbl_Exam_Measure_Data d on d.Exam_Id = e.Exam_Id 
														where Exam_TIN = @strCurTIN  and e.CMS_Submission_Year = @intCurActiveYear
														and d.Measure_ID in 
															( select top 1 m.Measure_ID from tbl_Lookup_Measure m 
																where m.Measure_num = @strMeasure_num and  m.CMSYear = @intCurActiveYear
																
															)
															AND e.Patient_Age >= @CurStart_Age
								                                    AND e.Patient_Age <= @CurEnd_Age
															and status in(2,3)

										SELECT @blnSelectedForSubmission = isnull(g.SelectedForSubmission,0)
										,@intTotalCasesReviewed = g.TotalCasesReviewed
										,@blnHundredPercentSubmit = isnull(g.HundredPercentSubmit,0) 
										FROM    [dbo].[tbl_GPRO_TIN_Selected_Measures] g
										WHERE g.TIN = @strCurTIN
										AND  g.Submission_year= @intCurActiveYear
										AND g.Measure_Num = @strMeasure_num 
										  and g.Is_Active=1 -- Change #14
										  and g.Is_90Days=0 -- Change #15 

                                      IF @blnHundredPercentSubmit = 1
									  Begin
													set @intTotalCasesReviewed = 0;
													--set @TotalExamsCount =0; --Change #16
														
													select @intTotalCasesReviewed = count(*) from tbl_Exam e inner join
													tbl_Exam_Measure_Data d on d.Exam_Id = e.Exam_Id 
														where Exam_TIN = @strCurTIN  and e.CMS_Submission_Year = @intCurActiveYear
														and d.Measure_ID in 
															( select top 1 m.Measure_ID from tbl_Lookup_Measure m 
																where m.Measure_num = @strMeasure_num and  m.CMSYear = @intCurActiveYear
																
															)
															AND e.Patient_Age >= @CurStart_Age
								                                 AND e.Patient_Age <= @CurEnd_Age
															and status in(2,3)
											--set @TotalExamsCount =0; --Change #16
											--	set @TotalExamsCount =@intTotalCasesReviewed; --Change #16
										END

										 IF ISNULL(@intTotalCasesReviewed, 0) > 0 
                                            BEGIN
                                                SET @initPatientPopulation = @intTotalCasesReviewed ;										
                                            END

                                         --<change#4>
										 IF ISNULL(@initPatientPopulation, 0) > 0 
											BEGIN			
											    --SET @ReportingDenominatorCount = @initPatientPopulation;	
												SET @ReportingDenominatorCount = @initPatientPopulation - @DenominatorExclusionCount;
											END
                                         --</change#4>

										-- Display for testing
										--select 'problem' as 'ello', @intTotalCasesReviewed as 'TINcases Total', @intCurActiveYear as [year],@strCurTIN as [tin], @strMeasure_num as [measure_Num]

										set @ReportingNumerator = 0;
										select @ReportingNumerator=sum(isnull(Reporting_Numerator,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=0 -- Change #15
										 and a.Stratum_Id=@CurStratum_Id
									
										set @performanceDenominator = 0;
										select @performanceDenominator =sum(isnull(Performance_denominator,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=0 -- Change #15
										 and a.Stratum_Id=@CurStratum_Id

										set @performanceNumerator = 0;
										select @performanceNumerator =sum(isnull(Performance_Numerator,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=0 -- Change #15
										 and a.Stratum_Id=@CurStratum_Id

										set @DenominatorExceptionCount=0;

										select @DenominatorExceptionCount =sum(isnull(Denominator_Exceptions,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=0 -- Change #15
										 and a.Stratum_Id=@CurStratum_Id

										set @DenominatorExclusionCount =0;
											select @DenominatorExclusionCount =sum(isnull(Denominator_Exclusions,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=0 -- Change #15
										 and a.Stratum_Id=@CurStratum_Id


										set @performanceNotMetCount = 0;
										select  @performanceNotMetCount =sum(isnull(Performance_Not_Met,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=0 -- Change #15
										 and a.Stratum_Id=@CurStratum_Id

										set @performanceMetCount = 0;
										select  @performanceMetCount =sum(isnull(Performance_Met,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=0 -- Change #15
										 and a.Stratum_Id=@CurStratum_Id

										 SELECT  @Last_Encounter_Date = MAX(Encounter_To_Date) ,
                                        @First_Encounter_date = MIN(Encounter_From_Date)
										from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=0 -- Change #15
										 and a.Stratum_Id=@CurStratum_Id

										--<change#4>
										   IF ISNULL(@initPatientPopulation, 0) > 0 
									 BEGIN
										-- King Lo 02/20/2015: ReportingDenominatorCount should be the same as initPatientPopulation
										--SET @ReportingDenominatorCount = @initPatientPopulation;																
                                        SET @ReportingDenominatorCount = @initPatientPopulation - @DenominatorExclusionCount;
                                    END
									--</change#4>
				
                                IF ( @ReportingDenominatorCount < 1 ) 
                                    BEGIN
                                        SET @ReportingDenominatorCount = NULL ;
                                    END

								-- @ReportingNumerator

								--<change#12> initialize @reportingRate
								SET @reportingRate = NULL
								--</change#12>

								IF ( ( @ReportingNumerator > 0 ) AND
								 ( ISNULL(@ReportingDenominatorCount, 0) > 0 )
                                   ) 
                                    BEGIN
						
                                        SET @reportingRate = CAST(@ReportingNumerator AS FLOAT)/ @ReportingDenominatorCount ;
                                        SET @reportingRate = @reportingRate* 100 ;
										--select  @strMeasure_num as 'mes Num',CAST(@ReportingNumerator AS FLOAT) as 'repNum',@ReportingDenominatorCount as 'repdencount', @reportingRate as 'reprate'
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
												SET @performanceRate = ( CAST(@performanceNumerator AS FLOAT)
																		/ @performanceDenominator ) * 100 ;
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
				
		

										-- Insert into tbl_TIN_Aggregation_year
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
											   ,[Benchmark_met] --25
											   ,[Decile_Val]--26
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
											   ,
											   @blnGPRO --6 <GPRO, int,>
											   ,@initPatientPopulation --7 <Init_Patient_Population, int,>
											   ,@ReportingDenominatorCount --8<Reporting_Denominator, int,>
											   ,@ReportingNumerator --9 <Reporting_Numerator, int,>
											   ,1 -- 10 <Exclusion, int,>
											   ,isnull(@performanceDenominator,0) -- 11 <Performance_denominator, int,>
											   ,@performanceNumerator -- 12 <Performance_Numerator, int,>
											   ,@DenominatorExceptionCount -- 13 <Denominator_Exceptions, int,>
											   ,@DenominatorExclusionCount -- 14 <Denominator_Exclusions, int,>
											   ,@performanceNotMetCount -- 15 <Performance_Not_Met, int,>
											   ,@performanceMetCount -- 16 <Performance_Met, int,>
											   ,CASE WHEN @ReportingNumerator IS NULL
														 THEN NULL
													-- WHEN @performanceRate = 0
														--THEN NULL
													 ELSE ROUND(@reportingRate, 2)
													END-- 17 <Reporting_Rate, decimal(18,4),>
											   , CASE WHEN @performanceRate IS NULL
														THEN NULL
													 --WHEN @performanceRate = 0
														--THEN NULL
													ELSE ROUND(@performanceRate, 2)
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
								  ,	@TotalExamsCount --Change #16
								  ,@totalPhysiansSubmittedCount --Change #17
								  ,@CurStratum_Id
								  )

											--if @strMeasure_num = '359' and 	@strCurTIN = '121212121'
											--		Begin
											--		select * from tbl_TIN_Aggregation_Year where Measure_Num = @strMeasure_num
											--		and Exam_TIN = @strCurTIN
											--		end
									--print '####2 physician count='+Convert(varchar, @totalPhysiansSubmittedCount)+'cms year='+Convert(varchar,@intCurActiveYear)+ 'Tin ='+@strCurTIN + 'measure num='+@strMeasure_num;
                                    END

								ELSE  -- NOT IN PHYSICIAN SELECTED OR  FACILITY SELECTED
								--<Change#5>
								    BEGIN
                                       SET @intTotalCasesReviewed = 0;
									   SET @blnSelectedForSubmission = 0;
									   SET @intGPROTotalCasesReviewed = 0;									  
									   SET @blnHundredPercentSubmit = 0		
									   --added by raju g	  
									   Set @TotalExamsCount=0; --Change#16
											
											select 	@intTotalCasesReviewed = isnull (count(*),000)  from tbl_Exam e inner join
															 tbl_Exam_Measure_Data d on d.Exam_Id = e.Exam_Id 
																where Exam_TIN = @strCurTIN  and e.CMS_Submission_Year = @intCurActiveYear
															and d.Measure_ID in 
																( select top 1 m.Measure_ID from tbl_Lookup_Measure m 
																	where m.Measure_num = @strMeasure_num and  m.CMSYear = @intCurActiveYear
																	
																)
																AND e.Patient_Age >= @CurStart_Age
								                                  AND e.Patient_Age <= @CurEnd_Age
															and status in(2,3)					
										
									
										set	@TotalExamsCount=@intTotalCasesReviewed; --Change#16
								 --print '----------------3ed inserted line 1002 [TotalExamsCount=]'+Convert(varchar,@TotalExamsCount)+'tin='+@strCurTIN+'Measure_Num='+@strMeasure_num

								
										 IF ISNULL(@intTotalCasesReviewed, 0) > 0 
                                            BEGIN
                                                SET @initPatientPopulation = @intTotalCasesReviewed ;										
                                            END

											if @blnGPRO = 1
											Begin
											  if @blnHundredPercentSubmit =0  and isnull(@intGPROTotalCasesReviewed,0) > 0
											  Begin
											  set @initPatientPopulation = isnull(@intGPROTotalCasesReviewed,0)
											  end
											End


										-- Display for testing
										--select 'false' as [GPRO] , @intTotalCasesReviewed as 'TINcases Total', @intCurActiveYear as [year],@strCurTIN as [tin], @strMeasure_num as [measure_Num]



										set @ReportingNumerator = 0;
										select @ReportingNumerator=sum(isnull(Reporting_Numerator,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=0 -- Change #15
										 and a.Stratum_Id=@CurStratum_Id

							    --<change#4>
								--  set reportingDenominator
                                IF ISNULL(@initPatientPopulation, 0) > 0 
                                    BEGIN
										
											set @DenominatorExclusionCount =0;
											select @DenominatorExclusionCount =sum(isnull(Denominator_Exclusions,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=0 -- Change #15
										 and a.Stratum_Id=@CurStratum_Id

											set @DenominatorExceptionCount=0;

										select @DenominatorExceptionCount =sum(isnull(Denominator_Exceptions,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=0 -- Change #15
										and a.Stratum_Id=@CurStratum_Id

										-- King Lo 02/20/2015: ReportingDenominatorCount should be the same as initPatientPopulation
									  
									    --SET @ReportingDenominatorCount = @initPatientPopulation;				
                                        SET @ReportingDenominatorCount = @initPatientPopulation - @DenominatorExclusionCount ;
                                    END
                                 --</change#4>
									
									
									IF ( @ReportingDenominatorCount < 1 ) 
										BEGIN
											SET @ReportingDenominatorCount = NULL ;
										END

										set @performanceDenominator = 0;
										select @performanceDenominator =sum(isnull(Performance_denominator,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=0 -- Change #15
										 and a.Stratum_Id=@CurStratum_Id

										set @performanceNumerator = 0;
										select @performanceNumerator =sum(isnull(Performance_Numerator,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=0 -- Change #15
										 and a.Stratum_Id=@CurStratum_Id


										set @performanceNotMetCount = 0;
										select  @performanceNotMetCount =sum(isnull(Performance_Not_Met,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=0 -- Change #15
										 and a.Stratum_Id=@CurStratum_Id

										set @performanceMetCount = 0;
										select  @performanceMetCount =sum(isnull(Performance_Met,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=0 -- Change #15
										 and a.Stratum_Id=@CurStratum_Id

										 SELECT  @Last_Encounter_Date = MAX(Encounter_To_Date) ,
                                        @First_Encounter_date = MIN(Encounter_From_Date)
										from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=0 -- Change #15
										 and a.Stratum_Id=@CurStratum_Id

										
								
								-- @ReportingNumerator	
															
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
								--</change#8>
														
				--Change #13
			select @decile_Val= dbo.fnYearwiseDecileLogic(@strMeasure_num,@performanceRate,@intCurActiveYear,@reportingRate,@TotalExamsCount) 
				                


								--print '3rd inserted 1001 started'+Convert(varchar,@totalPhysiansSubmittedCount)
									 --print '3ed inserted line 1002 [TotalExamsCount]'+Convert(varchar,@TotalExamsCount)+'tin'+@strCurTIN+'Measure_Num'+@strMeasure_num; ; 
										-- Insert into tbl_TIN_Aggregation_year  from PQRS Aggreated
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
											   ,[Benchmark_met] --25
											   ,[Decile_Val] --26
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
											   ,0 --5<SelectedForCMSSubmission, bit,>
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
								  ,0
								  ,@TotalExamsCount --Change #16
								  ,@totalPhysiansSubmittedCount --Change #17
								  ,@CurStratum_Id
								  )

						

									--</Change#5>
								--print '####3 physician count='+Convert(varchar, @totalPhysiansSubmittedCount)+'cms year='+Convert(varchar,@intCurActiveYear)+ 'Tin ='+@strCurTIN + 'measure num='+@strMeasure_num;
                                    END
		
              	FETCH NEXT FROM CurStratum 	INTO @CurStart_Age,@CurEnd_Age,@CurStratum_Id
            END 
        CLOSE CurStratum ;
        DEALLOCATE CurStratum ;				
				
    END

