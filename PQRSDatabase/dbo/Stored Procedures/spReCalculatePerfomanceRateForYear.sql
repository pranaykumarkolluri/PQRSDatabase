



-- =============================================
-- Author:		Hari J
-- Create date: 10/11/2019
-- Description:This sp completly overriden by old SP. Just changed the execution plan for JIRA#745. It donesn't change any existing Performance calculation logic.
-- Change #1 JIRA#753 By Hari on Jan 2nd 2020
-- Change #2 JIRA#767 By Hari on Feb 17th 2020
-- Change #3 JIRA#786 By Hari on May 5th 2020
-- Change #4 pass gpro value -- Hari on Jan 4th 2021
--Change #5: call the SP 'SPCI_Submission_Email_Remainder_nonGPRO' internally -- hari on Feb 26th,2021
--Change#6: update gpro value column in tbl_Physician_Aggregation_Year -- hari on Feb 26th,2021
-- Change#7: JIRA#955, hari on June 8th,2021
-- Change#8 : JIRA#973  , pranay on July 15,2021
--Change#9 : JIRA#1012 ,Sai on August 16th,2021 -- Adding BatchFileProcess
--Chang#10 : JIRA#1057 , Pranay on Oct 1st 2021
-- =============================================
CREATE PROCEDURE [dbo].[spReCalculatePerfomanceRateForYear]
	-- Add the parameters for the stored procedure here
    @intYear INT = 0 ,
    @strPhysicianNPI VARCHAR(50) = '',
	@strTIN VARCHAR(50) = ''-- Change #3
AS 
    BEGIN
	

DECLARE @tbl_Physician_Aggr as TABLE(
	[Aggregation_Id] [int] IDENTITY(1,1) NOT NULL,
	[CMS_Submission_Year] [int] NOT NULL,
	[CMS_Submission_Date] [datetime] NULL,
	[Physician_NPI] [varchar](50) NOT NULL,
	[Exam_TIN] [varchar](10) NOT NULL,
	[Measure_Num] [varchar](50) NULL,
	[Strata_num] [int] NULL,
	[SelectedForCMSSubmission] [bit] NULL,
	[Init_Patient_Population] [int] NULL,
	[Reporting_Denominator] [int] NULL,
	[Reporting_Numerator] [int] NULL,
	[Exclusion] [int]  NULL ,
	[Performance_denominator] [int] NOT NULL,
	[Performance_Numerator] [decimal](18, 2) NULL,-- Change #2
	[Denominator_Exceptions] [int] NULL,
	[Denominator_Exclusions] [int] NULL,
	[Performance_Not_Met] [int] NULL,
	[Performance_Met] [int] NULL,
	[Reporting_Rate] [decimal](18, 4) NULL,
	[Performance_rate] [decimal](18, 4) NULL,
	[Created_Date] [datetime] NOT NULL,
	[Created_By] [int] NOT NULL,
	[Last_Mod_Date] [datetime] NULL,
	[Last_Mod_By] [int] NULL,
	[Encounter_From_Date] [datetime] NULL,
	[Encounter_To_Date] [datetime] NULL,
	[Benchmark_met] [nvarchar](1) NULL,
	[GPRO] [bit] NULL ,
	[Decile_Val] [varchar](50) NULL,
	[Is_90Days] [bit] NULL ,
	[TotalExamsCount] [int] NULL,
	[Stratum_Id] [int] NULL,
	TotalCasesReviewed INT NULL,
	HundredPercentSubmit BIT,
	IsNotMIPSMeasure BIT,
	[observationInstances] int null,
	-- Change#8
	[Original_Reporting_Denominator] [int] NULL,
    [Original_Reporting_Numerator] [int] NULL,
    [Original_Reporting_Rate] [decimal](18, 4) NULL
	)
	

		print('Recalculate Performance  SP Started start time'+CONVERT( VARCHAR(24), GETDATE(), 113));	

 SET @strTIN=ISNULL(@strTIN,'');
 SET @strPhysicianNPI=ISNULL(@strPhysicianNPI,'');

   DELETE FROM [dbo].[tbl_Physician_Aggregation_Year]
                        WHERE   
                                 CMS_Submission_Year = @intYear
						  and Is_90Days=0   --Change #11
						  AND Physician_NPI= CASE WHEN @strPhysicianNPI='' THEN Physician_NPI
						                          ELSE @strPhysicianNPI END 
					       AND Exam_TIN= CASE WHEN @strTIN='' THEN Exam_TIN
						                          ELSE @strTIN END 

 DELETE FROM [dbo].[tbl_ReportingRateGreaterThan100]

    

Declare @PhysicinaTins as Table(NPI Varchar(10),
TIN Varchar(9))
INSERT into @PhysicinaTins
--select DISTINCT  NPI,TIN from NRDR..[PHYSICIAN_TIN_VW]

