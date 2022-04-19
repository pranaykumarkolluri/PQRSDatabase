-- =============================================
-- Author:		Raju G
-- Create date: Feb-26- 2018
-- Description:	Getting the measure related data using TIN
--Chnage#1 Date: March 12,2018
--Change#1 Des : Get CMS_Message from tbl_lookup_measures --jira-522
--Change#2 Date:hari j: Nov,13th,2018
--Change#2 Des : measure 46 displaying 3 times bcz of stratum,so getting only one
--Change#3 Date:Hari J Dec,14th,2018
--Change#3 Des : get Latest TotalExamsCount
--Change#4 For Jira 617 isEndToEndReported 
--Change#5:HARI J: 31st,dec,2018
--Change#5:changed as Reusable method
--Change#6:Sumanth J: 11 feb 2019
--Change#6:Two columns data added for measure 226
--Change#7:Sumanth J: 03 mar 2019
--Change#7:Jira #672
--Change#8:JIRA#696: Display priority symbol for a measure in CMS submission and Performance report page
--Change#9: Jira#719
--Change#10: Jira#750
-- =============================================
CREATE PROCEDURE [dbo].[spNPIRelatedMeasureDataForFullYear]
	-- Add the parameters for the stored procedure here
   @TIN varchar(9),
   @NPI varchar(11),
   @CMSYear int,
   @isExport bit

