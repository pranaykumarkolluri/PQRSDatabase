



-- =============================================
-- Author:	Harikrishna 
-- Create date:11-27-2018
-- Description:	This proc Re-Calculates performance data for active year passes or it will 
--				Calculate for all the years.
-- Change #1 By:Prashanth kumar Garlapally 
-- Change #1 date:15-june-2015
-- Change #1 desc:	make log update inside the  cms year loop from outside.
-- Change #2 By:Prashanth kumar Garlapally 
-- Change #2 date:13-Dec-2015
-- Change #2 desc:	Consider GPRO selected TIN, physicians records as 100%.
-- Change #3 By:Prashanth kumar Garlapally 
-- Change #3 date: 11-jan-2017
-- Change #3 desc:	Get denominator Exclusion from table
-- Change #4 By:yarannaidu 
-- Change #4 date: 11-jan-2017
-- Change #4 desc:	Get Reporting Denominator from table

-- Change #5 By:   Prashanth
-- Change #5 date: 10-Feb-2017
-- Change #5 desc:  tbl_tin_aggregation_year - performance_rate should be 0.00% if Performance_numerator is 0 and Performance_denominator > 0

-- Change #6 By:   Prashanth
-- Change #6 date: 17-Feb-2017
-- Change #6 desc:  tbl_tin_aggregation_year - performance_rate should be 0.00% if Performance_numerator is 0 and Performance_denominator > 0

-- Change #7 By:   King
-- Change #7 date: 25-Feb-2017
-- Change #7 desc: performance Rate calculation rule changes for PQRS measures:  If performance_numerator and performance_denominator are both 0
--                  then set Performance_Rate to NULL
--
-- Change #8 By: King
-- Change #8 date: 05-Mar-2017
-- Change #8 desc: For GPRO we don't need to query if physician has selected measure and to determine the initial patient population from the tbl_physician_selected_measures table.
-- Change #8       Instead, if measure is selected at TIN level then we default physician has selected the measure and 100% submission
-- Change #9 By: Hari j
-- Change #9 date: Jan-05-18
-- Change #9 desc: finding the decile value based on performance rate and reporting rate
-- Change #10 By: Hari j
-- Change #10 date: Jan-17-18
-- Change #10 desc: only isActive=1 values in the tbl_physician_selected_measures should involved in performancerate calculations
-- Change #11 By: Hari j
-- Change #11 date: Feb-14-18
-- Change #11 desc: only Is_90Days=0 values in the tbl_Physician_Aggregation_Year should involved in performancerate calculations
-- Change #11 desc: only Is_90Days=0 values in the tbl_Physician_Selected_Measures should involved in performancerate calculations
-- Change #11 desc: only Is_90Days=0 values in the tbl_GPRO_TIN_Selected_Measures should involved in performancerate calculations
-- Change #15 desc: insert Is_90Days=0 values in the tbl_Physician_Aggregation_Year
-- Change #16  By :  Raju Gaddam
-- Change #16 date: feb 16 2018
-- Change #16 desc: insert TotalExamsCount in  tbl_Physician_Aggregation_Year
-- chnage #19 By: Hari
-- Change #19 date: Mar 1,2018
-- Change #19 Description: for JIRA#504

-- change #13 By: Hari
-- Change #13 date: April 11,2018
-- Change #13 Add CMSyear in tbl_lookup_decile_data:
--exec spReCalculatePerfomanceRateForYearandMeasureID '145','121212121',2017,1
-- Change #14: by hari :on Nov 12th, 2018
-- Change #14 Add  code for stratum of measure 46
-- Change #23: by hari :on Dec 12th, 2018
-- Change #23 JIRA#609
-- Change #24: by hari :on Dec 28th, 2018
-- Change #24 JIRA#618
-- =============================================
CREATE PROCEDURE [dbo].[spReCalculate_PapulatePhyAggrTblForTinofNPIS] 
	-- Add the parameters for the stored procedure here
     @strCurMeasure_num AS VARCHAR(20) ,
	@strCurTIN varchar(25),
    @intCurActiveYear INT  ,
    @Is_90Days bit =0
  --  @strCurNPI VARCHAR(50)