select DISTINCT  NPI,TIN from NRDR..[PHYSICIAN_TIN_VW] WHERE 
NPI= CASE WHEN @strPhysicianNPI='' THEN NPI ELSE @strPhysicianNPI END 
AND IS_ACTIVE=1--Change#7
AND IS_ENROLLED =1 and REGISTRY_NAME ='MIPS' --Change#10
AND TIN =CASE WHEN @strTIN='' THEN TIN ELSE @strTIN END
--AND TIN='232323232'


Declare @PhysicianQCDRtins as Table(NPI Varchar(10),
TIN Varchar(9))
INSERT into @PhysicianQCDRtins
select DISTINCT  NPI,TIN from NRDR..[PHYSICIAN_TIN_VW] WHERE 
NPI= CASE WHEN @strPhysicianNPI='' THEN NPI ELSE @strPhysicianNPI END 
AND IS_ACTIVE=1
AND IS_ENROLLED =1
AND TIN =CASE WHEN @strTIN='' THEN TIN ELSE @strTIN END	

	-----------------UPDATE TBL_TIN_GPRO Starts ---------------
	DECLARE @strCurTIN VARCHAR(9);
	 DECLARE CurTINS CURSOR FOR 
                SELECT distinct T.TIN FROM tbl_Users U WITH(NOLOCK) 
                
				 INNER JOIN @PhysicinaTins T 
                ON T.NPI = U.NPI
                OPEN CurTINS

                FETCH NEXT FROM CurTINS INTO @strCurTIN

                WHILE @@FETCH_STATUS = 0 
                BEGIN	
			 	exec sp_getTIN_GPRO @strCurTIN

               FETCH NEXT FROM CurTINS INTO @strCurTIN
                    END 
                CLOSE CurTINS ;
                DEALLOCATE CurTINS ;	

			 print('Recalculate Performance: TBl_TIN_GPRO Table populated '+CONVERT( VARCHAR(24), GETDATE(), 113));	

  	-----------------UPDATE TBL_TIN_GPRO ENDs ---------------



-----------Performance Calculation For MIPS Measures Except ('226','143')   ------Starts

Declare @PhysicinaAggrData as Table(NPI Varchar(10),
TIN Varchar(9),Measure_ID int,Measure_num varchar (500),MeasuresCount int)


INSERT INTO @PhysicinaAggrData 

SELECT P.NPI,P.TIN,E.Measure_ID, E.Measure_num,E.MeasureCount as MeasuresCount FROM @PhysicinaTins P INNER JOIN  PRExamMeasure_VW E  ON 
                                                                           P.NPI=e.Physician_NPI
															And P.TIN=E.Exam_TIN
       
        WHERE e.CMS_Submission_Year = @intYear     
	     -- AND E.Measure_num NOT IN ('226','46','143')     
		   AND E.Measure_num NOT IN ('226','143','409')       
		    
--SELECT DISTINCT P.NPI,P.TIN,md.Measure_ID, L.Measure_num FROM @PhysicinaTins P INNER JOIN   tbl_Exam e WITH ( NOLOCK ) ON P.TIN=e.Exam_TIN
--                                                                                AND P.NPI=e.Physician_NPI
--        INNER JOIN tbl_Exam_Measure_Data md WITH ( NOLOCK ) ON md.Exam_Id = e.Exam_Id
--	   INNER JOIN tbl_Lookup_Measure L ON L.Measure_ID=md.Measure_ID AND L.CMSYear=e.CMS_Submission_Year
--        WHERE e.CMS_Submission_Year = @intYear                        
--        AND md.[Status]  IN (2,3)
--	   AND L.Measure_num NOT IN ('226','46')
				    