AS
BEGIN
DECLARE @Measure_226 varchar(10)='226';
DECLARE @IsGpro bit;
DECLARE @C1_StratumID int=5--Refer table tbl_Lookup_Stratum
DECLARE @C3_StratumID int=6
select @IsGpro=is_GPRO from tbl_TIN_GPRO where TIN=@TIN
					select 
					LM.Measure_num,
					--Change#7
					--ISNULL(@TotalExamCount,0) as TotalExamsCount ,
					ISNULL(A.TotalExamsCount,0) as TotalExamsCount ,  --this is overall/c2 exam count for 226 
					G.SelectedForSubmission as SelectedForCMSSubmission,
					ISNULL(G.TotalCasesReviewed,0) as TotalCasesReviewed,   --this is screenedForUse/c1 exam count for 226 
					A.Exam_TIN as Tin,
					A.CMS_Submission_Year as CMSYear,
					A.Is_90Days as is90days,
					case when (G.DateLastSelected is not null and G.DateLastUnSelected is not null) and (G.DateLastSelected> G.DateLastUnSelected) then G.DateLastSelected
						 when (G.DateLastSelected is not null and G.DateLastUnSelected is not null) and (G.DateLastSelected < G.DateLastUnSelected) then G.DateLastUnSelected
						 when (G.DateLastSelected is not null and G.DateLastUnSelected is  null)  then G.DateLastSelected
						 when (G.DateLastSelected is null and G.DateLastUnSelected is not null)  then G.DateLastUnSelected
						 else NULL end as Last_Mod_Date,

					-- case when (G.HundredPercentSubmit=0 and isnull(G.TotalCasesReviewed,'')='') then CONVERT(bit,0) else CONVERT(bit,1) end as isSavedPreviously,
					case when G.Measure_num_ID=@Measure_226
					then
					case when (G.HundredPercentSubmit=0 and isnull(G.TotalCasesReviewed,'')='' and G.HundredPercentSubmit_C2=0 and isnull(G.TotalCasesReviewed_C2,'')='') then CONVERT(bit,0) else CONVERT(bit,1) end
					else
					case when (G.HundredPercentSubmit=0 and isnull(G.TotalCasesReviewed,'')='') then CONVERT(bit,0) else CONVERT(bit,1) end 
					end as isSavedPreviously,

				 -- case when G.HundredPercentSubmit=1 then G.HundredPercentSubmit
					--when  isnull(G.TotalCasesReviewed,'')='' then CONVERT(bit,1) 
					--else CONVERT(bit,0) end as HundredPercentSubmit,
					case when @isExport=0 then (case when G.HundredPercentSubmit=1 then G.HundredPercentSubmit
					when  isnull(G.TotalCasesReviewed,'')='' then CONVERT(bit,1) else CONVERT(bit,0) end) else isnull(G.HundredPercentSubmit,CONVERT(bit,0)) 
					end as HundredPercentSubmit, --this is screenedForUse/c1 exam count for 226

					LM.PhysGroupMeasure,

					A.Performance_rate,
					A.Decile_Val ,
					A.Reporting_Rate,			
				
					A.Physician_NPI as NPI,
					LM.CMS_Message,
					G.isEndToEndReported,     --Change#4    
				
			--isnull(G.HundredPercentSubmit_C2,0) as HundredPercentSubmit_C2,  --Change#6
				case when G.HundredPercentSubmit_C2=1 then G.HundredPercentSubmit_C2
				when  isnull(G.TotalCasesReviewed_C2,'')='' then CONVERT(bit,1) 
				else CONVERT(bit,0) end as HundredPercentSubmit_C2,
				isnull(G.TotalCasesReviewed_C2,0) as TotalCasesReviewed_C2 ,      --Change#6

				--case when G.HundredPercentSubmit_C3=1 then G.HundredPercentSubmit_C3
				--when  isnull(G.TotalCasesReviewed_C3,'')='' then CONVERT(bit,1) 
				--else CONVERT(bit,0) end as HundredPercentSubmit_C3,
				--isnull(G.TotalCasesReviewed_C3,0) as TotalCasesReviewed_C3 ,      --Change#6
			    CONVERT(bit,0) as HundredPercentSubmit_C3 ,
				0 as TotalCasesReviewed_C3,

					CASE WHEN A.Measure_Num=@Measure_226 THEN (SELECT TOP 1 B.TotalExamsCount from tbl_Physician_Aggregation_Year B where B.Measure_Num=@Measure_226
					                                                                     and (B.Stratum_Id=@C1_StratumID) 
																		    and B.Exam_TIN=A.Exam_TIN 
																		    and B.Physician_NPI=A.Physician_NPI 
																		    and B.CMS_Submission_Year=A.CMS_Submission_Year
																			and B.Is_90Days=A.Is_90Days)
                                                       ELSE 0 END as TotalExamsCount_C1,
				   --CASE WHEN A.Measure_Num=@Measure_226 THEN (SELECT TOP 1 B.TotalExamsCount from tbl_Physician_Aggregation_Year B where B.Measure_Num=@Measure_226
					  --                                                                   and (B.Stratum_Id=@C3_StratumID) 
							--											    and B.Exam_TIN=A.Exam_TIN 
							--											    and B.Physician_NPI=A.Physician_NPI 
							--											    and B.CMS_Submission_Year=A.CMS_Submission_Year)
       --                                                ELSE 0 END as TotalExamsCount_C3
	                        0 as TotalExamsCount_C3,
							LM.Measure_Scoring,
						    case when LM.Measure_Scoring='C' then Lm.score_type+': '+ CONVERT(nvarchar(500), A.Performance_Numerator)+' '+lm.value_unit
							else '' end as PR_CMeasure,        --Change#7
							LP.[Name] as PriorityName,           --Change#8
							case when  exists(select 1 from tbl_CI_Measuredata_value md join
							tbl_CI_Source_UniqueKeys su on md.KeyId=su.Key_Id and su.Key_Id=sc.Key_Id  and  md.Measure_Name= case when LEN(A.Measure_Num)=2 then ('0'+A.Measure_Num) 
												                            ELSE REPLACE(A.Measure_Num,' ','')
																			END) then CONVERT(bit,1)  
							ELSE CONVERT(bit,0) end as ISSubmittedtoCMS,                 --Change#9: Jira#719
							LM.Is_eCQM              --Change#10
		from tbl_Physician_Aggregation_Year A 
					
					INNER JOIN tbl_Lookup_Measure LM ON LM.CMSYear=@CMSYear 
													AND LM.ForCMSSubmission=1
													--AND LM.Measure_num=@Measure_Num 					
													AND A.Measure_num=LM.Measure_num
													AND A.CMS_Submission_Year=LM.CMSYear
													AND A.Exam_TIN=@TIN 
													AND A.Physician_NPI=@npi
													AND A.Is_90Days=0 
					LEFT JOIN tbl_Lookup_Measure_Priority LP on LM.Priority_ID=LP.Priority_ID       --Change#8
					LEFT JOIN tbl_Physician_Selected_Measures G  ON A.CMS_Submission_Year=G.[Submission_year] 												          					                                     					                                      
					                                      AND A.Measure_num=G.Measure_num_ID 
					                                      AND A.Exam_TIN=G.TIN
														  AND A.Physician_NPI=G.NPI
														  AND  A.Is_90Days= G.Is_90Days
					LEFT JOIN tbl_Lookup_Stratum LS ON A.Stratum_Id = LS.Stratum_Id 
					                               AND ls.Measure_Num = A.Measure_num
					                               AND ls.Stratum_Name='overall'
                     LEFT JOIN tbl_CI_Source_UniqueKeys sc on A.Exam_TIN=sc.Tin                            --Change#9: Jira#719
					                               --AND ISNULL(sc.Npi,'')= case when @IsGpro=1 then  ISNULL(sc.Npi,'') else A.Physician_NPI end	
												   AND sc.Npi=A.Physician_NPI									  										 												  						  
				                                   AND sc.IsMSetIdActive=1												  
												   AND sc.CmsYear=A.CMS_Submission_Year 
												   AND sc.Category_Id=1
                   -- LEFT JOIN tbl_CI_Measuredata_value md on sc.Key_Id=md.KeyId                                 --Change#9: Jira#719
					              --                AND md.Measure_Name= case when LEN(A.Measure_Num)=2 then ('0'+A.Measure_Num) 
												       --                     ELSE REPLACE(A.Measure_Num,' ','')
																			--END
                   --                                AND md.Stratum_Name= case when A.Measure_Num ='ACRAD 34' then 'head'    --JIRA#736
												                           
												       --                     ELSE md.Stratum_Name
																			--END 
				WHERE (A.Measure_num NOT IN ('46', @Measure_226) OR LS.Stratum_Id IS NOT NULL)
				order by LM.DisplayOrder
END