AS 
  BEGIN
   --FETCH NEXT FROM CurSubmission_Year 	INTO @intCurActiveYear
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	DECLARE @strCurNPI VARCHAR(11);
        Declare @strMeasure_num varchar(20);
        DECLARE @intCurMeasureId AS INT

        DECLARE @intCurAggregationID AS INT
      
        DECLARE @intCurUserID AS INT
      
        DECLARE @initPatientPopulation AS INT
        DECLARE @totalValReportedCount AS INT
        DECLARE @DenominatorExclusionCount AS INT
        DECLARE @DenominatorExceptionCount AS INT
        DECLARE @ReportingNumerator AS INT
        DECLARE @ReportingDenominatorCount AS INT

        DECLARE @performanceNumerator AS INT
        DECLARE @performanceDenoCount AS INT
        DECLARE @performanceMetCount AS INT	
        DECLARE @performanceNotMetCount AS INT


        DECLARE @intStrataNum AS INT ;

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
		DECLARE @blnGPRO	as bit;
		Declare @curPrevTin as varchar(12);

		--Hari 1/5-2018 for decilevalue

		DECLARE @decile_Val as varchar(100);

		declare @TotalExamsCount int ;

		declare @PhysicianUserid int ;
	
        SET NOCOUNT ON ;
--Step#0 Update TINS for NON-pqrs purpose.
		--EXECUTE dbo.spGetLatestTINsOfNPI @strNPI = @strCurNPI;
	
--Step#1 Get Active years	
       

        
            BEGIN
		
--Step#2 Get NPI's and TIN
				

                    BEGIN	
					


	--##we are not using tbl_Physician_TIN 
		Declare @PhysicinaTinsofNPI as Table(NPI Varchar(10))