INSERT INTO @tbl_Physician_Aggr
SELECT 
  @intYear as [CMS_Submission_Year]
     , null as [CMS_Submission_Date]
     , t.NPI as [Physician_NPI]
     , t.TIN as [Exam_TIN]
     , t.Measure_num as [Measure_Num]
     , 1 as [Strata_num]
     , NULL as [SelectedForCMSSubmission]
     , NULL as [Init_Patient_Population]
     , 0 as [Reporting_Denominator]
     , 0 as [Reporting_Numerator]
     , 0 as [Exclusion]
     , 0 as [Performance_denominator]
     , 0 as [Performance_Numerator]
     , (  SELECT COUNT(E.Measure_ID)
                                FROM    PRExamNumerator_VW E WITH(NOEXPAND)
                                 WHERE   e.CMS_Submission_Year = @intYear
                                        AND e.Physician_NPI = t.NPI
                                        AND e.Exam_TIN = t.TIN
                                        AND E.Measure_ID = t.Measure_ID                                      
                                        AND E.Denominator_Exceptions IN ( 'Y', 'y' )
                                     ) as [Denominator_Exceptions]
       , (  SELECT COUNT(E.Measure_ID)
                                FROM    PRExamNumerator_VW E WITH(NOEXPAND)
                                 WHERE   e.CMS_Submission_Year = @intYear
                                        AND e.Physician_NPI = t.NPI
                                        AND e.Exam_TIN = t.TIN
                                        AND E.Measure_ID = t.Measure_ID  
                                        AND E.Exclusion IN ( 'Y', 'y' )
                                       )as [Denominator_Exclusions]
        , (  SELECT COUNT(E.Measure_ID)
                                FROM    PRExamNumerator_VW E WITH(NOEXPAND)
                                 WHERE   e.CMS_Submission_Year = @intYear
                                        AND e.Physician_NPI = t.NPI
                                        AND e.Exam_TIN = t.TIN
                                        AND E.Measure_ID = t.Measure_ID  
                                        AND E.Performance_met IN ( 'N', 'n' )
                                        ) as [Performance_Not_Met]
     , (  SELECT COUNT(E.Measure_ID)
                                FROM    PRExamNumerator_VW E WITH(NOEXPAND)
                                 WHERE   e.CMS_Submission_Year = @intYear
                                        AND e.Physician_NPI = t.NPI
                                        AND e.Exam_TIN = t.TIN
                                        AND E.Measure_ID = t.Measure_ID  
                                        AND E.Performance_met IN ( 'Y', 'y' )
                                               ) as [Performance_Met]
     , 0 as [Reporting_Rate]
     , 0 as [Performance_rate]
     , GETDATE() as [Created_Date]
     , 0 as [Created_By]
     , GETDATE() as [Last_Mod_Date]
     , 0 as [Last_Mod_By]
     , (  SELECT      MIN(Exam_Date)
                                  FROM    PRExamNumerator_VW E WITH(NOEXPAND)
                               WHERE   e.CMS_Submission_Year = @intYear
                                        AND e.Physician_NPI = t.NPI
                                        AND e.Exam_TIN = t.TIN
                                        AND E.Measure_ID = t.Measure_ID  
                                                  ) as [Encounter_From_Date]
      , (  SELECT      MAX(Exam_Date)
                                  FROM    PRExamNumerator_VW E WITH(NOEXPAND)
                               WHERE   e.CMS_Submission_Year = @intYear
                                        AND e.Physician_NPI = t.NPI
                                        AND e.Exam_TIN = t.TIN
                                        AND E.Measure_ID = t.Measure_ID  
                                        AND e.CMS_Submission_Year = @intYear) as [Encounter_To_Date]
     , null as [Benchmark_met]
     , 0 as [GPRO]
    , null as [Decile_Val]
     , 0 as [Is_90Days]
     , t.MeasuresCount
     , 0 as [Stratum_Id]	
	,NULL AS initPatientPopulation  
	, NULL AS HundredPercentSubmit 	
	,0
	,0 as observationInstances
	-- Change#8
	 , 0 as [Original_Reporting_Denominator]
     , 0 as [Original_Reporting_Numerator]
	  , 0 as [Original_Reporting_Rate]
from @PhysicinaAggrData t where t.Measure_num NOT IN ('46','409')

------------FOR Measure 46----- STARTS


