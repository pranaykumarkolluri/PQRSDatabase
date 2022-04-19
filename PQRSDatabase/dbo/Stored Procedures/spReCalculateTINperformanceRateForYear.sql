-- =============================================
-- Author:		hari J
-- Create date: 27/05/2020
-- Description:	JIRA#806
-- Change #1 : uncommented the 143,226, sps and pass gpro value---Hari on Jan 4th 2021
--Change #2: call the SP 'SPCI_Submission_Email_Remainder_GPRO' internally -- hari on Feb 4th,2021
-- Change #3: JIRA#921  , hari on 18th, Feb,2021
-- Change#4: update GPRO column value in tbl_tin_aggregation_year --hari on 26th Feb,2021
-- Chnage#5:JIRA#955, hari on June 14th,2021
-- Change#6 : JIRA#973  , pranay on July 15,2021
--Change#7 : JIRA#1027 , pranay on AUG 02, 2021
--Change#8 : JIRA#1012 ,Sai on August 16th,2021 -- Adding BatchFileProcess
-- Change#9 : Sai on Nov 24, 2021
-- Change#10 : Sai on Nov 30, 2021
-- =============================================
CREATE PROCEDURE [dbo].[spReCalculateTINperformanceRateForYear]
	@intYear int = 0, 
	@strTIN varchar(11) = ''
AS
BEGIN
	

DECLARE @tbl_TIN_Aggr AS TABLE(
	[Aggregation_Id] [int] IDENTITY(1,1) NOT NULL,
	[CMS_Submission_Year] [int] NOT NULL,
	[CMS_Submission_Date] [datetime] NULL,
	[Exam_TIN] [varchar](10) NOT NULL,
	[Measure_Num] [varchar](50) NULL,
	[Strata_num] [int] NULL,
	[SelectedForCMSSubmission] [bit] NULL,
	[Init_Patient_Population] [int] NULL,
	[Reporting_Denominator] [int] NULL,
	[Reporting_Numerator] [int] NULL,
	[Exclusion] [int] NOT NULL,
	[Performance_denominator] [int] NOT NULL,
	[Performance_Numerator] [decimal](18, 2) NULL,
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
	[GPRO] [bit] NOT NULL,
	[Decile_Val] [varchar](50) NULL,
	[Is_90Days] [bit] NULL,
	[TotalExamsCount] [int] NULL,
	[Stratum_Id] [int] NULL,
	[totalPhysiansSubmittedCount] [int] NULL,
	[observationInstances] [int] NULL,
	IsNotMIPSMeasure BIT,
	PhyorFac int,
	HundredPercentSubmit BIT,
	TotalCasesReviewed INT NULL
	-- Change#6
	,[Original_Reporting_Denominator] [int] NULL
    ,[Original_Reporting_Numerator] [int] NULL
    ,[Original_Reporting_Rate] [decimal](18, 4) NULL
	)


	SET @strTIN=ISNULL(@strTIN,'');
	-------DELETE existing data------------
	Delete from tbl_TIN_Aggregation_Year where CMS_Submission_Year = @intYear
				   and Is_90Days=0 -- Change #15
				and Exam_TIN = CASE  @strTIN WHEN '' THEN Exam_tin ELSE @strTIN END

	-------DELETE existing data ends------------
	-----------------UPDATE TBL_TIN_GPRO Starts ---------------
	DECLARE @strCurTIN VARCHAR(9);
	 DECLARE CurTINS CURSOR FOR 
                select distinct Exam_tin from 
				PRExamMeasure_VW   where  CMS_Submission_Year = @intYear 
				and  Exam_tin = CASE  @strTIN WHEN '' THEN Exam_tin ELSE @strTIN END
				
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

	
-----------Performance Calculation For MIPS Measures Except ('226','143','46')   ------Starts

--Change#10 
------------------------------
declare @UserTINNPIs table(TIN varchar(9), NPI varchar(10));

insert into @UserTINNPIs
select distinct TIN, NPI from PHYSICIAN_TIN_VW where REGISTRY_NAME='MIPS'
---------------------------------
Declare @TINAggrData as Table(
TIN Varchar(9),Measure_ID int,Measure_num varchar (500),MeasuresCount int)


INSERT INTO @TINAggrData 