INSERT into @PhysicinaTinsofNPI
select DISTINCT  NPI from NRDR..[PHYSICIAN_TIN_VW] WHERE TIN=@strCurTIN

	 DECLARE CurTINSofNPI CURSOR FOR 
                SELECT distinct NPI from @PhysicinaTinsofNPI T 
           
                OPEN CurTINSofNPI

                FETCH NEXT FROM CurTINSofNPI INTO @strCurNPI

                WHILE @@FETCH_STATUS = 0 
                    BEGIN	

							set @PhysicianUserid =0;
							select  @PhysicianUserid = ISNULL(UserID,0) from tbl_Users where NPI=@strCurNPI;
                   DELETE  FROM [dbo].[tbl_Physician_Aggregation_Year]
                        WHERE    Exam_TIN = @strCurTIN
                                AND CMS_Submission_Year = @intCurActiveYear
						  and Is_90Days=@Is_90Days 
						  and Measure_Num=@strCurMeasure_num
						  and Physician_NPI = @strCurNPI


					set @blnGPRO = 0;			
					if @curPrevTin <> @strCurTIN
					Begin							
							--Check tin gpro status
							--exec sp_getTIN_GPRO @strCurTIN
							set @curPrevTin = @strCurTIN ;
					End
							select top 1  @blnGPRO =  is_GPRO from 
							tbl_TIN_GPRO where ltrim(rtrim(TIN)) = ltrim(rtrim(@strCurTIN))
					
					print 'Calculating for NPI: ' + @strCurNPI + ' TIN: ' +  @strCurTIN 
			



			--Step#3 Get Exam Measures for this NPI,TIN
                 SELECT @intCurMeasureId=(SELECT DISTINCT md.Measure_ID
                        FROM 
				    tbl_Exam e  
                        INNER JOIN tbl_Exam_Measure_Data md
                        ON md.Exam_Id = e.Exam_Id inner join
				    tbl_Lookup_Measure l  on l.[Measure_ID]=md.[Measure_ID]
                        WHERE e.CMS_Submission_Year = @intCurActiveYear 
                        AND e.Physician_NPI = @strCurNPI
                        AND e.Exam_TIN = @strCurTIN
                        AND md.[Status]  IN (2,3)
				    AND l.Measure_num=@strCurMeasure_num
				    )
                            BEGIN
				
                                SET @strMeasure_num = '' ;				
							-- Fill @@strMeasure_num
                                SELECT  @strMeasure_num = Measure_num
                                FROM    tbl_Lookup_Measure
                                WHERE   Measure_ID = @intCurMeasureId
								
								print 'Calculating for NPI: ' + @strCurNPI + ' TIN: ' +  @strCurTIN  + ' measure num' + @strMeasure_num
							IF(@strMeasure_num='46')  -- Change #23 
				BEGIN
				print('measure 46 related stratum code executing')

				EXEC spReCalculate_StratumCalbyAgeforPhy @intCurActiveYear,@strCurNPI,@strCurTIN,@intCurMeasureId,@strMeasure_num,@blnGPRO
				END
				ELSE IF(@strMeasure_num='226')-- Change #24 
				BEGIN
					print('measure 226 related stratum code executing')
					EXEC spReCalculate_Measure226ForPhy @strCurNPI,@strCurTIN,@intCurActiveYear,@strMeasure_num,@blnGPRO
				END
				ELSE ---******non stratum starts***----------
				BEGIN

	
							-- Step#4 Get info for received measure is selected for CMS submission		
				
                                IF EXISTS ( SELECT  *
                                            FROM    dbo.tbl_Physician_Selected_Measures
                                            WHERE   NPI = @strCurNPI
                                                    AND TIN = @strCurTIN
                                                    AND Submission_year = @intCurActiveYear
                                                    AND Measure_num_ID = @strMeasure_num 
										  and Is_Active=1 --Change #10
										  and Is_90Days=0 -- Change #11
											) 
											BEGIN
													SELECT  @blnSelectedForSubmission = SelectedForSubmission ,
															@intTotalCasesReviewed = TotalCasesReviewed ,
															@blnHundredPercentSubmit = HundredPercentSubmit
													FROM    dbo.tbl_Physician_Selected_Measures
													WHERE   NPI = @strCurNPI
															AND TIN = @strCurTIN
															AND Submission_year = @intCurActiveYear
															AND Measure_num_ID = @strMeasure_num
															 and Is_Active=1 --Change #10
															  and Is_90Days=0 -- Change #11
											END
                                ELSE 
											BEGIN
												SET @blnSelectedForSubmission = 0 ;
												SET @intTotalCasesReviewed = NULL ;
												SET @blnHundredPercentSubmit = 0 ;

										-- <change#2>
										-- Added by Prashanth kumar Garlapally dec-13,2016
										-- This could be a GPRO TIN so take Facility selection data
										
											IF EXISTS ( SELECT top 1 *
														FROM    [dbo].[tbl_GPRO_TIN_Selected_Measures]
																WHERE TIN = @strCurTIN
																AND  Submission_year= @intCurActiveYear
																AND Measure_Num = @strMeasure_num 
																 and Is_90Days=0 -- Change #11
																  and Is_Active=1 --Change #10
																) 
												BEGIN
												--select @strCurTIN,@intCurActiveYear,@strMeasure_num,@intCurMeasureId
												
													SET @blnSelectedForSubmission = 1 ;
													SET @intTotalCasesReviewed = NULL ;
													SET @blnHundredPercentSubmit = 1 ;
												END
											END
											-- </change#2>
						

				
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

				
				-- Fill @totalValReportedCount
                                SELECT  @totalValReportedCount = COUNT(md.Measure_ID)
                                FROM    tbl_Exam e WITH ( NOLOCK )
                                        INNER JOIN tbl_Exam_Measure_Data md
                                        WITH ( NOLOCK ) ON md.Exam_Id = e.Exam_Id
                                WHERE   e.CMS_Submission_Year = @intCurActiveYear
                                        AND e.Physician_NPI = @strCurNPI
                                        AND e.Exam_TIN = @strCurTIN
                                        AND md.Measure_ID = @intCurMeasureId
                                        AND md.[Status] IN ( 2, 3 )

				SET @TotalExamsCount =@totalValReportedCount; --Change #16
				-- Set population
				--select  @blnSelectedForSubmission as '@blnSelectedForSubmission'
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
				
				
			
				
                                IF ( @ReportingDenominatorCount < 1 ) 
                                    BEGIN
                                        SET @ReportingDenominatorCount = NULL ;
                                    END
				
				
				-- Fill @DenominatorExceptionCount
                                SELECT  @DenominatorExceptionCount = COUNT(md.Measure_ID)
                                FROM    tbl_Exam e WITH ( NOLOCK )
                                        INNER JOIN tbl_Exam_Measure_Data md
                                        WITH ( NOLOCK ) ON md.Exam_Id = e.Exam_Id
                                        INNER JOIN tbl_lookup_Numerator_Code N
                                        WITH ( NOLOCK ) ON N.Measure_ID = md.Measure_ID
                                WHERE   e.CMS_Submission_Year = @intCurActiveYear
                                        AND e.Physician_NPI = @strCurNPI
                                        AND e.Exam_TIN = @strCurTIN
                                        AND md.Measure_ID = @intCurMeasureId
                                        AND N.Numerator_response_Value = md.Numerator_response_value
                                        AND n.Denominator_Exceptions IN ( 'Y', 'y' )
                                        AND md.[Status] IN ( 2, 3 )
				--<change#3>
			-- Fill @@DenominatorExclusionCount
								  SELECT  @DenominatorExclusionCount = COUNT(md.Measure_ID)
                                FROM    tbl_Exam e WITH ( NOLOCK )
                                        INNER JOIN tbl_Exam_Measure_Data md
                                        WITH ( NOLOCK ) ON md.Exam_Id = e.Exam_Id
                                        INNER JOIN tbl_lookup_Numerator_Code N
                                        WITH ( NOLOCK ) ON N.Measure_ID = md.Measure_ID
                                WHERE   e.CMS_Submission_Year = @intCurActiveYear
                                        AND e.Physician_NPI = @strCurNPI
                                        AND e.Exam_TIN = @strCurTIN
                                        AND md.Measure_ID = @intCurMeasureId
                                        AND N.Numerator_response_Value = md.Numerator_response_value
                                        AND n.Exclusion IN ( 'Y', 'y' )
                                        AND md.[Status] IN ( 2, 3 )				
				--</change#3>

				-- Fill @performanceMetCount
                                SELECT  @performanceMetCount = COUNT(md.Measure_ID)
                                FROM    tbl_Exam e WITH ( NOLOCK )
                                        INNER JOIN tbl_Exam_Measure_Data md
                                        WITH ( NOLOCK ) ON md.Exam_Id = e.Exam_Id
                                        INNER JOIN tbl_lookup_Numerator_Code N
                                        WITH ( NOLOCK ) ON N.Measure_ID = md.Measure_ID
                                WHERE   e.CMS_Submission_Year = @intCurActiveYear
                                        AND e.Physician_NPI = @strCurNPI
                                        AND e.Exam_TIN = @strCurTIN
                                        AND md.Measure_ID = @intCurMeasureId
                                        AND N.Numerator_response_Value = md.Numerator_response_value
                                        AND n.Performance_met IN ( 'Y', 'y' )
                                        AND md.[Status] IN ( 2, 3 )
				
				-- Fill @performanceNotMetCount
                                SELECT  @performanceNotMetCount = COUNT(md.Measure_ID)
                                FROM    tbl_Exam e WITH ( NOLOCK )
                                        INNER JOIN tbl_Exam_Measure_Data md
                                        WITH ( NOLOCK ) ON md.Exam_Id = e.Exam_Id
                                        INNER JOIN tbl_lookup_Numerator_Code N
                                        WITH ( NOLOCK ) ON N.Measure_ID = md.Measure_ID
                                WHERE   e.CMS_Submission_Year = @intCurActiveYear
                                        AND e.Physician_NPI = @strCurNPI
                                        AND e.Exam_TIN = @strCurTIN
                                        AND md.Measure_ID = @intCurMeasureId
                                        AND N.Numerator_response_Value = md.Numerator_response_value
                                        AND n.Performance_met IN ( 'N', 'n' )
                                        AND md.[Status] IN ( 2, 3 )

								--  set reportingDenominator
                                IF ISNULL(@initPatientPopulation, 0) > 0 
									BEGIN
								 -- King Lo 02/20/2015: ReportingDenominatorCount should be the same as initPatientPopulation
								 --<change#4>

								  -- SET @ReportingDenominatorCount = @initPatientPopulation ;
									SET  @ReportingDenominatorCount = @initPatientPopulation - @DenominatorExclusionCount;
						

								--</change#4>
                                      
                                    END
				
                                SET @performanceNumerator = @performanceMetCount ;
                                SET @performanceDenoCount = @performanceMetCount  + @performanceNotMetCount ;	

				--King Lo 02/20/2015 - DenominatorExceptionCount can be null			
				--set @ReportingNumerator = @performanceNumerator + @DenominatorExceptionCount + @performanceNotMetCount;
                                SET @ReportingNumerator = @performanceNumerator + ISNULL(@DenominatorExceptionCount, 0)  + @performanceNotMetCount ;
				
				
					
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


                                -- King Lo 2/28/15
								-- Need to include performanceNumerator = 0; in this case
								-- performanceRate will be 0 instead of null

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
                                FROM    tbl_exam e
                                        INNER JOIN tbl_exam_measure_data md ON md.Exam_Id = e.Exam_Id
                                        INNER JOIN tbl_Lookup_Measure m ON m.Measure_ID = md.Measure_ID
                                WHERE   md.[Status] IN ( 2, 3 )
                                        AND e.Physician_NPI = @strCurNPI
                                        AND e.Exam_TIN = @strCurTIN
                                        AND m.Measure_num = @strMeasure_num
                                        AND e.CMS_Submission_Year = @intCurActiveYear
                                GROUP BY e.CMS_Submission_Year ,
                                        md.[Status] ,
                                        e.Physician_NPI ,
                                        e.Exam_TIN ,
                                        m.Measure_num
				
				----Change #9
				-- SET @decile_Val=NULL
				-- IF((@reportingRate < 50 ) and (@reportingRate is not  null ) )
				-- begin
				--SET @decile_Val='3 Points'
				-- end
				-- else if(@reportingRate >= 50)
				-- begin
				-- -- call function fnGetDecileValue
				-- select @decile_Val= dbo.fnGetDecileValue(@strMeasure_num,@performanceRate,@intCurActiveYear) --Change# 13
				-- select @decile_Val=ISNULL(@decile_Val,'3 Points')
				-- end

				--	IF(@intCurActiveYear <=2017)
				--		BEGIN
														
				----Change #13
			 --SET @decile_Val=NULL
				--  IF((@reportingRate < 50 ) and (@reportingRate is not null ) )
				-- begin
				--SET @decile_Val='3 Points'
				-- end
				-- else if(@reportingRate >= 50)
				-- begin
				-- -- call function fnGetDecileValue
				--select @decile_Val= dbo.fnGetDecileValue(@strMeasure_num,@performanceRate,@intCurActiveYear) --change# 20
				-- select @decile_Val=ISNULL(@decile_Val,'3 Points')
				-- end


				--END
				--ELSE IF(@intCurActiveYear >= 2018)--Change #23
				--BEGIN
				-- SET @decile_Val=NULL
				--IF(((@reportingRate < 60 ) and (@reportingRate is not null ) )OR  (@TotalExamsCount < 20))
				-- begin
				--SET @decile_Val='1 Point'
				-- end
				-- else if(@reportingRate >= 60)
				-- begin
				-- -- call function fnGetDecileValue
				--select @decile_Val= dbo.fnGetDecileValue(@strMeasure_num,@performanceRate,@intCurActiveYear) --change# 20
				-- select @decile_Val=ISNULL(@decile_Val,'1 Point')
				-- end

				--END

				select @decile_Val= dbo.fnYearwiseDecileLogic(@strMeasure_num,@performanceRate,@intCurActiveYear,@reportingRate,@TotalExamsCount) 



				                
				
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
           
                                        )
                                VALUES  ( @intCurActiveYear  --1)         
                                          ,
                                          @strCurNPI --2)
                                          ,
                                          @strCurTIN --3)
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
                                               -- WHEN @performanceRate = 0
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
										  @decile_Val
										  ,0
										  ,@TotalExamsCount --Change #16
                                        )

							
				
                               
                            END 
               
					END---******non stratum ENDS***----------