INSERT INTO @tbl_Physician_Aggr
SELECT 
  @intYear as [CMS_Submission_Year]
     , null as [CMS_Submission_Date]
     , t.NPI as [Physician_NPI]
     , t.TIN as [Exam_TIN]
     , t.Measure_num as [Measure_Num]
     , 1 as [Strata_num]
     , NULL as [SelectedForCMSSubmission]
     , NULL as [Init_Patient_Population]
     , 0 as [Reporting_Denominator]
     , 0 as [Reporting_Numerator]
     , 0 as [Exclusion]
     , 0 as [Performance_denominator]
     , 0 as [Performance_Numerator]
     , (  SELECT COUNT(E.Measure_ID)
                                FROM    PRExamNumerator_VW E WITH(NOEXPAND)
                                 WHERE   e.CMS_Submission_Year = @intYear
                                        AND e.Physician_NPI = t.NPI
                                        AND e.Exam_TIN = t.TIN
                                        AND E.Measure_ID = t.Measure_ID                                      
                                        AND E.Denominator_Exceptions IN ( 'Y', 'y' )
								AND e.Patient_Age >= S.Start_Age	AND e.Patient_Age <= S.End_Age
                                     ) as [Denominator_Exceptions]
       , (  SELECT COUNT(E.Measure_ID)
                                FROM    PRExamNumerator_VW E WITH(NOEXPAND)
                                 WHERE   e.CMS_Submission_Year = @intYear
                                        AND e.Physician_NPI = t.NPI
                                        AND e.Exam_TIN = t.TIN
                                        AND E.Measure_ID = t.Measure_ID  
                                        AND E.Exclusion IN ( 'Y', 'y' )
								AND e.Patient_Age >= S.Start_Age	AND e.Patient_Age <= S.End_Age
                                       )as [Denominator_Exclusions]
        , (  SELECT COUNT(E.Measure_ID)
                                FROM    PRExamNumerator_VW E WITH(NOEXPAND)
                                 WHERE   e.CMS_Submission_Year = @intYear
                                        AND e.Physician_NPI = t.NPI
                                        AND e.Exam_TIN = t.TIN
                                        AND E.Measure_ID = t.Measure_ID  
                                        AND E.Performance_met IN ( 'N', 'n' )
								AND e.Patient_Age >= S.Start_Age	AND e.Patient_Age <= S.End_Age
                                        ) as [Performance_Not_Met]
     , (  SELECT COUNT(E.Measure_ID)
                                FROM    PRExamNumerator_VW E WITH(NOEXPAND)
                                 WHERE   e.CMS_Submission_Year = @intYear
                                        AND e.Physician_NPI = t.NPI
                                        AND e.Exam_TIN = t.TIN
                                        AND E.Measure_ID = t.Measure_ID  
                                        AND E.Performance_met IN ( 'Y', 'y' )
								AND e.Patient_Age >= S.Start_Age	AND e.Patient_Age <= S.End_Age
                                               ) as [Performance_Met]
     , 0 as [Reporting_Rate]
     , 0 as [Performance_rate]
     , GETDATE() as [Created_Date]
     , 0 as [Created_By]
     , GETDATE() as [Last_Mod_Date]
     , 0 as [Last_Mod_By]
     , (  SELECT      MIN(Exam_Date)
                                  FROM    PRExamNumerator_VW E 
                               WHERE   e.CMS_Submission_Year = @intYear
                                        AND e.Physician_NPI = t.NPI
                                        AND e.Exam_TIN = t.TIN
                                        AND E.Measure_ID = t.Measure_ID  
								AND e.Patient_Age >= S.Start_Age	AND e.Patient_Age <= S.End_Age
                                                  ) as [Encounter_From_Date]
      , (  SELECT      MAX(Exam_Date)
                                  FROM    PRExamNumerator_VW E 
                               WHERE   e.CMS_Submission_Year = @intYear
                                        AND e.Physician_NPI = t.NPI
                                        AND e.Exam_TIN = t.TIN
                                        AND E.Measure_ID = t.Measure_ID  
                                        AND e.CMS_Submission_Year = @intYear
								AND e.Patient_Age >= S.Start_Age	AND e.Patient_Age <= S.End_Age
								--AND E.
								) as [Encounter_To_Date]
     , null as [Benchmark_met]
     , 0 as [GPRO]
    , null as [Decile_Val]
     , 0 as [Is_90Days]
     , t.MeasuresCount
     , S.Stratum_Id as [Stratum_Id]	
	,NULL AS initPatientPopulation  
	, NULL AS HundredPercentSubmit 	
	,0
	,0 as observationInstances
	-- Change#8
	 , 0 as [Original_Reporting_Denominator]
     , 0 as [Original_Reporting_Numerator]
	  , 0 as [Original_Reporting_Rate]	
from @PhysicinaAggrData t INNER JOIN tbl_Lookup_Stratum S on t.Measure_num=S.Measure_Num and S.Measure_Num='46'


------------FOR Measure 46----- ENDS

UPDATE A SET SelectedForCMSSubmission=ISNULL(P.SelectedForSubmission,0),
             HundredPercentSubmit=ISNULL(P.HundredPercentSubmit,0),
		   TotalCasesReviewed=ISNULL(P.TotalCasesReviewed,0)  
                                          FROM @tbl_Physician_Aggr A INNER JOIN  tbl_Physician_Selected_Measures P ON  A.Exam_TIN=P.TIN 
                                                                                                         AND A.Physician_NPI=P.NPI
																					AND  A.CMS_Submission_Year=P.Submission_year
																					AND A.Measure_Num=P.Measure_num_ID
																					and P.Is_Active=1
																					AND P.Is_90Days=0


UPDATE A SET SelectedForCMSSubmission=1,
             HundredPercentSubmit=1
		   --TotalCasesReviewed=ISNULL(P.TotalCasesReviewed,1)  
                                          FROM @tbl_Physician_Aggr A INNER JOIN  tbl_GPRO_TIN_Selected_Measures P ON A.Exam_TIN=P.TIN 
                                                                                                         --AND A.Physician_NPI=P.NPI
																					AND  A.CMS_Submission_Year=P.Submission_year
																					AND A.Measure_Num=P.Measure_num
																					and P.Is_Active=1
																					AND P.Is_90Days=0
                                       WHERE A.SelectedForCMSSubmission IS NULL 
							        AND A.HundredPercentSubmit IS NULL
								   AND A.TotalCasesReviewed IS NULL