SELECT E.Exam_TIN, E.Measure_ID, E.Measure_num,SUM(E.MeasureCount) as MeasuresCount FROM
 PRExamMeasure_VW E INNER JOIN @UserTINNPIs V -- Change#10
						ON V.NPI COLLATE DATABASE_DEFAULT = E.Physician_NPI 
						AND V.TIN COLLATE DATABASE_DEFAULT=E.Exam_TIN
--Change#9						 and V.IS_ACTIVE=1 --#Change#5
--	Change#9					 and V.IS_ENROLLED = 1 
--Change#10						 and V.REGISTRY_NAME='MIPS' 
        WHERE e.CMS_Submission_Year = @intYear    
		and  Exam_tin = CASE  @strTIN WHEN '' THEN Exam_tin ELSE @strTIN END
	        AND E.Measure_num NOT IN ('226','143','46','409')  
			GROUP BY E.Exam_TIN, E.Measure_ID, E.Measure_num

INSERT INTO @tbl_TIN_Aggr

SELECT 

@intYear	as CMS_Submission_Year,
	null as CMS_Submission_Date,
	t.TIN as Exam_TIN,
	t.Measure_num as Measure_Num,
	1 as Strata_num,
	null as SelectedForCMSSubmission,
	null as Init_Patient_Population,
	0 as Reporting_Denominator,
	(select sum(isnull(Reporting_Numerator,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =T.TIN 
										and a.Measure_Num = T.Measure_num 
										and a.CMS_Submission_Year = @intYear
										 and a.Is_90Days=0) as Reporting_Numerator,
	1 as Exclusion,
	(select ISNULL(sum(isnull(a.Performance_denominator,0)),0) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =T.TIN 
										and a.Measure_Num = T.Measure_num 
										and a.CMS_Submission_Year = @intYear
										 and a.Is_90Days=0 ) as Performance_denominator,
	(select ISNULL(sum(isnull(a.Performance_Numerator,0)),0) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =T.TIN 
										and a.Measure_Num = T.Measure_num 
										and a.CMS_Submission_Year = @intYear
										 and a.Is_90Days=0) as Performance_Numerator,
	(select ISNULL(sum(isnull(Denominator_Exceptions,0)),0) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =t.TIN 
										and a.Measure_Num = T.Measure_num 
										and a.CMS_Submission_Year = @intYear
										 and a.Is_90Days=0) as [Denominator_Exceptions]
      ,(select ISNULL(sum(isnull(Denominator_Exclusions,0)),0) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =t.TIN 
										and a.Measure_Num = T.Measure_num 
										and a.CMS_Submission_Year = @intYear
										 and a.Is_90Days=0) as [Denominator_Exclusions]
      ,(select ISNULL(sum(isnull(Performance_Not_Met,0)),0) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =t.TIN 
										and a.Measure_Num = T.Measure_num 
										and a.CMS_Submission_Year = @intYear
										 and a.Is_90Days=0) as [Performance_Not_Met]
      ,(select  ISNULL(sum(isnull(Performance_Met,0)),0) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =t.TIN 
										and a.Measure_Num = T.Measure_num 
										and a.CMS_Submission_Year = @intYear
										 and a.Is_90Days=0) as [Performance_Met],
	0 as Reporting_Rate,
	0 as Performance_rate,
	getdate() as Created_Date,
	0 as Created_By,
	getdate() as Last_Mod_Date,
	null as Last_Mod_By,
	      (                              SELECT  MIN(Encounter_From_Date)
										from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =t.TIN 
										and a.Measure_Num = T.Measure_num 
										and a.CMS_Submission_Year = @intYear
										 and a.Is_90Days=0 -- Change #15
) as [Encounter_From_Date]
      ,(          SELECT  MAX(Encounter_To_Date)
										from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =t.TIN 
										and a.Measure_Num = T.Measure_num 
										and a.CMS_Submission_Year = @intYear
										 and a.Is_90Days=0 ) as [Encounter_To_Date],
	null as Benchmark_met,
	1 as GPRO,
	null as Decile_Val,
	0 as Is_90Days,
	t.MeasuresCount as TotalExamsCount,
	0 as Stratum_Id,
	( SELECT count( distinct E.Physician_NPI)  FROM PRExamMeasure_VW E 
	INNER JOIN @UserTINNPIs V --Change#10
						ON V.NPI COLLATE DATABASE_DEFAULT = E.Physician_NPI 
						AND V.TIN COLLATE DATABASE_DEFAULT=E.Exam_TIN
						 --Change#9  and V.IS_ACTIVE=1 --#Change#5
						 --Change#9  and V.IS_ENROLLED = 1 
						--  and V.REGISTRY_NAME='MIPS' --Change#10
        WHERE e.CMS_Submission_Year = @intYear     
	        AND e.Exam_TIN=t.TIN
		   AND E.Measure_num=t.Measure_num)as totalPhysiansSubmittedCount,
	0 as observationInstances,
	0 as IsNotMIPSMeasure,
	 CASE WHEN EXISTS(SELECT  1
                                            FROM    dbo.tbl_Physician_Selected_Measures
                                            WHERE  
													TIN = t.TIN
                                                    AND Submission_year = @intYear
                                                    AND Measure_num_ID = t.Measure_num 
										    and Is_Active=1 
										    and Is_90Days=0 
											) then 1---records exists in physician

             WHEN EXISTS( SELECT  1
                                            FROM    dbo.tbl_GPRO_TIN_Selected_Measures
                                            WHERE  	TIN = t.TIN
                                                    AND Submission_year = @intYear
                                                    AND Measure_num = T.Measure_num 
										    and Is_Active=1 
										    and Is_90Days=0)  
											THEN 2-- record exists in facility
											ELSE 3 -- record exists neighter facility nor physician
											END as PhyorFac ,
	null as HundredPercentSubmit ,
	null as TotalCasesReviewed
	-- Change#6
	,0 as Original_Reporting_Denominator
	,(select sum(isnull(Reporting_Numerator,0)) from  dbo.tbl_Physician_Aggregation_Year a 
										where a.Exam_TIN =T.TIN 
										and a.Measure_Num = T.Measure_num 
										and a.CMS_Submission_Year = @intYear
										 and a.Is_90Days=0) as Original_Reporting_Numerator
	,0 as Original_Reporting_Rate
      
  FROM @TINAggrData t -- where t.Measure_num !='46'

  --------MEASURE 46---
  --------MEASURE 46 ENDS------

  ------if data exists in PHYSICIAN
UPDATE A SET SelectedForCMSSubmission=ISNULL(P.SelectedForSubmission,0),
             HundredPercentSubmit=ISNULL(P.HundredPercentSubmit,0),
		   TotalCasesReviewed=  ISNULL(P.TotalCasesReviewed,0)  
                                          FROM @tbl_TIN_Aggr A INNER JOIN  tbl_GPRO_TIN_Selected_Measures P ON  A.Exam_TIN=P.TIN                                                                                                      
																					AND  A.CMS_Submission_Year=P.Submission_year
																					AND A.Measure_Num=P.Measure_num
																					and P.Is_Active=1
																					AND P.Is_90Days=0



    UPDATE A SET SelectedForCMSSubmission=0

                                          FROM @tbl_TIN_Aggr A  WHERE A.SelectedForCMSSubmission is null


;WITH PHYTOTALCASES AS(
  select SUM(isnull (case S.HundredPercentSubmit
										when 1 then (
											a.MeasureCount
										 )
										else s.TotalCasesReviewed end,000) ) AS TotalCasesReviewed,
										A.Exam_TIN,
										A.Measure_Num,
										A.CMS_Submission_Year
										from PRExamMeasure_VW A
										INNER JOIN @UserTINNPIs V --Change#10
						ON V.NPI COLLATE DATABASE_DEFAULT = A.Physician_NPI 
						AND V.TIN COLLATE DATABASE_DEFAULT=A.Exam_TIN
						--Change#9 and V.IS_ACTIVE=1 --#Change#5 
						--Change#9  and V.IS_ENROLLED = 1 
						--  and V.REGISTRY_NAME='MIPS' --Change#10
						 INNER JOIN   tbl_Physician_Selected_Measures S ON  
										S.Measure_num_ID = a.Measure_Num 
										AND S.NPI=A.Physician_NPI
										and s.Submission_year =A.CMS_Submission_Year 
										AND A.CMS_Submission_Year= @intYear
										and S.TIN = A.Exam_TIN
										 and S.Is_Active=1
										   and S.Is_90Days=0
										   
										  GROUP BY 
										  A.Exam_TIN,
										A.Measure_Num,
										A.CMS_Submission_Year
										   )


  UPDATE A SET Init_Patient_Population=C.TotalCasesReviewed

                                          FROM @tbl_TIN_Aggr A INNER JOIN PHYTOTALCASES C ON A.Exam_TIN=C.Exam_TIN
										  AND A.CMS_Submission_Year=C.CMS_Submission_Year
										  AND A.Measure_Num=C.Measure_Num
										  WHERE A.PhyorFac=1



  UPDATE A SET Init_Patient_Population=CASE WHEN A.PhyorFac=3 THEN A.TotalExamsCount
                                            WHEN  A.HundredPercentSubmit=0 THEN ISNULL(A.TotalCasesReviewed,0)                                            
                                            WHEN  A.HundredPercentSubmit=1 THEN ISNULL(A.TotalExamsCount,0)								    
                                            ELSE 0 
                                           END

                                          FROM @tbl_TIN_Aggr A  WHERE A.Init_Patient_Population is null

UPDATE A SET Reporting_Denominator= Init_Patient_Population-Denominator_Exclusions    -- CASE WHEN Init_Patient_Population>0 THEN  Init_Patient_Population-Denominator_Exclusions ELSE 0 END,--SET  @ReportingDenominatorCount = @initPatientPopulation - @DenominatorExclusionCount;
         				 
								  FROM @tbl_TIN_Aggr A

-- Change#6
UPDATE A SET Original_Reporting_Denominator= Init_Patient_Population-Denominator_Exclusions    -- CASE WHEN Init_Patient_Population>0 THEN  Init_Patient_Population-Denominator_Exclusions ELSE 0 END,--SET  @ReportingDenominatorCount = @initPatientPopulation - @DenominatorExclusionCount;
         				 
								  FROM @tbl_TIN_Aggr A


	UPDATE A SET  Reporting_Denominator= CASE WHEN Reporting_Numerator>Reporting_Denominator THEN Reporting_Numerator ELSE Reporting_Denominator END
                                          FROM @tbl_TIN_Aggr A 						  
	

UPDATE A SET  Reporting_Rate= CASE WHEN Reporting_Denominator>0 THEN ((CAST(Reporting_Numerator  as float)/Reporting_Denominator) *100) ELSE NULL END,
              Performance_rate=CASE WHEN Performance_denominator>0 THEN((CAST(Performance_Numerator AS float)/Performance_denominator)*100) ELSE 0 END
		  

                                          FROM @tbl_TIN_Aggr A 

-- Change#6									  
UPDATE A SET  Original_Reporting_Rate= CASE WHEN Original_Reporting_Denominator>0 THEN ((CAST(Original_Reporting_Numerator  as float)/Original_Reporting_Denominator) *100) ELSE NULL END
                                          FROM @tbl_TIN_Aggr A 
                                    	  

UPDATE A SET  Decile_Val= (select dbo.fnYearwiseDecileLogic(A.Measure_Num,A.Performance_rate,@intYear,A.Reporting_Rate,A.TotalExamsCount))

                                          FROM @tbl_TIN_Aggr A 


 ------if data exists in FACILITY
  ------if data exists in NOT IN PHYSICIAN SELECTED OR  FACILITY SELECTED
  --===================non mips measures
  INSERT INTO @tbl_TIN_Aggr

SELECT 

@intYear	as CMS_Submission_Year,
	null as CMS_Submission_Date,
	t.Exam_TIN as Exam_TIN,
	t.Measure_num as Measure_Num,
    t.Strata_num	as Strata_num,
	null as SelectedForCMSSubmission,
	null as Init_Patient_Population,
	0 as Reporting_Denominator,
    t.Reporting_Numerator,
	0 as Exclusion,
	t.Performance_denominator,
	t.Performance_Numerator,
	t.Denominator_Exceptions,
    t.Denominator_Exclusions,
    t.Performance_Not_Met,
    t.Performance_Met,
	0 as Reporting_Rate,
	t.Performance_rate as Performance_rate,
	getdate() as Created_Date,
	0 as Created_By,
	getdate() as Last_Mod_Date,
	null as Last_Mod_By,
	t.Encounter_From_Date,
   t.Encounter_To_Date,
	t.Benchmark_met as Benchmark_met,
	1 as GPRO,
	t.Decile_val as Decile_Val,
	0 as Is_90Days,
	t.Total_Num_Exam_Submitted as TotalExamsCount,
	0 as Stratum_Id,
	--( SELECT count( distinct E.Physician_NPI)  FROM tbl_Non_PQRS_Aggregation_Year E  
 --       WHERE e.CMS_Submission_Year = @intYear     
	--        AND e.Exam_TIN=t.Exam_TIN)as totalPhysiansSubmittedCount,
	0 as totalPhysiansSubmittedCount,
	((ISNULL(t.Performance_denominator,0)-ISNULL(t.Denominator_Exclusions,0))) as observationInstances,
	1 as IsNotMIPSMeasure,
	 CASE WHEN EXISTS( select 1 from tbl_Lookup_Measure lm join tbl_lookup_Measure_Average av on 
													lm.Measure_ID=av.Measure_Id 
													and lm.CMSYear=@intYear 
													and av.Avg_MeasureName=t.Measure_Num
											) then 1 ---average measures

             WHEN EXISTS( SELECT  1
                                            FROM    dbo.tbl_GPRO_TIN_Selected_Measures
                                            WHERE  	TIN = t.Exam_TIN
                                                    AND Submission_year = @intYear
                                                    AND Measure_num = T.Measure_num 
										    and Is_Active=1 
										    and Is_90Days=0)  
											THEN 2
											ELSE 3 END as PhyorFac ,
	null as HundredPercentSubmit ,
	null as TotalCasesReviewed 
	-- Change#6
	,0 as Original_Reporting_Denominator
	,t.Reporting_Numerator as Original_Reporting_Numerator
	,0 as Original_Reporting_Rate
      
  FROM tbl_Non_PQRS_TIN_Aggregation_Year t where CMS_Submission_Year=@intYear and 
  (t.Is_90Days=0 or t.Is_90Days is null)
  -------------------
  UPDATE A SET SelectedForCMSSubmission= CASE WHEN A.PhyorFac=2 then (SELECT s.SelectedForSubmission 
                                            FROM    dbo.tbl_GPRO_TIN_Selected_Measures s
                                            WHERE  	s.TIN = A.Exam_TIN
                                                    AND s.Submission_year = @intYear
                                                    AND s.Measure_num = A.Measure_num 
										    and s.Is_Active=1 
										    and s.Is_90Days=0)
                                              WHEN A.PhyorFac=1 then 1
											  ELSE 0 END,
             HundredPercentSubmit=CASE WHEN A.PhyorFac=2 then (SELECT s.HundredPercentSubmit 
                                            FROM    dbo.tbl_GPRO_TIN_Selected_Measures s
                                            WHERE  	s.TIN = A.Exam_TIN
                                                    AND s.Submission_year = @intYear
                                                    AND s.Measure_num = A.Measure_num 
										    and s.Is_Active=1 
										    and s.Is_90Days=0)
                                              WHEN A.PhyorFac=1 then 1
											  ELSE 0 END,
		   TotalCasesReviewed=  CASE WHEN A.PhyorFac=2 then (SELECT s.TotalCasesReviewed 
                                            FROM    dbo.tbl_GPRO_TIN_Selected_Measures s
                                            WHERE  	s.TIN = A.Exam_TIN
                                                    AND s.Submission_year = @intYear
                                                    AND s.Measure_num = A.Measure_num 
										    and s.Is_Active=1 
										    and s.Is_90Days=0)
                                              WHEN A.PhyorFac=1 then a.TotalExamsCount
											  ELSE 0 END 
                                          FROM @tbl_TIN_Aggr A where a.IsNotMIPSMeasure=1


										  
UPDATE A SET Init_Patient_Population= CASE WHEN  A.SelectedForCMSSubmission=1 AND A.TotalCasesReviewed>0 THEN TotalCasesReviewed
                                            WHEN  A.SelectedForCMSSubmission=1 AND A.HundredPercentSubmit=1 THEN A.TotalExamsCount
								    ELSE 0
                                           END
                                          FROM @tbl_TIN_Aggr A WHERE  A.IsNotMIPSMeasure=1
UPDATE A SET Reporting_Denominator= Init_Patient_Population       -- CASE WHEN Init_Patient_Population>0 THEN  Init_Patient_Population-Denominator_Exclusions ELSE 0 END,--SET  @ReportingDenominatorCount = @initPatientPopulation - @DenominatorExclusionCount;
            --Reporting_Numerator=Performance_Met+Denominator_Exceptions+Performance_Not_Met --    SET @ReportingNumerator = @performanceNumerator + ISNULL(@DenominatorExceptionCount, 0)  + @performanceNotMetCount ;
		
								 
								  FROM @tbl_TIN_Aggr A  WHERE  A.IsNotMIPSMeasure=1

-- Change#6
UPDATE A SET Original_Reporting_Denominator= Init_Patient_Population       -- CASE WHEN Init_Patient_Population>0 THEN  Init_Patient_Population-Denominator_Exclusions ELSE 0 END,--SET  @ReportingDenominatorCount = @initPatientPopulation - @DenominatorExclusionCount;
            --Reporting_Numerator=Performance_Met+Denominator_Exceptions+Performance_Not_Met --    SET @ReportingNumerator = @performanceNumerator + ISNULL(@DenominatorExceptionCount, 0)  + @performanceNotMetCount ;
		
								 
								  FROM @tbl_TIN_Aggr A  WHERE  A.IsNotMIPSMeasure=1

								  
	

UPDATE A SET  Reporting_Rate= CASE WHEN Reporting_Denominator>0 THEN ((CAST(Reporting_Numerator  as float)/Reporting_Denominator) *100) ELSE NULL END
             

                                          FROM @tbl_TIN_Aggr A  WHERE  A.IsNotMIPSMeasure=1

-- Change#6
UPDATE A SET  Original_Reporting_Rate= CASE WHEN Original_Reporting_Denominator>0 THEN ((CAST(Original_Reporting_Numerator  as float)/Original_Reporting_Denominator) *100) ELSE NULL END
             

                                          FROM @tbl_TIN_Aggr A  WHERE  A.IsNotMIPSMeasure=1
                                    	  
	 print('Recalculate Performance: Performance Calculated For Non MIPS Measures '+CONVERT( VARCHAR(24), GETDATE(), 113));	
	---------------------	Non MIPS Measures ENDs-------------------

	--- Insert the calculated values into [tbl_TIN_Aggregation_Year] ---------------Started

	INSERT INTO [dbo].[tbl_TIN_Aggregation_Year]
           ([CMS_Submission_Year]
           ,[CMS_Submission_Date]
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
           ,[totalPhysiansSubmittedCount]
           ,[observationInstances])
		   select t.CMS_Submission_Year
		   ,t.CMS_Submission_Date
		   ,t.Exam_TIN
		   ,t.Measure_Num
		   ,t.Strata_num
		   ,t.SelectedForCMSSubmission
		   ,t.Init_Patient_Population
		   ,t.Reporting_Denominator
		   ,t.Reporting_Numerator
		   ,t.Exclusion
		   ,t.Performance_denominator
		   ,t.Performance_Numerator
		   ,t.Denominator_Exceptions
		   ,t.Denominator_Exclusions,
		   t.Performance_Not_Met
		   ,t.Performance_Met
		   ,t.Reporting_Rate
		   ,t.Performance_rate
		   ,t.Created_Date
		   ,t.Created_By
		   ,t.Last_Mod_Date
		   ,t.Last_Mod_By
		   ,t.Encounter_From_Date
		   ,t.Encounter_To_Date
		   ,t.Benchmark_met
		   ,t.GPRO
		   ,t.Decile_Val
		   ,t.Is_90Days
		   ,t.TotalExamsCount
		   ,t.Stratum_Id
		   ,t.totalPhysiansSubmittedCount
		   ,t.observationInstances

		   from  @tbl_TIN_Aggr T
		   Inner Join tbl_Lookup_Measure M on M.Measure_num = T.Measure_Num AND M.CMSYear = @intYear
	--- Insert the calculated values into [tbl_TIN_Aggregation_Year] ---------------Ended

--Change#8
Exec [dbo].[SPCI_BulkUpload_FilesProcess] @intYear	

-- Change#6
	INSERT INTO [dbo].[tbl_ReportingRateGreaterThan100] 
	SELECT 
	Exam_TIN
	,'--'
	,Measure_Num
	,Original_Reporting_Denominator
	,Original_Reporting_Numerator
	,Original_Reporting_Rate
	,Reporting_Denominator
	,Reporting_Numerator
	,Reporting_Rate
	FROM @tbl_TIN_Aggr WHERE Original_Reporting_Rate > 100
	
-----------Performance Calculation For MIPS Measures '226','46','143'   ------STARTS
	 
	 SET @strCurTIN='';

	 DECLARE @strCurNPI varchar(10);

	 DECLARE @intCurMeasureId int;
	 DECLARE @strMeasure_num varchar(50)
	 DECLARE @blnGPRO bit=null;

	 DECLARE CurStratumMes CURSOR FOR 
               
      SELECT e.Exam_TIN,E.Measure_ID, E.Measure_num FROM PRExamMeasure_VW E 
        WHERE e.CMS_Submission_Year = @intYear     
	      AND E.Measure_num IN ('226','143','46','409')  
                OPEN CurStratumMes

                FETCH NEXT FROM CurStratumMes INTO @strCurTIN,@intCurMeasureId,@strMeasure_num

                WHILE @@FETCH_STATUS = 0 
                BEGIN	
			 SELECT TOP 1 @blnGPRO=ISNULL(is_GPRO,0) from tbl_TIN_GPRO WHERE TIN=@strCurTIN-- Change #1
		
				IF(@strMeasure_num='46')-- Change #21 
				BEGIN
				print('measure 46 related stratum code executing')
               	EXEC spReCalculate_StratumCalbyAgeforTIN @intYear,@strCurTIN,@intCurMeasureId,@strMeasure_num,@blnGPRO
				END

				ELSE IF(@strMeasure_num='226')-- Change #24 
				BEGIN
				print('measure 226 related stratum code executing')
			     EXEC spReCalculate_Measure226ForTin @strCurTIN,@intYear,@strMeasure_num,@blnGPRO
				END
				ELSE IF(@strMeasure_num='143')-- Change #27
				BEGIN
					print('measure 143 related stratum code executing')
				EXEC spReCalculate_Measure143ForTin @strCurTIN,@intYear,@strMeasure_num,@blnGPRO
				END
				ELSE IF(@strMeasure_num='409')-- Change #27
				BEGIN
					print('measure 409 related  code executing')
					EXEC spReCalculate_Measure409ForTin @intYear,@strCurTIN
					
				END
             FETCH NEXT FROM CurStratumMes INTO @strCurTIN,@intCurMeasureId,@strMeasure_num
                    END 
                CLOSE CurStratumMes ;
                DEALLOCATE CurStratumMes ;	

			   print('Recalculate Performance: Performance Calculated For MIPS Measures 226,143 '+CONVERT( VARCHAR(24), GETDATE(), 113));
	-----------Performance Calculation For MIPS Measures '226','143'   ------ENDS			
	
  --------------
  	update a
				set
				a.SelectedForCMSSubmission = 1
				from tbl_TIN_Aggregation_Year a inner join tbl_GPRO_TIN_Selected_Measures G on
				G.Submission_year = a.CMS_Submission_Year and G.Measure_num = a.Measure_Num
				and G.TIN = a.Exam_TIN
				where G.SelectedForSubmission = 1
				and a.CMS_Submission_Year = @intYear
				  and a.Is_90Days=0 
				  and G.Is_Active=1 
	--Change#4: update gpro value
	update a
				set
				a.GPRO = G.is_GPRO
				from tbl_TIN_Aggregation_Year a inner join tbl_TIN_GPRO G on
				a.Exam_TIN = a.Exam_TIN 
				where a.CMS_Submission_Year=@intYear
				
	----------Change#2 :run the SP 'SPCI_Submission_Email_Remainder_GPRO'	
	IF( Exists (select 1 from tbl_Lookup_Active_Submission_Year where Submission_Year=@intYear and IsSubmittoCMS=1)
	   AND EXISTS(select 1 from tbl_Lookup_MIPS_Settings where Set_Key='ISEmail_ReminderSPRUN' and Value='1') )
	BEGIN
	EXEC SPCI_Submission_Email_Remainder_GPRO
	
	Print 'SPCI_Submission_Email_Remainder_GPRO executed'
	END		 
END

