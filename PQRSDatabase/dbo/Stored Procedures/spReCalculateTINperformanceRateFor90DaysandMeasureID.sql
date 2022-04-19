
-- =============================================
-- Author:		Prashanth kumar Garlapally
-- Create date: 23-11-2016
-- Description:	Recalculate  performance rate by year and filter by tin optional
-- Change #4 By:yarannaidu 
-- Change #4 date: 11-jan-2017
-- Change #4 desc:	Get Reporting Denominator from table
-- Change #5 By:	Prashanth kumar Garlapally
-- Change #5 date: 12-jan-2017
-- Change #5 desc:	Include records that are not selected by physician or GPRO Facility

-- Change #6 By:   yarannaidu
-- Change #6 date: 01-Feb-2017
-- Change #6 desc:	@blnSelectedForSubmission = 1 ;

-- Change #7 By:   Prashanth
-- Change #7 date: 02-Feb-2017
-- Change #7 desc:  missed "and  e.[Physician_NPI] = tbl_Physician_Selected_Measures.npi" in aggregation

-- Change #8 By:   Prashanth
-- Change #8 date: 10-Feb-2017
-- Change #8 desc:  tbl_tin_aggregation_year - performance_rate should be 0.00% if Performance_numerator is 0 and Performance_denominator > 0
--
-- Change #9 By:   Prashanth
-- Change #9 date: 10-Feb-2017
-- Change #9 desc:  tbl_tin_aggregation_year - Delete all records of cms submission year if tin is not defined else restrict to tin passed as parameter.

-- Change #10 By:   Prashanth
-- Change #10 date: 17-Feb-2017
-- Change #10 desc:  tbl_tin_aggregation_year - udpate selected for cms if tbl_GPRO_TIN_Selected_Measures has selectedforcmssubmission= 1

-- Change #11 By:   King
-- Change #11 date: 25-Feb-2017
-- Change #11 desc: Performance Rate calculation rule changes for PQRS measures:  If performance_numerator and performance_denominator are both 0
--                  then set Performance_Rate to NULL
-- Change #12 By:   King
-- Change #12 date: 25-Feb-2017
-- Change #12 desc: Initialize @reportingRate and @performanceRate
-- Change #13 By: Hari j
-- Change #13 date: Jan-05-18
-- Change #13 desc: finding the decile value based on performance rate and reporting rate
-- Change #14 By: Hari j
-- Change #14 date: Jan-17-18
-- Change #14 desc: only isActive=1 values in the tbl_GPRO_TIN_Selected_Measures should involved in performancerate calculations
-- Change #15 By: Hari j
-- Change #15 date: Feb-14-18
-- Change #15 desc: only Is_90Days=1 values in the tbl_Physician_Aggregation_Year should involved in performancerate calculations
-- Change #15 desc: only Is_90Days=1 values in the tbl_Physician_Selected_Measures should involved in performancerate calculations
-- Change #15 desc: only Is_90Days=1 values in the tbl_GPRO_TIN_Selected_Measures should involved in performancerate calculations
-- Change #15 desc: insert Is_90Days=1 values in the tbl_TIN_Aggregation_Year
-- Change #15 desc: given a 90 days range from '10/1/2017 12:00:00 AM' to '1/1/2018 12:00:00 AM'
-- Change #16 By  : Raju Gaddam
-- Change #16 Date : Feb-15-18
-- Change #17  By : Raju Gaddam
-- Change #17 date: Feb 16,2018
-- Change #18 desc: insert  total physician submitted count ,totalexamcount in table tbl_GPRO_TIN_Selected_Measures_90days using column totalPhysiansSubmittedCount
-- Change #18  By : Raju Gaddam
-- Change #18 date: Feb 16,2018
-- chnage #19 By: Hari
-- Change #19 date: Mar 1,2018
-- Change #19 Description: for JIRA#504