UPDATE A SET Init_Patient_Population= CASE WHEN  A.SelectedForCMSSubmission=1 AND A.TotalCasesReviewed>0 THEN TotalCasesReviewed
                                            WHEN  A.SelectedForCMSSubmission=1 AND A.HundredPercentSubmit=1 THEN A.TotalExamsCount
								    ELSE 0
                                           END
                                          FROM @tbl_Physician_Aggr A 
                                    

UPDATE A SET Reporting_Denominator= Init_Patient_Population-Denominator_Exclusions ,      -- CASE WHEN Init_Patient_Population>0 THEN  Init_Patient_Population-Denominator_Exclusions ELSE 0 END,--SET  @ReportingDenominatorCount = @initPatientPopulation - @DenominatorExclusionCount;
            Reporting_Numerator=Performance_Met+Denominator_Exceptions+Performance_Not_Met, --    SET @ReportingNumerator = @performanceNumerator + ISNULL(@DenominatorExceptionCount, 0)  + @performanceNotMetCount ;
		--  Exclusion=0,
		  Performance_denominator=Performance_Met+Performance_Not_Met, --   SET @performanceDenoCount = @performanceMetCount  + @performanceNotMetCount ;		
		  Performance_Numerator=Performance_Met --  SET @performanceNumerator = @performanceMetCount ;


								 
								  FROM @tbl_Physician_Aggr A 

-- Change#8	
UPDATE A SET Original_Reporting_Denominator= Init_Patient_Population-Denominator_Exclusions ,      -- CASE WHEN Init_Patient_Population>0 THEN  Init_Patient_Population-Denominator_Exclusions ELSE 0 END,--SET  @ReportingDenominatorCount = @initPatientPopulation - @DenominatorExclusionCount;
            Original_Reporting_Numerator=Performance_Met+Denominator_Exceptions+Performance_Not_Met --    SET @ReportingNumerator = @performanceNumerator + ISNULL(@DenominatorExceptionCount, 0)  + @performanceNotMetCount ;
		FROM @tbl_Physician_Aggr A 							  
	

UPDATE A SET  Reporting_Rate= CASE WHEN Reporting_Denominator>0 THEN ((CAST(Reporting_Numerator  as float)/Reporting_Denominator) *100) ELSE NULL END,
              Performance_rate=CASE WHEN Performance_denominator>0 THEN((CAST(Performance_Numerator AS float)/Performance_denominator)*100) ELSE 0 END
		  

                                          FROM @tbl_Physician_Aggr A 

-- Change#8	
UPDATE A SET  Original_Reporting_Rate= CASE WHEN Reporting_Denominator>0 THEN ((CAST(Original_Reporting_Numerator  as float)/Original_Reporting_Denominator) *100) ELSE NULL END		  

                                          FROM @tbl_Physician_Aggr A 
                                    	  

UPDATE A SET  Decile_Val= (select dbo.fnYearwiseDecileLogic(A.Measure_Num,A.Performance_rate,@intYear,A.Reporting_Rate,A.TotalExamsCount))

                                          FROM @tbl_Physician_Aggr A 
                                    	  
                                    

 print('Recalculate Performance: Performance Calculated For MIPS Measures Except (226,143) '+CONVERT( VARCHAR(24), GETDATE(), 113));	
-----------Performance Calculation For MIPS Measures Except ('226','143')   ------ENDs
	------------------Non MIPS Measures Starts---------------
	
	

INSERT INTO @tbl_Physician_Aggr
SELECT DISTINCT
  @intYear as [CMS_Submission_Year]
     , null as [CMS_Submission_Date]
     , t.Physician_NPI as [Physician_NPI]
     , t.Exam_TIN as [Exam_TIN]
     , t.Measure_num as [Measure_Num]
     , 1 as [Strata_num]
     , NULL as [SelectedForCMSSubmission]
     , NULL as [Init_Patient_Population]
     , 0 as [Reporting_Denominator]
     , t.Reporting_Numerator as [Reporting_Numerator]
     , 0 as [Exclusion]
     , t.Performance_denominator as [Performance_denominator]
     , t.Performance_Numerator as [Performance_Numerator] 
     , t.Denominator_Exceptions
       ,t.Denominator_Exclusions
        , t.Performance_Not_Met
     , t.Performance_Met
     , 0 as [Reporting_Rate]
     , t.Performance_rate as [Performance_rate]
     , GETDATE() as [Created_Date]
     , 0 as [Created_By]
     , GETDATE() as [Last_Mod_Date]
     , 0 as [Last_Mod_By]
     , t.Encounter_From_Date
      ,t.Encounter_To_Date
     , t.Benchmark_met as [Benchmark_met]
     , 0 as [GPRO]
    , t.Decile_val as [Decile_Val]
     , 0 as [Is_90Days]
     , t.Total_Num_Exam_Submitted
     , 0 as [Stratum_Id]	
	,NULL AS TotalCasesReviewed  
	, NULL AS HundredPercentSubmit 	
	,1
	,(ISNULL(t.Performance_denominator,0)-ISNULL(t.Denominator_Exclusions,0)) as observationInstances        --Change #1
		-- Change#8
	 , 0 as [Original_Reporting_Denominator]
     , t.Reporting_Numerator as [Original_Reporting_Numerator]
	  , 0 as [Original_Reporting_Rate]
