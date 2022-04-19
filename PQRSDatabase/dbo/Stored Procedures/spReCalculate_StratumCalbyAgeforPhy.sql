



-- =============================================
-- Author:		harikrishna
--created Date:Nov,12th,2018
--used to calculate performance for stratum measures based on AGE
-- Change #23: by hari :on Dec 12th, 2018
-- Change #23 JIRA#609
-- =============================================
CREATE PROCEDURE [dbo].[spReCalculate_StratumCalbyAgeforPhy] 
	-- Add the parameters for the stored procedure here
    @intCurActiveYear INT = 0 ,
    @strCurNPI VARCHAR(50) = '',
    @strCurTIN varchar(50),
    @intCurMeasureId int,
  --  @blnSelectedForSubmission BIT,
    @strMeasure_num AS VARCHAR(20) ,
    @blnGPRO bit

AS 
    BEGIN
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
     --   DECLARE @strMeasure_num AS VARCHAR(20) ;

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
		--DECLARE @blnGPRO	as bit;
		Declare @curPrevTin as varchar(12);

		--Hari 1/5-2018 for decilevalue

		DECLARE @decile_Val as varchar(100);

		declare @TotalExamsCount int ;

		declare @PhysicianUserid int ;

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

							BEGIN

	
							-- Step#4 Get info for received measure is selected for CMS submission		
				
                                IF EXISTS ( SELECT  1
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
										
											IF EXISTS ( SELECT 1
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
								AND e.Patient_Age >= @CurStart_Age	AND e.Patient_Age <= @CurEnd_Age

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
								AND e.Patient_Age >= @CurStart_Age	AND e.Patient_Age <= @CurEnd_Age
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
								AND e.Patient_Age >= @CurStart_Age	AND e.Patient_Age <= @CurEnd_Age			
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
								AND e.Patient_Age >= @CurStart_Age	AND e.Patient_Age <= @CurEnd_Age
				
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
								AND e.Patient_Age >= @CurStart_Age	AND e.Patient_Age <= @CurEnd_Age

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
								AND e.Patient_Age >= @CurStart_Age	AND e.Patient_Age <= @CurEnd_Age
                                GROUP BY e.CMS_Submission_Year ,
                                        md.[Status] ,
                                        e.Physician_NPI ,
                                        e.Exam_TIN ,
                                        m.Measure_num
				
			

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
										  ,[Stratum_Id]--26
           
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
										  ,@CurStratum_Id--26
                                        )
							
				
                               
                            END
			
              	FETCH NEXT FROM CurStratum 	INTO @CurStart_Age,@CurEnd_Age,@CurStratum_Id
            END 
        CLOSE CurStratum ;
        DEALLOCATE CurStratum ;				
				
    END