-- change #20 By: Hari
-- Change #20 date: April 11,2018
-- Change #20 Add CMSyear in tbl_lookup_decile_data:
-- =============================================
CREATE PROCEDURE [dbo].[spReCalculateTINperformanceRateFor90DaysandMeasureID] 
	-- Add the parameters for the stored procedure here
	  @strCurMeasure_num AS VARCHAR(20) ,
	@intCurActiveYear int = 0, 
	@strCurTIN varchar(11) ,
    @Is_90Days bit =1
AS
BEGIN

-- Declare
		
        DECLARE @intCurMeasureId AS INT

        DECLARE @intCurAggregationID AS INT
     


        DECLARE @intCurUserID AS INT
        --DECLARE @strCurNPI AS VARCHAR(10)
     
		 DECLARE @strMeasure_num AS VARCHAR(20) ;
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
		DECLARE @blnGPRO	as bit;


		  DECLARE @blnSelectedForSubmission BIT       
			DECLARE @blnHundredPercentSubmit BIT

			--Hari 1/5-2018 for decilevalue

		DECLARE @decile_Val as varchar(100);

		--Hari 14th,Feb-2018 for 90days performance rate
	 DECLARE @Start_90Days DATETIME
        DECLARE @End_90Days DATETIME
		DECLARE @TotalExamsCount int; --Change #16
		DECLARE @totalPhysiansSubmittedCount int;  --Change #1
        SET NOCOUNT ON ;
--Step#0 Update TINS for NON-pqrs purpose.
		 --if ISNULL(@strPhysicianNPI,'')  <> ''
		 --Begin
		 --EXECUTE dbo.spGetLatestTINsOfNPI @strNPI = @strPhysicianNPI;
		 --End

		 --Hari 14th,Feb-2018 for performance rate
		 SELECT @Start_90Days = CONVERT(datetime, '10/1/2017 12:00:00 AM')--, 103)
		  SELECT @End_90Days = CONVERT(datetime, '1/1/2018 12:00:00 AM')--, 103)

		--where Exam_Date >= @Start_90Days and Exam_Date <= @End_90Days
	