from tbl_Non_PQRS_Aggregation_Year t INNER JOIN @PhysicianQCDRtins P on t.Physician_NPI=P.NPI

      and t.Exam_TIN=P.TIN
	 and t.CMS_Submission_Year=@intYear
	  --King 20191211
     and t.Is_90Days = 0
	 Inner JOIN tbl_Users U on U.NPI=P.NPI
	


UPDATE A SET SelectedForCMSSubmission=ISNULL(P.SelectedForSubmission,0),
             HundredPercentSubmit=ISNULL(P.HundredPercentSubmit,0),
		   TotalCasesReviewed=ISNULL(P.TotalCasesReviewed,0)  
                                          FROM @tbl_Physician_Aggr A INNER JOIN  tbl_Physician_Selected_Measures P ON
								                                                               
								                                                                  A.Exam_TIN=P.TIN 
                                                                                                         AND A.Physician_NPI=P.NPI
																					AND  A.CMS_Submission_Year=P.Submission_year
																					AND A.Measure_Num=P.Measure_num_ID
																					AND A.IsNotMIPSMeasure=1
																					and P.Is_Active=1
																					AND P.Is_90Days=0

UPDATE A SET SelectedForCMSSubmission=1,
             HundredPercentSubmit=1
		   --TotalCasesReviewed=ISNULL(P.TotalCasesReviewed,1)  
                                          FROM @tbl_Physician_Aggr A INNER JOIN  tbl_GPRO_TIN_Selected_Measures P ON A.Exam_TIN=P.TIN 
                                                                                                         --AND A.Physician_NPI=P.NPI
																					AND  A.CMS_Submission_Year=P.Submission_year
																					AND A.Measure_Num=P.Measure_num
																					AND A.IsNotMIPSMeasure=1
																					and P.Is_Active=1
																					AND P.Is_90Days=0
                                       WHERE A.SelectedForCMSSubmission IS NULL 
							        AND A.HundredPercentSubmit IS NULL
								   AND A.TotalCasesReviewed IS NULL


UPDATE A SET SelectedForCMSSubmission=1,
             HundredPercentSubmit=1
		   --TotalCasesReviewed=ISNULL(P.TotalCasesReviewed,1)  
                                          FROM @tbl_Physician_Aggr A INNER JOIN    tbl_lookup_Measure_Average av ON AV.Avg_MeasureName=A.Measure_num 
								                                            
														  join tbl_Lookup_Measure  M on 
													M.Measure_ID=av.Measure_Id 
													and M.CMSYear=@intYear 
													AND M.Is_AvgMeasure=1
													
                                       WHERE A.SelectedForCMSSubmission IS NULL 
							        AND A.HundredPercentSubmit IS NULL
								   AND A.TotalCasesReviewed IS NULL
								   AND A.IsNotMIPSMeasure=1





UPDATE A SET Init_Patient_Population= CASE WHEN  A.SelectedForCMSSubmission=1 AND A.TotalCasesReviewed>0 THEN TotalCasesReviewed
                                            WHEN  A.SelectedForCMSSubmission=1 AND A.HundredPercentSubmit=1 THEN A.TotalExamsCount
								    ELSE 0
                                           END
                                          FROM @tbl_Physician_Aggr A WHERE  A.IsNotMIPSMeasure=1
                                    

UPDATE A SET Reporting_Denominator= Init_Patient_Population       -- CASE WHEN Init_Patient_Population>0 THEN  Init_Patient_Population-Denominator_Exclusions ELSE 0 END,--SET  @ReportingDenominatorCount = @initPatientPopulation - @DenominatorExclusionCount;
            --Reporting_Numerator=Performance_Met+Denominator_Exceptions+Performance_Not_Met --    SET @ReportingNumerator = @performanceNumerator + ISNULL(@DenominatorExceptionCount, 0)  + @performanceNotMetCount ;
		
								 
								  FROM @tbl_Physician_Aggr A  WHERE  A.IsNotMIPSMeasure=1

