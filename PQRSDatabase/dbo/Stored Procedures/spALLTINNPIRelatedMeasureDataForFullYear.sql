-- =============================================
-- Author:		HARIKRISHNA
-- Create date: OCT 25th,2018
-- Description:	Getting the TIN and NPI related measure data
--Change#2 Date:Hari J Nov,28th,2018
--Change#2 Des : measure 46 displaying 3 times bcz of stratum,so getting only one
--Change#3 Date:Hari J Dec,14th,2018
--Change#3 Des : get Latest TotalExamsCount
--Change#4 Des : Jira 617
--Change#5:HARI J: 31st,dec,2018
--Change#5:changed as Reusable method
--Change#6:Sumanth J: 11 feb 2019
--Change#6:get Two columns data added for measure 226
-- =============================================
CREATE PROCEDURE [dbo].[spALLTINNPIRelatedMeasureDataForFullYear]
	-- Add the parameters for the stored procedure here
 
   @Current_User varchar(50),
   @CMSYear int,
   @isExport bit

AS
BEGIN

DECLARE @Tins_Npis table(first_name varchar(100),last_name varchar(100),npi varchar(10),tin varchar(9),is_active bit, deactivation_date datetime,is_enrolled bit)

insert into @Tins_Npis
 exec sp_getFacilityPhysicianNPIsTINs @Current_User;
 			select 
					LM.Measure_num,
					--Change#7
					--ISNULL(@TotalExamCount,0) as TotalExamsCount ,
					ISNULL(A.TotalExamsCount,0) as TotalExamsCount ,
					G.SelectedForSubmission as SelectedForCMSSubmission,
					ISNULL(G.TotalCasesReviewed,0) as TotalCasesReviewed,
					A.Exam_TIN as Tin,
					A.CMS_Submission_Year as CMSYear,
					A.Is_90Days as is90days,
					case when (G.DateLastSelected is not null and G.DateLastUnSelected is not null) and (G.DateLastSelected> G.DateLastUnSelected) then G.DateLastSelected
						 when (G.DateLastSelected is not null and G.DateLastUnSelected is not null) and (G.DateLastSelected < G.DateLastUnSelected) then G.DateLastUnSelected
						 when (G.DateLastSelected is not null and G.DateLastUnSelected is  null)  then G.DateLastSelected
						 when (G.DateLastSelected is null and G.DateLastUnSelected is not null)  then G.DateLastUnSelected
						 else NULL end as Last_Mod_Date,

					-- case when (G.HundredPercentSubmit=0 and isnull(G.TotalCasesReviewed,'')='') then CONVERT(bit,0) else CONVERT(bit,1) end as isSavedPreviously,
					case when G.Measure_num_ID='226'
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
					end as HundredPercentSubmit,

					LM.PhysGroupMeasure,

					A.Performance_rate,
					A.Decile_Val ,
					A.Reporting_Rate,			
				
					A.Physician_NPI as NPI,
					LM.CMS_Message,
					G.isEndToEndReported,     --Change#4    
				
			isnull(G.HundredPercentSubmit_C2,0) as HundredPercentSubmit_C2,  --Change#6
			isnull(G.TotalCasesReviewed_C2,0) as TotalCasesReviewed_C2       --Change#6
			from tbl_Physician_Aggregation_Year A 
					
					INNER JOIN tbl_TIN_GPRO TG on A.CMS_Submission_Year=@CMSYear 
										   AND A.Exam_TIN=TG.TIN and TG.is_GPRO=0
					INNER JOIN @Tins_Npis  T on  
												A.Exam_TIN=T.tin
										   AND  A.Physician_NPI=T.npi
										    
					
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
				WHERE (A.Measure_num NOT IN ('46', '226') OR LS.Stratum_Id IS NOT NULL)
END

