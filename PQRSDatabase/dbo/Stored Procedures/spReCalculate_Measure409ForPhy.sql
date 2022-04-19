



-- =============================================
-- Author:		Pavan A
-- Create date: 15/02/2022
-- description : Performance Calculation For #409 measure
-- =============================================
CREATE PROCEDURE [dbo].[spReCalculate_Measure409ForPhy]
    @intYear INT = 0 ,
    @strPhysicianNPI VARCHAR(50) = '',
	@strTIN VARCHAR(50) = ''
AS 
    BEGIN
	SET @strTIN=ISNULL(@strTIN,'');
	SET @strPhysicianNPI=ISNULL(@strPhysicianNPI,'');

	DELETE FROM [dbo].[tbl_Physician_Aggregation_Year] where CMS_Submission_Year = @intYear
						  and Is_90Days=0  
						  AND Physician_NPI= @strPhysicianNPI
					      AND Exam_TIN= @strTIN
						  AND Measure_Num = '409'

	DELETE FROM [dbo].[tbl_ReportingRateGreaterThan100] where   
   					   Physician_NPI=  @strPhysicianNPI 
					      AND Exam_TIN= @strTIN 
						  AND Measure_Num = '409'

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
	[Original_Reporting_Denominator] [int] NULL,
    [Original_Reporting_Numerator] [int] NULL,
    [Original_Reporting_Rate] [decimal](18, 4) NULL,
	[Criteria][varchar](50) NULL
	)


	Declare @Total_Population_Count_Criteria_One int

	select @Total_Population_Count_Criteria_One=count(distinct E.Exam_Unique_ID) from tbl_Exam E join tbl_Exam_Measure_Data D on d.Exam_Id = E.Exam_Id where Exam_TIN = @strTIN and Physician_NPI = @strPhysicianNPI and Measure_ID = '727'

	Declare @PRExamNumerator_VWForMes_409 as Table(
	CMS_Submission_Year int, Physician_NPI varchar(50),Exam_TIN varchar(50),Exam_Date datetime, Patient_Age decimal(18,2),Exam_Unique_Id varchar(100), Measure_Id int,Denominator_Exceptions varchar(1),Exclusion varchar(1),Performance_met varchar(2),Criteria varchar(50))

    
	INSERT INTO @PRExamNumerator_VWForMes_409
	SELECT  distinct  e.CMS_Submission_Year,e.Physician_NPI,e.Exam_TIN,e.Exam_Date,e.Patient_Age, e.Exam_Unique_ID, md.Measure_ID,N.Denominator_Exceptions,N.Exclusion,N.Performance_met,
	(CASE WHEN N.Numerator_Code IN ('G0045','G0046') THEN 'CRITERIA1'
			WHEN n.Numerator_Code IN ('G9646','G9647','G9648') THEN 'CRITERIA2'
			ELSE 'NA' END) As Criteria
									FROM    dbo.tbl_Exam e 
											INNER JOIN dbo.tbl_Exam_Measure_Data md ON md.Exam_Id = e.Exam_Id
											INNER JOIN dbo.tbl_lookup_Numerator_Code N ON N.Measure_ID = md.Measure_ID and N.Numerator_response_Value=md.Numerator_response_value and isnull(n.Criteria,'NA') = case when md.Criteria is null or md.Criteria ='' then 'NA' else md.Criteria end
											INNER JOIN tbl_Lookup_Measure L on L.Measure_num = N.Measure_Num
									WHERE   md.[Status] IN ( 2, 3 ) and  E.Exam_TIN = @strTIN and Physician_NPI = @strPhysicianNPI and md.CMS_Submission_Year = @intyear and N.Measure_Num = '409'


---------Criteria 1 calculation start----------

		INSERT INTO @tbl_Physician_Aggr
