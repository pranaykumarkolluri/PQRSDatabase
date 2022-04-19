-- =============================================
-- Author:		harikrishna 
-- Create date: oct,25,2018
-- Description:	Getting the all tins realted measure data
--Change#2 Date:Hari J Nov,28th,2018
--Change#2 Des : measure 46 displaying 3 times bcz of stratum,so getting only one
--Change#3 Date:Hari J Dec,14th,2018
--Change#3 Des : get Latest TotalExamsCount
--Change#4 Des : Jira 617
--Change#5:HARI J: 31st,dec,2018
--Change#5:changed as Reusable method
--Change#6:Sumanth J: 11 feb 2019
--Change#6:Two columns data added for measure 226
--======================================================
CREATE PROCEDURE [dbo].[spAllTinRelatedMeasureDataForFullYear]
	-- Add the parameters for the stored procedure here
	@Current_User varchar(50),
 
   @CMSYear int,
   @isExport bit
AS
BEGIN

---final return table

--- binding user related tins 

declare @tbl_UserTINs table(TIN varchar(9), Is_GPRO bit)
INSERT into @tbl_UserTINs
exec [NRDR]..[sp_getFacilityTIN_GPRO] @Current_User

			select  
					LM.Measure_num,
				A.TotalExamsCount ,
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
					case when G.Measure_num='226'
					then
					case when (G.HundredPercentSubmit=0 and isnull(G.TotalCasesReviewed,'')='' and G.HundredPercentSubmit_C2=0 and isnull(G.TotalCasesReviewed_C2,'')='') then CONVERT(bit,0) else CONVERT(bit,1) end
					else
					case when (G.HundredPercentSubmit=0 and isnull(G.TotalCasesReviewed,'')='') then CONVERT(bit,0) else CONVERT(bit,1) end 
					end as isSavedPreviously,


					case when @isExport=0 then (case when G.HundredPercentSubmit=1 then G.HundredPercentSubmit
					when  isnull(G.TotalCasesReviewed,'')='' then CONVERT(bit,1) else CONVERT(bit,0) end) else isnull(G.HundredPercentSubmit,CONVERT(bit,0)) 
					end as HundredPercentSubmit,

					LM.PhysGroupMeasure,
					ISNULL(A.totalPhysiansSubmittedCount,0) as totalPhysiansSubmittedCount,					
					A.Performance_rate,
					A.Decile_Val ,
					A.Reporting_Rate,

					LM.CMS_Message, -- Change#1
					G.isEndToEndReported,  --Change #4

				--isnull(G.HundredPercentSubmit_C2,0) as HundredPercentSubmit_C2,  --Change#5
				case when @isExport=0 then (case when G.HundredPercentSubmit_C2=1 then G.HundredPercentSubmit_C2
				when  isnull(G.TotalCasesReviewed_C2,'')='' then CONVERT(bit,1) else CONVERT(bit,0) end) else isnull(G.HundredPercentSubmit_C2,CONVERT(bit,0)) 
				end as HundredPercentSubmit_C2,

				isnull(G.TotalCasesReviewed_C2,0) as TotalCasesReviewed_C2       --Change#5

					from tbl_TIN_Aggregation_Year A 
					INNER JOIN @tbl_UserTINs T ON A.CMS_Submission_Year=@CMSYear
												AND A.Exam_TIN=T.TIN and T.Is_GPRO=1

					INNER JOIN tbl_Lookup_Measure LM ON LM.CMSYear=A.CMS_Submission_Year 
													and LM.ForCMSSubmission=1 					
													AND A.Measure_num=LM.Measure_num
													and A.CMS_Submission_Year=LM.CMSYear
													--and A.Exam_TIN=@TIN 
													and A.Is_90Days=0 
					LEFT JOIN tbl_GPRO_TIN_Selected_Measures G  ON A.CMS_Submission_Year=G.[Submission_year] 												          					                                     					                                      
					                                      AND A.Measure_num=G.Measure_num 
					                                      AND A.Exam_TIN=G.TIN
															and A.Is_90Days= G.Is_90Days
					LEFT JOIN tbl_Lookup_Stratum LS ON A.Stratum_Id = LS.Stratum_Id 
					                               AND ls.Measure_Num = A.Measure_num
					                               and ls.Stratum_Name='overall'
				WHERE (A.Measure_num NOT IN ('46', '226') OR LS.Stratum_Id IS NOT NULL)
					                               					                              					                             
					        
END