------------------------------------------------------------------------------------------				
			-- Step#B get NON PQRS measures from dbo.tbl_Non_PQRS_Aggregation_Year
                        DECLARE CurNonPQRSMeasures CURSOR FOR
                        SELECT Aggregation_Id,Measure_Num FROM tbl_Non_PQRS_Aggregation_Year  
                        WHERE CMS_Submission_Year  = @intCurActiveYear
                        AND Physician_NPI  = @strCurNPI
                        AND Exam_Tin = @strCurTIN
				    AND Measure_Num=@strCurMeasure_num
				     and (Is_90Days=0 or Is_90Days is null) -- Change #19 
                        OPEN CurNonPQRSMeasures
                        FETCH NEXT FROM CurNonPQRSMeasures 
				INTO @intCurAggregationID,@strCurMeasure_num				
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
                                FROM    tbl_Non_PQRS_Aggregation_Year n
                                WHERE   n.Aggregation_Id = @intCurAggregationID
					------
					set @TotalExamsCount =0; --Change #16
					  set @TotalExamsCount =@totalValReportedCount; --Change #16
 --<change#8>
			IF (@blnGPRO = 0)
			   BEGIN
--</change#8>

                                IF EXISTS ( SELECT  *
                                            FROM    dbo.tbl_Physician_Selected_Measures
                                            WHERE   NPI = @strCurNPI
                                                    AND TIN = @strCurTIN
                                                    AND Submission_year = @intCurActiveYear
                                                    AND Measure_num_ID = @strCurMeasure_num 
										    and Is_Active=1 --Change #10
										     and Is_90Days=0 -- Change #11
										    ) 
                                    BEGIN
                                        SELECT  @blnSelectedForSubmission = SelectedForSubmission ,
                                                @intTotalCasesReviewed = TotalCasesReviewed ,
                                                @blnHundredPercentSubmit = HundredPercentSubmit
                                        FROM    dbo.tbl_Physician_Selected_Measures
                                        WHERE   NPI = @strCurNPI
                                                AND TIN = @strCurTIN
                                                AND Submission_year = @intCurActiveYear
                                                AND Measure_num_ID = @strCurMeasure_num
									     and Is_Active=1	--Change #10
										 and Is_90Days=0 -- Change #11					
							
                                    END
                                ELSE 
                                    BEGIN
                                        SET @blnSelectedForSubmission = 0 ;
                                        SET @intTotalCasesReviewed = NULL ;
                                        SET @blnHundredPercentSubmit = 0 ;
							
                                    END
			    END -- GPRO = 0
                --<change#8>
			  ELSE -- GPRO = 1; if this measure is selected at the TIN level then we need to set the initial patient population
                               -- and reporting denominator for the current TIN NPI; otherwise the reporting rate at the TIN NPI level
                               -- won't be displayed on the Performance Report page. 
                            BEGIN
				IF EXISTS ( SELECT  *
                                            FROM    dbo.tbl_GPRO_TIN_Selected_Measures
                                            WHERE   TIN = @strCurTIN
                                                    AND Submission_year = @intCurActiveYear
                                                    AND Measure_num = @strCurMeasure_num
						    AND SelectedForSubmission = 1
						     and Is_90Days=0 -- Change #11
							and Is_Active=1 --Change #10
						     )
                                    BEGIN
                                       SET @blnSelectedForSubmission = 1;
									   SET @blnHundredPercentSubmit = 1
                                    END
                                ELSE
                                    BEGIN
                                        SET @blnSelectedForSubmission = 0 ;
										SET @intTotalCasesReviewed = NULL ;
                                        SET @blnHundredPercentSubmit = 0 ;
                                    END

                            END 	
		  --</change#8>			
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

				
				--  set reportingDenominator
                                IF ISNULL(@initPatientPopulation, 0) > 0 
                                    BEGIN
				 -- King Lo 02/20/2015: ReportingDenominatorCount should be the same as initPatientPopulation
				 -- set  @ReportingDenominatorCount = @initPatientPopulation - @DenominatorExclusionCount;
                                        SET @ReportingDenominatorCount = @initPatientPopulation ;
                                    END
					
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
										  [Decile_Val],
										  [Is_90Days],
										  [TotalExamsCount] --Change #16

           
                                        )
                                VALUES  ( @intCurActiveYear  --1)         
                                          ,
                                          @strCurNPI --2)
                                          ,
                                          @strCurTIN --3)
                                          ,
                                          @initPatientPopulation --4)
                                          ,
                                          @ReportingDenominatorCount -- 5a
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
										  @decile_Val,0
										  ,@TotalExamsCount --Change #16
                                        )
				
                                FETCH NEXT FROM CurNonPQRSMeasures 
					INTO @intCurAggregationID,@strCurMeasure_num			
                            END
                        CLOSE CurNonPQRSMeasures ;
                        DEALLOCATE CurNonPQRSMeasures ;
			
                    END 
          
                
                
        --IF EXISTS ( SELECT  *
        --            FROM    dbo.tbl_Scheduled_Jobs_Log_Data l
        --            WHERE   l.LogForYear = @intCurActiveYear
        --                    AND l.LogName = 'PerformanceRecalculate' ) 
        --    BEGIN
        --        UPDATE  dbo.tbl_Scheduled_Jobs_Log_Data
        --        SET     LogTime = GETDATE() ,
        --                LogValue = 1
        --        WHERE   LogName = 'PerformanceRecalculate'

        --    END
        --ELSE 
        --    BEGIN
        --        INSERT  INTO tbl_Scheduled_Jobs_Log_Data
        --                ( LogName ,
        --                  LogForYear ,
        --                  LogValue ,
        --                  LogTime
        --                )
        --        VALUES  ( 'PerformanceRecalculate' ,
        --                  @intCurActiveYear ,
        --                  1 ,
        --                  GETDATE()
        --                )
        --    END
                	
				--<change#6>
			update tbl_Physician_Aggregation_Year
				set
				SelectedForCMSSubmission = 1
				from tbl_Physician_Aggregation_Year p inner join tbl_GPRO_TIN_Selected_Measures G on
				G.Submission_year = p.CMS_Submission_Year and G.Measure_num = p.Measure_Num
				and G.TIN = p.Exam_TIN
				where G.SelectedForSubmission = 1
				and p.CMS_Submission_Year = @intCurActiveYear
				and p.Measure_Num=@strCurMeasure_num
				 and p.Is_90Days=0 --Change #11
				  and G.Is_90Days=0 --Change #11
				  and G.Is_Active=1 --Change #10
			--</change#6>

               
                         FETCH NEXT FROM CurTINSofNPI INTO @strCurNPI
                    END 
                CLOSE CurTINSofNPI ;
                DEALLOCATE CurTINSofNPI ;	
            END 

			
    END


