-- =============================================
-- Author:		RAJU
-- Description:	Getting selected non gpro related measure data
--Change#1 : Adding Cms_Submission_Status Pavan 08/31/2021
-- =============================================
CREATE PROCEDURE [dbo].[spSelectedTINNPIRelatedMeasureDataForFullYear]
	-- Add the parameters for the stored procedure here
   @CMSYear int,
   @isExport bit,
@tbl_CI_Tins_Type tbl_CI_Tins_Type Readonly

AS
BEGIN

Declare  @PhysicianTinsNpis table(TIN varchar(9),NPI varchar(10));

Insert into @PhysicianTinsNpis(TIN,NPI)
select distinct TIN,NPI from NRDR..PHYSICIAN_TIN_VW  

--DECLARE @Tins_Npis table(first_name varchar(100),last_name varchar(100),npi varchar(10),tin varchar(9));
--insert into @Tins_Npis
-- exec sp_getFacilityPhysicianNPIsTINs @Current_User;
 			select 
		
					A.Exam_TIN as TIN,
						
				
					A.Physician_NPI as NPI,
				
					
		 
					LM.Measure_num as Measure_Number,
				    Case when  A.TotalExamsCount is null then '' else Convert(varchar(50),A.TotalExamsCount) end as Total_numberof_Exams_mygroup_performed,
					Case when G.TotalCasesReviewed is null then '' else CONVERT(varchar(50),G.TotalCasesReviewed) end as Total_Exam_Volume_Old,
					'' as Total_Exam_Volume_New,

					Case When G.HundredPercentSubmit is null THEN ''
					     when G.HundredPercentSubmit=1 THEN 'Y'
						 WHEN G.HundredPercentSubmit=0 THEN 'N'
				    END as Submitted_Hundred_Percent_OLD,
					'' as Submitted_Hundred_Percent_NEW,

					Case When G.SelectedForSubmission is null THEN ''
					     when G.SelectedForSubmission=1 THEN 'Y'
						 WHEN G.SelectedForSubmission=0 THEN 'N'
				    END as Selected_for_CMS_submission_OLD,				
					'' as Selected_for_CMS_submission_NEW,

					Case When G.isEndToEndReported is null THEN ''
					     when G.isEndToEndReported=1 THEN 'Y'
						 WHEN G.isEndToEndReported=0 THEN 'N'
				    END  as EndtoEndReporting_OLD,
					'' as EndtoEndReporting_NEW,

				case when A.Performance_rate is not null then convert(decimal(10,2),A.Performance_rate) else convert(decimal(10,2),0.00) end as Performance_rate  ,
					case when A.Reporting_Rate is not null then convert(decimal(10,2),A.Reporting_Rate) else convert(decimal(10,2),0.00) end as Completeness  ,
					
				    CASE WHEN A.CMS_Submission_Year<=2017 AND (A.Reporting_Rate IS NULL OR A.Reporting_Rate < 50 OR A.Decile_Val='NoMeasure'  OR A.Decile_Val='not available') THEN '3 Points'
					     WHEN A.CMS_Submission_Year > 2017 AND (A.Reporting_Rate IS NULL OR A.Reporting_Rate < 60) AND A.Decile_Val Is not null THEN '1 Point'
						 WHEN A.CMS_Submission_Year > 2017 AND (A.Decile_Val='NoMeasure'  OR A.Decile_Val='not available') AND A.Decile_Val Is not null THEN '3 Points'
						 Else A.Decile_Val
						 end 
					
					 as Decile,
					 --Change#1
					case when  exists(select 1 from tbl_CI_Measuredata_value md join
							tbl_CI_Source_UniqueKeys su on md.KeyId=su.Key_Id and su.Key_Id=sc.Key_Id  and  md.Measure_Name= case when LEN(A.Measure_Num)=2 then ('0'+A.Measure_Num) 
												                            ELSE REPLACE(A.Measure_Num,' ','')
																			END) then 'Submitted to CMS'   
							ELSE 'Not Submitted to CMS' end as CMS_Submission_Status					 	
			from tbl_Physician_Aggregation_Year A 
					
					INNER JOIN tbl_TIN_GPRO TG on A.CMS_Submission_Year=@CMSYear 
										   AND A.Exam_TIN=TG.TIN and TG.is_GPRO=0
										   AND A.Measure_Num <>'226'  -- For Batch Submisison we did n't consider measure 226
					INNER JOIN @tbl_CI_Tins_Type  T on  
												A.Exam_TIN=T.tin
					INNER JOIN @PhysicianTinsNpis P on
												A.Exam_TIN=P.TIN 
											and A.Physician_NPI=P.NPI				   
										    
					
					INNER JOIN tbl_Lookup_Measure LM ON LM.CMSYear=A.CMS_Submission_Year 
													AND LM.ForCMSSubmission=1					
													AND A.Measure_num=LM.Measure_num
													AND A.Is_90Days=0 
					
					LEFT JOIN tbl_Physician_Selected_Measures G  ON A.CMS_Submission_Year=G.[Submission_year] 												          					                                     					                                      
					                                 AND A.Measure_num=G.Measure_num_ID 
					                                 AND A.Exam_TIN=G.TIN
													 AND A.Physician_NPI=G.NPI
													 AND  A.Is_90Days= G.Is_90Days
					LEFT JOIN tbl_Lookup_Stratum LS ON A.Stratum_Id = LS.Stratum_Id 
					                                 AND ls.Measure_Num = A.Measure_num
					                                 AND ls.Stratum_Name='overall'
				    LEFT JOIN tbl_CI_Source_UniqueKeys sc on A.Exam_TIN=sc.Tin        --Change#1                    --Change#10: Jira#719
					                               AND sc.Npi=A.Physician_NPI
				                                   AND sc.IsMSetIdActive=1												  
												   AND sc.CmsYear=A.CMS_Submission_Year 
												   AND sc.Category_Id=1
				WHERE (A.Measure_num NOT IN ('46', '226') OR LS.Stratum_Id IS NOT NULL)
				ORDER BY A.Exam_TIN ,A.Physician_NPI, LM.DisplayOrder 


				--select  '123456789'as TIN,
				--     '1528286911' as NPI,
				--	 '12' as Measure_Number,
				--     '3' as Total_numberof_Exams_mygroup_performed,			
				--	 'N' as Number_of_Exams_Submitted_OLD,
				--	 '' as Number_of_Exams_Submitted_NEW,
				--	 'Y'as Submitted_Hundred_Percent_OLD,
				--	 '' as Submitted_Hundred_Percent_NEW,
				--     'Y' Selected_for_CMS_submission_OLD,
				--	 '' as Selected_for_CMS_submission_NEW,
				--	 'Y'as EndtoEndReporting_OLD,
				--	 '' as EndtoEndReporting_NEW,
				--	 '0.00'as Performance_rate ,
				--	 '1.00'  as Completeness,
				--	 '3 points' as Decile
				--	from tbl_Exam
END