--Step#1 Get Active years	
     
            BEGIN

				--<change#9>
				-- if tin is specified delte only related to that tin else all for the selected year.
					Delete from tbl_TIN_Aggregation_Year where
				   CMS_Submission_Year = @intCurActiveYear
				   and Measure_Num=@strCurMeasure_num
				   and Is_90Days=1 -- Change #15
				and Exam_TIN = @strCurTIN
				--</change#9>

			
			--Step#2 Get NPI's and TIN
               
                    BEGIN
							set @blnGPRO = 0;			
							--Check tin gpro status
							--exec sp_getTIN_GPRO @strCurTIN
							select top 1  @blnGPRO =  is_GPRO from 
							tbl_TIN_GPRO where ltrim(rtrim(TIN)) = ltrim(rtrim(@strCurTIN))
						
							
						--Step#3 Get Exam Measures for this NPI,TIN
														
  SELECT @intCurMeasureId=(SELECT DISTINCT md.Measure_ID
                        FROM 
				    tbl_Exam e  
                        INNER JOIN tbl_Exam_Measure_Data md
                        ON md.Exam_Id = e.Exam_Id inner join
				    tbl_Lookup_Measure l  on l.[Measure_ID]=md.[Measure_ID]
                       WHERE e.CMS_Submission_Year = @intCurActiveYear									
									AND e.Exam_TIN = @strCurTIN
									AND md.[Status]  IN (2,3)
				    AND l.Measure_num=@strCurMeasure_num
				    )

										BEGIN
				
											SET @strMeasure_num = '' ;
											set @blnSelectedForSubmission =0
									
											SELECT  @strMeasure_num = Measure_num
											FROM    tbl_Lookup_Measure
											WHERE   Measure_ID = @intCurMeasureId

																	
										            set @totalPhysiansSubmittedCount=0;


											--change #18
											select @totalPhysiansSubmittedCount=count(*) from (select e.Physician_NPI from tbl_Exam e inner join
															 tbl_Exam_Measure_Data d on d.Exam_Id = e.Exam_Id 
																where Exam_TIN = @strCurTIN  and e.CMS_Submission_Year = @intCurActiveYear
																and  e.Exam_Date >= @Start_90Days and e.Exam_Date <= @End_90Days -- Change #15
																-- Change #15
															and d.Measure_ID in 
																( select top 1 m.Measure_ID from tbl_Lookup_Measure m 
																	where m.Measure_num = @strMeasure_num and  m.CMSYear = @intCurActiveYear
																)
															and status =2
															group by e.Physician_NPI
															having COUNT(e.Physician_NPI) > 0)x


									-- Step#4 Get info for received measure is selected for CMS submission		
					 IF EXISTS ( SELECT  top 1 *
                                            FROM    dbo.tbl_GPRO_TIN_Selected_Measures_90days
                                            WHERE  	TIN = @strCurTIN
                                                    AND Submission_year = @intCurActiveYear
                                                    AND Measure_num = @strMeasure_num 
										    and Is_Active=1 ) -- Change #14
										  --  and Is_90Days=1) -- Change #15 
                                    BEGIN

										-- Default its selected some time back
										SET @blnSelectedForSubmission = 0 ;
										SET @intTotalCasesReviewed = NULL ;
										SET @blnHundredPercentSubmit = 0 ;						
										
										--Change #16 -@TotalExamsCount
														select @TotalExamsCount = count(*) from tbl_Exam e inner join
													tbl_Exam_Measure_Data d on d.Exam_Id = e.Exam_Id 
														where Exam_TIN = @strCurTIN 
														and e.Exam_Date >= @Start_90Days and e.Exam_Date <= @End_90Days -- Change #15
														 and e.CMS_Submission_Year = @intCurActiveYear
														and d.Measure_ID in 
															( select top 1 m.Measure_ID from tbl_Lookup_Measure m 
																where m.Measure_num = @strMeasure_num and  m.CMSYear = @intCurActiveYear
															)
															and status in(2,3)


										SELECT @blnSelectedForSubmission = isnull(g.SelectedForSubmission,0)
										,@intTotalCasesReviewed = g.TotalCasesReviewed
										,@blnHundredPercentSubmit = isnull(g.HundredPercentSubmit,0) 
										FROM    [dbo].[tbl_GPRO_TIN_Selected_Measures_90days] g
										WHERE g.TIN = @strCurTIN
										AND  g.Submission_year= @intCurActiveYear
										AND g.Measure_Num = @strMeasure_num 
										  and g.Is_Active=1 -- Change #14
										--  and g.Is_90Days=1 -- Change #15 

                                      IF @blnHundredPercentSubmit = 1
									  Begin
													set @intTotalCasesReviewed = 0;
										            
													select @intTotalCasesReviewed = count(*) from tbl_Exam e inner join
													tbl_Exam_Measure_Data d on d.Exam_Id = e.Exam_Id 
														where Exam_TIN = @strCurTIN 
														and e.Exam_Date >= @Start_90Days and e.Exam_Date <= @End_90Days -- Change #15
														 and e.CMS_Submission_Year = @intCurActiveYear
														and d.Measure_ID in 
															( select top 1 m.Measure_ID from tbl_Lookup_Measure m 
																where m.Measure_num = @strMeasure_num and  m.CMSYear = @intCurActiveYear
															)
															and status in(2,3)
											
													--set @TotalExamsCount =0; --Change #16
													--set @TotalExamsCount=@intTotalCasesReviewed; --Change #16
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
										 and a.Is_90Days=1 -- Change #15

									
										set @performanceDenominator = 0;
										select @performanceDenominator =sum(isnull(Performance_denominator,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=1 -- Change #15

										set @performanceNumerator = 0;
										select @performanceNumerator =sum(isnull(Performance_Numerator,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=1 -- Change #15

										set @DenominatorExceptionCount=0;

										select @DenominatorExceptionCount =sum(isnull(Denominator_Exceptions,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=1 -- Change #15

										set @DenominatorExclusionCount =0;
											select @DenominatorExclusionCount =sum(isnull(Denominator_Exclusions,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=1 -- Change #15


										set @performanceNotMetCount = 0;
										select  @performanceNotMetCount =sum(isnull(Performance_Not_Met,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=1 -- Change #15

										set @performanceMetCount = 0;
										select  @performanceMetCount =sum(isnull(Performance_Met,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=1 -- Change #15

										 SELECT  @Last_Encounter_Date = MAX(Encounter_To_Date) ,
                                        @First_Encounter_date = MIN(Encounter_From_Date)
										from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=1 -- Change #15

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
								--</change#8>

									--if @blnGPRO = 1
									--Begin
									--select 
									-- @intCurActiveYear --1											  
									--		   ,@strCurTIN --2
									--		   ,@strMeasure_num --3
									--		   ,@intCurMeasureId
									--		   ,@blnGPRO
									--End

															
				--Change #13
				  SET @decile_Val=NULL
				  IF((@reportingRate < 50 ) and (@reportingRate is not null ) )
				 begin
				SET @decile_Val='3 Points'
				 end
				 else if(@reportingRate >= 50)
				 begin
				 -- call function fnGetDecileValue
				 select @decile_Val= dbo.fnGetDecileValue(@strMeasure_num,@performanceRate,@intCurActiveYear)--@change# 20
				 select @decile_Val=ISNULL(@decile_Val,'3 Points')
				 end

				 
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
								  ,1 -- Change #15
								  ,@TotalExamsCount --Change #16
								  ,@totalPhysiansSubmittedCount --Change #17
								  )

											--if @strMeasure_num = '359' and 	@strCurTIN = '121212121'
											--		Begin
											--		select * from tbl_TIN_Aggregation_Year where Measure_Num = @strMeasure_num
											--		and Exam_TIN = @strCurTIN
											--		end

                                    END

								ELSE  -- NOT IN PHYSICIAN SELECTED OR  FACILITY SELECTED
								--<Change#5>
								    BEGIN
                                       SET @intTotalCasesReviewed = 0;
									   SET @blnSelectedForSubmission = 0;
									   SET @intGPROTotalCasesReviewed = 0;									  
									   SET @blnHundredPercentSubmit = 0	;
									   SET @TotalExamsCount=0	;	  
									 
											
											select 	@intTotalCasesReviewed = isnull (count(*),000)  from tbl_Exam e inner join
															 tbl_Exam_Measure_Data d on d.Exam_Id = e.Exam_Id 
																where Exam_TIN = @strCurTIN  and e.CMS_Submission_Year = @intCurActiveYear
																and  Exam_Date >= @Start_90Days and Exam_Date <= @End_90Days -- Change #15
															and d.Measure_ID in 
																( select top 1 m.Measure_ID from tbl_Lookup_Measure m 
																	where m.Measure_num = @strMeasure_num and  m.CMSYear = @intCurActiveYear
																)
															and status in(2,3)					
										
									 SET @TotalExamsCount=@intTotalCasesReviewed;	
										

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
										 and a.Is_90Days=1 -- Change #15
							    --<change#4>
								--  set reportingDenominator
                                IF ISNULL(@initPatientPopulation, 0) > 0 
                                    BEGIN
										
											set @DenominatorExclusionCount =0;
											select @DenominatorExclusionCount =sum(isnull(Denominator_Exclusions,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=1 -- Change #15

											set @DenominatorExceptionCount=0;

										select @DenominatorExceptionCount =sum(isnull(Denominator_Exceptions,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=1 -- Change #15
										
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
										 and a.Is_90Days=1 -- Change #15

										set @performanceNumerator = 0;
										select @performanceNumerator =sum(isnull(Performance_Numerator,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=1 -- Change #15


										set @performanceNotMetCount = 0;
										select  @performanceNotMetCount =sum(isnull(Performance_Not_Met,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=1 -- Change #15

										set @performanceMetCount = 0;
										select  @performanceMetCount =sum(isnull(Performance_Met,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=1 -- Change #15

										 SELECT  @Last_Encounter_Date = MAX(Encounter_To_Date) ,
                                        @First_Encounter_date = MIN(Encounter_From_Date)
										from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =@strCurTIN 
										and a.Measure_Num = @strMeasure_num 
										and a.CMS_Submission_Year = @intCurActiveYear
										 and a.Is_90Days=1 -- Change #15

										
								
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
			 SET @decile_Val=NULL
				  IF((@reportingRate < 50 ) and (@reportingRate is not null ) )
				 begin
				SET @decile_Val='3 Points'
				 end
				 else if(@reportingRate >= 50)
				 begin
				 -- call function fnGetDecileValue
				 select @decile_Val= dbo.fnGetDecileValue(@strMeasure_num,@performanceRate,@intCurActiveYear)--@change# 20
				 select @decile_Val=ISNULL(@decile_Val,'3 Points')
				 end
									


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
											   ,[totalPhysiansSubmittedCount] --Change #17
											   ,[TotalExamsCount]
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
								  ,1
								  ,@totalPhysiansSubmittedCount
								  ,@TotalExamsCount
								  )



									--</Change#5>
                                    END
									
										
										END
							
					
					End

				

					declare @CurExamNONPQRS_TIN as varchar(11)
						-- STEP#9 GET EXAM MEASURES OF NON PQRS TINS

							-- Step#B get NON PQRS measures from dbo.tbl_Non_PQRS_Aggregation_Year
                        DECLARE CurNonPQRTINSMeasures CURSOR FOR
								SELECT Aggregation_Id,Measure_Num,Exam_TIN FROM tbl_Non_PQRS_TIN_Aggregation_Year  
								WHERE CMS_Submission_Year  = @intCurActiveYear
								and Measure_Num=@strCurMeasure_num
								and Exam_TIN = @strCurTIN  
								  and Is_90Days=1
								                    
								
								ORDER BY Aggregation_Id
								OPEN CurNonPQRTINSMeasures
						FETCH NEXT FROM CurNonPQRTINSMeasures INTO @intCurAggregationID,@strCurMeasure_num,@CurExamNONPQRS_TIN				
                        WHILE @@FETCH_STATUS = 0 
                            BEGIN
                                SET @initPatientPopulation = NULL ;
                                SET @totalValReportedCount = NULL ;
                                SET @DenominatorExclusionCount = 0
                                SET @DenominatorExceptionCount = 0
                                SET @ReportingNumerator = 0
                                SET @ReportingDenominatorCount = 0

                                SET @performanceNumerator = 0
                                SET @performanceDenoCount = 0
                                SET @performanceMetCount = 0	
                                SET @performanceNotMetCount = 0

                                SET @reportingRate = NULL ;
                                SET @performanceRate = NULL ;
                                SET @First_Encounter_date = NULL ;
                                SET @Last_Encounter_Date = NULL ;
                                SET @intStrataNum = 0 ;
								SET @benchmarkMet = NULL;
								SET @decile_Val=NULL;
								
								--Change #17
			
			select @totalPhysiansSubmittedCount=count(*) from (select e.Physician_NPI from tbl_Exam e inner join
															 tbl_Exam_Measure_Data d on d.Exam_Id = e.Exam_Id 
																where Exam_TIN = @CurExamNONPQRS_TIN  and e.CMS_Submission_Year = @intCurActiveYear
																and  e.Exam_Date >= @Start_90Days and e.Exam_Date <= @End_90Days -- Change #15
													
															and d.Measure_ID in 
																( select top 1 m.Measure_ID from tbl_Lookup_Measure m 
																	where m.Measure_num = @strCurMeasure_num and  m.CMSYear = @intCurActiveYear
																)
															and status =2
															group by e.Physician_NPI
															having COUNT(e.Physician_NPI) > 0)x

								DELETE FROM dbo.tbl_TIN_Aggregation_Year 
								WHERE CMS_Submission_Year = @intCurActiveYear
										and Exam_TIN = 	@CurExamNONPQRS_TIN 
										and Measure_Num = @strCurMeasure_num	
										  and Is_90Days=1 -- Change #15

										set @blnGPRO = 0;			
							--Check tin gpro status
							exec sp_getTIN_GPRO @CurExamNONPQRS_TIN
							select top 1  @blnGPRO =  is_GPRO from 
							tbl_TIN_GPRO where ltrim(rtrim(TIN)) = ltrim(rtrim(@CurExamNONPQRS_TIN))


                                SELECT  @totalValReportedCount = [Total_Num_Exam_Submitted] ,
                                        @First_Encounter_date = [Encounter_From_Date] ,
                                        @Last_Encounter_Date = [Encounter_To_Date] ,
                                        @intStrataNum = [Strata_num] ,
                                        @ReportingNumerator = [Reporting_Numerator] ,
                                        @performanceDenoCount = [Performance_denominator] ,
                                        @performanceNumerator = [Performance_Numerator] ,
                                        @DenominatorExceptionCount = [Denominator_Exceptions] ,
                                        @DenominatorExclusionCount = [Denominator_Exclusions] ,
                                        @performanceNotMetCount = [Performance_Not_Met] ,
                                        @performanceMetCount = [Performance_Met] ,
                                        @performanceRate = [Performance_rate],
                                        @benchmarkMet = [Benchmark_met],
								@decile_Val=[Decile_val]
                                FROM    [dbo].[tbl_Non_PQRS_TIN_Aggregation_Year] n
                                WHERE   n.Aggregation_Id = @intCurAggregationID

									set @TotalExamsCount =0; --Change #16
							set @TotalExamsCount =@totalValReportedCount ;
							------
                                IF EXISTS ( SELECT  *
                                            FROM    dbo.tbl_GPRO_TIN_Selected_Measures_90days
                                            WHERE  TIN = @CurExamNONPQRS_TIN
                                                    AND Submission_year = @intCurActiveYear
                                                    AND ltrim(rtrim(Measure_num)) = ltrim(rtrim(@strCurMeasure_num ) )
										    and Is_Active=1) -- Change #14
										 
                                    BEGIN
                                        SELECT  @blnSelectedForSubmission = SelectedForSubmission ,
                                                @intTotalCasesReviewed = TotalCasesReviewed ,
                                                @blnHundredPercentSubmit = HundredPercentSubmit
                                        FROM    dbo.tbl_GPRO_TIN_Selected_Measures_90days
                                        WHERE  TIN = @CurExamNONPQRS_TIN
                                                AND Submission_year = @intCurActiveYear
                                                AND Measure_num = @strCurMeasure_num	
									     and Is_Active=1	-- Change #14
										--and Is_90Days=1 -- Change #15 
															
							
                                    END
                                ELSE 
                                    BEGIN
									   
									   --<change#6>
                                        --SET @blnSelectedForSubmission = 1 ;
										SET @blnSelectedForSubmission = 0 ;
                                        SET @intTotalCasesReviewed = @totalValReportedCount
                                        SET @blnHundredPercentSubmit = 1 ;
										
							           --<change#6>
                                    END
										
							--if @strCurMeasure_num = 'ACRAD 10'
							--select  @blnSelectedForSubmission ,
       --                                  @intTotalCasesReviewed ,
       --                                  @blnHundredPercentSubmit  as  Naidu,
							--			 @strCurMeasure_num as measure
							--			 ,@strCurTIN as tin
					---------
                                IF ( @blnSelectedForSubmission = 1 ) 
                                    BEGIN
					
                                        IF ISNULL(@intTotalCasesReviewed, 0) > 0 
                                            BEGIN
                                                SET @initPatientPopulation = @intTotalCasesReviewed ;
					--select @initPatientPopulation as 'Init pop', @intTotalCasesReviewed as 'T Cases Received'
                                            END
                                        ELSE 
                                            IF ( @blnHundredPercentSubmit = 1 ) 
                                                BEGIN
												
                                                    SET @initPatientPopulation = @totalValReportedCount ;
                                                END
                                    END
				
				--select 'kumar' as k,@initPatientPopulation,@totalValReportedCount,@intTotalCasesReviewed

				--<change#4>
				--  set reportingDenominator
                                IF ISNULL(@initPatientPopulation, 0) > 0 
                                    BEGIN
				 -- King Lo 02/20/2015: ReportingDenominatorCount should be the same as initPatientPopulation
				 -- set  @ReportingDenominatorCount = @initPatientPopulation - @DenominatorExclusionCount;
				   --SET @ReportingDenominatorCount = @initPatientPopulation;
                                        SET @ReportingDenominatorCount = @initPatientPopulation - @DenominatorExclusionCount;
                                    END
					--</change#4>

                                IF ( @ReportingDenominatorCount < 1 ) 
                                    BEGIN
                                        SET @ReportingDenominatorCount = NULL ;
                                    END
					
				--- set reporting numerator
				-- King Lo 02/20/2015: commented out the ReportingNumerator calculation:
				--                     we should just take the value from the non_pqrs_aggregation_year table instead
				--                     of doing the calculation: 
				-- set @ReportingNumerator = @performanceNumerator + @DenominatorExceptionCount 
				-- + @performanceNotMetCount;
				
						
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
                    						
	

				
                  
                                INSERT  INTO [dbo].tbl_TIN_Aggregation_Year
                                        ( [CMS_Submission_Year]  --1)        
                                         ,[Exam_TIN] --2)
                                          ,
                                          [Init_Patient_Population] --3)
                                          ,
                                          [Reporting_Denominator] -- 4
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
                                          [Performance_Numerator] --11
                                          ,
                                          [Denominator_Exclusions] --12
                                          ,
                                          [Performance_Not_Met] --13)
                                          ,
                                          [Performance_Met]  -- 14)
                                          ,
                                          [Reporting_Rate] -- 15)
                                          ,
                                          [Performance_rate]  -- 16)
                                          ,
                                          [Created_Date] ,--17
                                          [Created_By] ,--18
                                          [Last_Mod_Date] ,--19
                                          [Last_Mod_By] ,--20
                                          [Encounter_From_Date] ,--21
                                          [Encounter_To_Date],--22
                                          [Benchmark_met],--23
										  [GPRO],--24
										  [Decile_Val]--25
										  ,[Is_90Days]
										  ,[TotalExamsCount]
										  ,[totalPhysiansSubmittedCount]
           
                                        )
                                VALUES  ( @intCurActiveYear  --1)         
                                          ,
                                          @CurExamNONPQRS_TIN --2)
                                          ,
                                          @initPatientPopulation --3)
                                          ,
                                          @ReportingDenominatorCount -- 4
                                          ,
                                          @performanceDenoCount --5)
                                          ,
                                          @strCurMeasure_num --6)
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
                                               --WHEN @performanceRate = 0
                                               --THEN NULL
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
										  @decile_Val --25
										  ,1
										  ,@TotalExamsCount
										  ,@totalPhysiansSubmittedCount
										 
                                        )										
				
                                FETCH NEXT FROM CurNonPQRTINSMeasures 
								INTO @intCurAggregationID,@strCurMeasure_num,@CurExamNONPQRS_TIN			
                            END
                        CLOSE CurNonPQRTINSMeasures ;
                        DEALLOCATE CurNonPQRTINSMeasures ;


							update tbl_TIN_Aggregation_Year
				set
				SelectedForCMSSubmission = 1
				from tbl_TIN_Aggregation_Year a inner join tbl_GPRO_TIN_Selected_Measures_90days G on
				G.Submission_year = a.CMS_Submission_Year and G.Measure_num = a.Measure_Num
				and G.TIN = a.Exam_TIN
				where G.SelectedForSubmission = 1
				and a.CMS_Submission_Year = @intCurActiveYear
				and a.Measure_Num=@strCurMeasure_num
				 and a.Is_90Days=1 -- Change #15
				  and G.Is_Active=1 -- Change #14
				  --and G.Is_90Days=1 -- Change #15 

			
			
			END 
      

	

END