VALUES(
  @intYear --as [CMS_Submission_Year]
     , null --as [CMS_Submission_Date]
     , @strPhysicianNPI --as [Physician_NPI]
     , @strTIN --as [Exam_TIN]
     , '409' --as [Measure_Num]
     , 1 --as [Strata_num]
     , NULL --as [SelectedForCMSSubmission]
     , NULL --as [Init_Patient_Population]
     , 0 --as [Reporting_Denominator]
     , 0 --as [Reporting_Numerator]
     , 0 --as [Exclusion]
     , 0 --as [Performance_denominator]
     , 0 --as [Performance_Numerator]
     , (  SELECT COUNT(E.Measure_ID)
                                FROM    @PRExamNumerator_VWForMes_409 E 
                                 WHERE  E.Criteria = 'CRITERIA1'                                 
                                        AND E.Denominator_Exceptions IN ( 'Y', 'y' )
                                     ) --as [Denominator_Exceptions]
       , (  SELECT COUNT(E.Measure_ID)
                                FROM     @PRExamNumerator_VWForMes_409 E 
                                 WHERE  E.Criteria = 'CRITERIA1'            
                                        AND E.Exclusion IN ( 'Y', 'y' )
                                       )--as [Denominator_Exclusions]
        , (  SELECT COUNT(E.Measure_ID)
                                FROM    @PRExamNumerator_VWForMes_409 E 
                                 WHERE   E.Criteria = 'CRITERIA1'             
                                        AND E.Performance_met IN ( 'N', 'n' )
                                        ) --as [Performance_Not_Met]
     , (  SELECT COUNT(E.Measure_ID)
                                FROM    @PRExamNumerator_VWForMes_409 E 
                                 WHERE   E.Criteria = 'CRITERIA1'           
                                        AND E.Performance_met IN ( 'Y', 'y' )
                                               )-- as [Performance_Met]
     , 0 --as [Reporting_Rate]
     , 0 --as [Performance_rate]
     , GETDATE() --as [Created_Date]
     , 0 --as [Created_By]
     , GETDATE() --as [Last_Mod_Date]
     , 0 --as [Last_Mod_By]
     , (  SELECT      MIN(Exam_Date)
                                FROM    @PRExamNumerator_VWForMes_409 E 
                                 WHERE   E.Criteria = 'CRITERIA1'       
                                                  ) --as [Encounter_From_Date]
      , (  SELECT      MAX(Exam_Date)
                                FROM    @PRExamNumerator_VWForMes_409 E 
                                 WHERE   E.Criteria = 'CRITERIA1'        
								 ) --as [Encounter_To_Date]
     , null --as [Benchmark_met]
     , 0 --as [GPRO]
    , null --as [Decile_Val]
     , 0 --as [Is_90Days]
     , @Total_Population_Count_Criteria_One
     , 0 --as [Stratum_Id]	
	,NULL --AS initPatientPopulation  
	, NULL --AS HundredPercentSubmit 	
	,0
	,0 --as observationInstances
	 , 0 --as [Original_Reporting_Denominator]
     , 0 --as [Original_Reporting_Numerator]
	  , 0 --as [Original_Reporting_Rate]
	  ,'CRITERIA1')
	  
		 UPDATE A SET SelectedForCMSSubmission=ISNULL(P.SelectedForSubmission,0),
					 HundredPercentSubmit=ISNULL(P.HundredPercentSubmit,0),
					 TotalCasesReviewed=ISNULL(P.TotalCasesReviewed,0)  
				    FROM @tbl_Physician_Aggr A INNER JOIN  tbl_Physician_Selected_Measures P ON  A.Exam_TIN=P.TIN 
                                                                             AND  A.Physician_NPI=P.NPI
														AND  A.CMS_Submission_Year=P.Submission_year
														AND A.Measure_Num=P.Measure_num_ID
														and P.Is_Active=1
														AND P.Is_90Days=0
		UPDATE A SET SelectedForCMSSubmission=1,
						HundredPercentSubmit=1
		        FROM @tbl_Physician_Aggr A INNER JOIN  tbl_GPRO_TIN_Selected_Measures P ON A.Exam_TIN=P.TIN 
    													AND  A.CMS_Submission_Year=P.Submission_year
														AND A.Measure_Num=P.Measure_num
														and P.Is_Active=1
														AND P.Is_90Days=0
            WHERE A.SelectedForCMSSubmission IS NULL 
				AND A.HundredPercentSubmit IS NULL
				AND A.TotalCasesReviewed IS NULL


		UPDATE A SET Init_Patient_Population= CASE WHEN  A.SelectedForCMSSubmission=1 AND A.TotalCasesReviewed>0 AND A.Criteria = 'CRITERIA1' THEN TotalCasesReviewed
												WHEN  A.SelectedForCMSSubmission=1 AND A.HundredPercentSubmit=1 AND A.Criteria = 'CRITERIA1'THEN A.TotalExamsCount
										ELSE 0 END FROM @tbl_Physician_Aggr A 
                                    

		UPDATE A SET Reporting_Denominator= Init_Patient_Population-Denominator_Exclusions ,
					Reporting_Numerator=Performance_Met+Performance_Not_Met,
					Performance_denominator=Performance_Met+Performance_Not_Met, 		
					 Performance_Numerator=Performance_Met FROM @tbl_Physician_Aggr A 


		UPDATE A SET Original_Reporting_Denominator= Init_Patient_Population-Denominator_Exclusions ,      
					Original_Reporting_Numerator=Performance_Met+Performance_Not_Met 
				FROM @tbl_Physician_Aggr A 							  
	

		UPDATE A SET  Reporting_Rate= CASE WHEN Reporting_Denominator>0 THEN ((CAST(Reporting_Numerator  as float)/Reporting_Denominator) *100) ELSE NULL END,
					  Performance_rate=CASE WHEN Performance_denominator>0 THEN((CAST(Performance_Numerator AS float)/Performance_denominator)*100) ELSE 0 END
				  FROM @tbl_Physician_Aggr A 

		UPDATE A SET  Original_Reporting_Rate= CASE WHEN Reporting_Denominator>0 THEN ((CAST(Original_Reporting_Numerator  as float)/Original_Reporting_Denominator) *100) ELSE NULL END		  
				 FROM @tbl_Physician_Aggr A 
                                    	  

		UPDATE A SET  Decile_Val= (select dbo.fnYearwiseDecileLogic(A.Measure_Num,A.Performance_rate,@intYear,A.Reporting_Rate,A.TotalExamsCount))
				FROM @tbl_Physician_Aggr A 
	
	Declare @Perf_Rate decimal(18,2)
	
	select @Perf_Rate = Performance_rate from @tbl_Physician_Aggr 
	
	IF(@Perf_Rate < 90)
	BEGIN
			print('Aggregation ended 90% criteria not met')
	END
	ELSE
		BEGIN
			Update @tbl_Physician_Aggr set Init_Patient_Population = Performance_Met 

			Declare @Total_Population_Count_Criteria_Two int

			select @Total_Population_Count_Criteria_Two = Performance_Met from @tbl_Physician_Aggr

			Declare @UniqueExamIDs as TABLE(UniqueExamID varchar(100) )

			insert into @UniqueExamIDs
			select distinct E.Exam_Unique_ID from tbl_Exam E 
					join tbl_Exam_Measure_Data D on d.Exam_Id = E.Exam_Id 
					where Exam_TIN = @strTIN and Physician_NPI = @strPhysicianNPI and E.CMS_Submission_Year = @intYear  and Numerator_Code = 'G0045'


			---- Criteria 2 Aggregation Starts ---
			UPDATE A SET Init_Patient_Population= CASE WHEN  A.SelectedForCMSSubmission=1 AND A.TotalCasesReviewed>0 AND A.Criteria = 'CRITERIA2' THEN TotalCasesReviewed
										WHEN  A.SelectedForCMSSubmission=1 AND A.HundredPercentSubmit=1 AND A.Criteria = 'CRITERIA2'THEN A.TotalExamsCount
								ELSE Init_Patient_Population END FROM @tbl_Physician_Aggr A 
                                    

			update @tbl_Physician_Aggr SET Denominator_Exceptions = (  SELECT COUNT(E.Measure_ID)
                                FROM    @PRExamNumerator_VWForMes_409 E 
									join @UniqueExamIDs U on U.UniqueExamID = E.Exam_Unique_Id
                                 WHERE  E.Criteria = 'CRITERIA2'                                 
                                        AND E.Denominator_Exceptions IN ( 'Y', 'y' )
                                     )

			update @tbl_Physician_Aggr SET Performance_Met = (  SELECT COUNT(E.Measure_ID)
                                FROM    @PRExamNumerator_VWForMes_409 E 
									join @UniqueExamIDs U on U.UniqueExamID = E.Exam_Unique_Id
                                 WHERE  E.Criteria = 'CRITERIA2'                                 
                                        AND E.Performance_met IN ( 'Y', 'y' )
                                     )
			update @tbl_Physician_Aggr SET Performance_Not_Met = (  SELECT COUNT(E.Measure_ID)
                                FROM    @PRExamNumerator_VWForMes_409 E 
									join @UniqueExamIDs U on U.UniqueExamID = E.Exam_Unique_Id
                                 WHERE  E.Criteria = 'CRITERIA2'                                 
                                        AND E.Performance_met IN ( 'N', 'n' )
                                     )
			update @tbl_Physician_Aggr SET Denominator_Exclusions = (  SELECT COUNT(E.Measure_ID)
                                FROM    @PRExamNumerator_VWForMes_409 E 
									join @UniqueExamIDs U on U.UniqueExamID = E.Exam_Unique_Id
                                 WHERE  E.Criteria = 'CRITERIA2'                                 
                                        AND E.Exclusion IN ( 'Y', 'y' )
                                     )
			Update @tbl_Physician_Aggr set Reporting_Denominator = Init_Patient_Population,
										Reporting_Numerator = Performance_Met + Performance_Not_Met + Denominator_Exceptions,
										Performance_Numerator = Performance_Met,
										Performance_denominator = (Performance_Met + Performance_Not_Met) + (@Total_Population_Count_Criteria_One - @Total_Population_Count_Criteria_Two)

			UPDATE A SET Original_Reporting_Denominator= Init_Patient_Population-Denominator_Exclusions ,      
					Original_Reporting_Numerator=Performance_Met+Performance_Not_Met 
				FROM @tbl_Physician_Aggr A 							  
	

			UPDATE A SET  Reporting_Rate= CASE WHEN Reporting_Denominator>0 THEN ((CAST(Reporting_Numerator  as float)/Reporting_Denominator) *100) ELSE NULL END,
						  Performance_rate=CASE WHEN Performance_denominator>0 THEN((CAST(Performance_Numerator AS float)/Performance_denominator)*100) ELSE 0 END
					  FROM @tbl_Physician_Aggr A 

			UPDATE A SET  Original_Reporting_Rate= CASE WHEN Reporting_Denominator>0 THEN ((CAST(Original_Reporting_Numerator  as float)/Original_Reporting_Denominator) *100) ELSE NULL END
					FROM @tbl_Physician_Aggr A 

			UPDATE A SET Criteria = 'CRITERIA2' FROM @tbl_Physician_Aggr A

			-----------------Criteria 2 aggregation Ended ---------------
		END           	  
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
           ,[observationInstances]
		   ,[Criteria])

		 SELECT CMS_Submission_Year
		 ,CMS_Submission_Date
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
		 ,observationInstances
		 ,Criteria
		  from 
		  @tbl_Physician_Aggr --where Criteria = 'CRITERIA1'

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
   	
	END