-- Change#8
UPDATE A SET Original_Reporting_Denominator= Init_Patient_Population       -- CASE WHEN Init_Patient_Population>0 THEN  Init_Patient_Population-Denominator_Exclusions ELSE 0 END,--SET  @ReportingDenominatorCount = @initPatientPopulation - @DenominatorExclusionCount;
            --Reporting_Numerator=Performance_Met+Denominator_Exceptions+Performance_Not_Met --    SET @ReportingNumerator = @performanceNumerator + ISNULL(@DenominatorExceptionCount, 0)  + @performanceNotMetCount ;
		
								 
								  FROM @tbl_Physician_Aggr A  WHERE  A.IsNotMIPSMeasure=1

								  
	

UPDATE A SET  Reporting_Rate= CASE WHEN Reporting_Denominator>0 THEN ((CAST(Reporting_Numerator  as float)/Reporting_Denominator) *100) ELSE NULL END
             

                                          FROM @tbl_Physician_Aggr A  WHERE  A.IsNotMIPSMeasure=1

-- Change#8
UPDATE A SET  Original_Reporting_Rate= CASE WHEN Original_Reporting_Denominator>0 THEN ((CAST(Original_Reporting_Numerator  as float)/Original_Reporting_Denominator) *100) ELSE NULL END
             

                                          FROM @tbl_Physician_Aggr A  WHERE  A.IsNotMIPSMeasure=1
                                    	  
	 print('Recalculate Performance: Performance Calculated For Non MIPS Measures '+CONVERT( VARCHAR(24), GETDATE(), 113));	
	---------------------	Non MIPS Measures ENDs-------------------
	--- Insert the calculated values into tbl_Physician_Aggregation_Year ---------------Started

	INSERT INTO [dbo].[tbl_Physician_Aggregation_Year]
           ([CMS_Submission_Year]
           ,[CMS_Submission_Date]
           ,[Physician_NPI]
           ,[Exam_TIN]
           ,[Measure_Num]
           ,[Strata_num]
           ,[SelectedForCMSSubmission]
           ,[Init_Patient_Population]
           ,[Reporting_Denominator]
           ,[Reporting_Numerator]
           ,[Exclusion]
           ,[Performance_denominator]
           ,[Performance_Numerator]
           ,[Denominator_Exceptions]
           ,[Denominator_Exclusions]
           ,[Performance_Not_Met]
           ,[Performance_Met]
           ,[Reporting_Rate]
           ,[Performance_rate]
           ,[Created_Date]
           ,[Created_By]
           ,[Last_Mod_Date]
           ,[Last_Mod_By]
           ,[Encounter_From_Date]
           ,[Encounter_To_Date]
           ,[Benchmark_met]
           ,[GPRO]
           ,[Decile_Val]
           ,[Is_90Days]
           ,[TotalExamsCount]
           ,[Stratum_Id]
           ,[observationInstances])


		 SELECT CMS_Submission_Year
		 ,CMS_Submission_Date
		  ,[Physician_NPI]
           ,[Exam_TIN]
           ,M.CMS_Measure_Num
           ,[Strata_num]
           ,[SelectedForCMSSubmission]
           ,[Init_Patient_Population]
           ,[Reporting_Denominator]
           ,[Reporting_Numerator]
           ,[Exclusion]
           ,[Performance_denominator]
           ,[Performance_Numerator]
           ,[Denominator_Exceptions]
           ,[Denominator_Exclusions]
           ,[Performance_Not_Met]
           ,[Performance_Met]
           ,[Reporting_Rate]
           ,[Performance_rate]
           ,A.[Created_Date]
           ,A.[Created_By]
           ,A.[Last_Mod_Date]
           ,A.[Last_Mod_By]
           ,[Encounter_From_Date]
           ,[Encounter_To_Date]
           ,[Benchmark_met]
           ,[GPRO]
           ,[Decile_Val]
           ,[Is_90Days]
           ,[TotalExamsCount]
           ,[Stratum_Id]
		 ,observationInstances
		 
		  from 
		  @tbl_Physician_Aggr A 
		  INNER JOIN tbl_Lookup_Measure M ON M.Measure_num = A.Measure_Num AND M.CMSYear = @intYear

--Change#9 
	Exec [dbo].[SPCI_BulkUpload_FilesProcess] @intYear	
-- Change#8
	INSERT INTO [dbo].[tbl_ReportingRateGreaterThan100] 
	SELECT 
	Exam_TIN
	,Physician_NPI
	,Measure_Num
	,Original_Reporting_Denominator
	,Original_Reporting_Numerator
	,Original_Reporting_Rate
	,Reporting_Denominator
	,Reporting_Numerator
	,Reporting_Rate
	FROM @tbl_Physician_Aggr WHERE Original_Reporting_Rate > 100
    print('Recalculate Performance: Insert the calculated values into tbl_Physician_Aggregation_Year '+CONVERT( VARCHAR(24), GETDATE(), 113));	
   --- Insert the calculated values into tbl_Physician_Aggregation_Year ---------------ENDS

-----------Performance Calculation For MIPS Measures '226','46','143'   ------STARTS
	 
	 SET @strCurTIN='';

	 DECLARE @strCurNPI varchar(10);

	 DECLARE @intCurMeasureId int;
	 DECLARE @strMeasure_num varchar(50)
	 DECLARE @blnGPRO bit=null;

	 DECLARE CurStratumMes CURSOR FOR 
               
      SELECT P.NPI,P.TIN,E.Measure_ID, E.Measure_num FROM @PhysicinaTins P INNER JOIN  PRExamMeasure_VW E  ON 
                                                                           P.NPI=e.Physician_NPI
															And P.TIN=E.Exam_TIN
       
        WHERE e.CMS_Submission_Year = @intYear     
	      AND E.Measure_num IN ('226','143','409')  
                OPEN CurStratumMes

                FETCH NEXT FROM CurStratumMes INTO @strCurNPI,@strCurTIN,@intCurMeasureId,@strMeasure_num

                WHILE @@FETCH_STATUS = 0 
                BEGIN	
			 SELECT TOP 1 @blnGPRO=ISNULL(is_GPRO,0) from tbl_TIN_GPRO WHERE TIN=@strCurTIN-- Change #4
			
				IF(@strMeasure_num='226')-- Change #24 
				BEGIN
					print('measure 226 related stratum code executing')
					EXEC spReCalculate_Measure226ForPhy @strCurNPI,@strCurTIN,@intYear,@strMeasure_num,@blnGPRO
					
				END
				ELSE IF(@strMeasure_num='143')-- Change #27
				BEGIN
					print('measure 143 related stratum code executing')
					EXEC spReCalculate_Measure143ForPhy @strCurNPI,@strCurTIN,@intYear,@strMeasure_num,@blnGPRO
					
				END
				ELSE IF(@strMeasure_num='409')-- Change #27
				BEGIN
					print('measure 409 related  code executing')
					EXEC spReCalculate_Measure409ForPhy @intYear,@strCurNPI,@strCurTIN
					
				END
             FETCH NEXT FROM CurStratumMes INTO @strCurNPI,@strCurTIN,@intCurMeasureId,@strMeasure_num
                    END 
                CLOSE CurStratumMes ;
                DEALLOCATE CurStratumMes ;	

			   print('Recalculate Performance: Performance Calculated For MIPS Measures 226,143 '+CONVERT( VARCHAR(24), GETDATE(), 113));
	-----------Performance Calculation For MIPS Measures '226','143'   ------ENDS			
	

	           
        IF EXISTS ( SELECT  1
                    FROM    dbo.tbl_Scheduled_Jobs_Log_Data l
                    WHERE   l.LogForYear = @intYear
                            AND l.LogName = 'PerformanceRecalculate' ) 
            BEGIN
                UPDATE  dbo.tbl_Scheduled_Jobs_Log_Data
                SET     LogTime = GETDATE() ,
                        LogValue = 1
                WHERE   LogName = 'PerformanceRecalculate'

            END
        ELSE 
            BEGIN
                INSERT  INTO tbl_Scheduled_Jobs_Log_Data
                        ( LogName ,
                          LogForYear ,
                          LogValue ,
                          LogTime
                        )
                VALUES  ( 'PerformanceRecalculate' ,
                          @intYear ,
                          1 ,
                          GETDATE()
                        )
            END
                			
--Change#5: update gpro value
	update a
				set
				a.GPRO = G.is_GPRO
				from tbl_TIN_Aggregation_Year a inner join tbl_TIN_GPRO G on
				a.Exam_TIN = a.Exam_TIN 
				where a.CMS_Submission_Year=@intYear

	----------Change#6 :run the SP 'SPCI_Submission_Email_Remainder_nonGPRO'	
	IF( Exists (select 1 from tbl_Lookup_Active_Submission_Year where Submission_Year=@intYear and IsSubmittoCMS=1)
	   AND EXISTS(select 1 from tbl_Lookup_MIPS_Settings where Set_Key='ISEmail_ReminderSPRUN' and Value='1') )
	BEGIN
	EXEC SPCI_Submission_Email_Remainder_nonGPRO
	
	Print 'SPCI_Submission_Email_Remainder_GPRO executed'
	END	
			
    END



