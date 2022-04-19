-- =============================================
-- Author:		Raju Gaddam
-- Create date: feb 16 2018
-- Description:	Get TIN Realated Measure Data Based on tin and cms year
-- [spTinRelatedMeasureData] @cmsYear = is the year of data. 
-- =============================================
CREATE PROCEDURE [dbo].[spTinRelatedMeasureData] 
	-- Add the parameters for the stored procedure here
	@cmsyear int , --is the year of data. 
	@TIN varchar(9), -- TIn for which data need to retrieved.
	@isExport bit = 0, --  default is false ie. not for export to xml or final
	@is90days bit =0  -- default is 0 i.e its 365 days data calculation
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
	declare @isPreviousSave bit;
declare @HundredPercentOfSubmit bit;
--declare @isExport bit ;
--set @isExport =0;
set @isPreviousSave=0;
set @HundredPercentOfSubmit =0;

select LM.Measure_num 
,isnull(T.TotalExamsCount,0) as TotalExamsCount 
,T.SelectedForCMSSubmission
, isnull(G.TotalCasesReviewed,0) as TotalCasesReviewed
--,@TIN as Tin
,T.Exam_TIN as Tin
,@cmsyear as CMSYear
,isnull(@is90days
,CONVERT(bit,0)) as is90days
,T.Last_Mod_Date,
case when (G.HundredPercentSubmit=0 and isnull(G.TotalCasesReviewed,'')='') then CONVERT(bit,0) else CONVERT(bit,1) end as isSavedPreviously,
case when @isExport=0 then (case when G.HundredPercentSubmit=1 then G.HundredPercentSubmit
 when  isnull(G.TotalCasesReviewed,'')='' then CONVERT(bit,1) else CONVERT(bit,0) end) else isnull(G.HundredPercentSubmit,CONVERT(bit,0)) 
 end as HundredPercentSubmit
 ,LM.PhysGroupMeasure
 ,isnull(T.totalPhysiansSubmittedCount,0) as totalPhysiansSubmittedCount 
 ,T.Performance_rate
 ,T.Decile_Val,T.Reporting_Rate
 
 from  tbl_Lookup_Measure LM      
 left  join tbl_GPRO_TIN_Selected_Measures G 
 on
  --G.Submission_year  = LM.CMSYear 
  LM.Measure_num= G.Measure_num
	left join tbl_TIN_Aggregation_Year T 
	 on 
	 --T.CMS_Submission_Year =LM.CMSYear 
	 --and 
	 lm.Measure_num = T.Measure_Num
 
	--and T.Is_90Days=G.Is_90Days
	--and T.Exam_TIN=G.TIN
	--and LM.Measure_Num=G.Measure_num
	where
LM.CMSYear=@cmsyear
and T.Exam_TIN=@TIN 
--and (T.TotalExamsCount > 0)
and T.Is_90Days=@is90days
   

--and (TAY.Exam_TIN=@TIN or TAY.Exam_TIN is null)
--and TAY.Measure_Num ='23'
--and TAY.Is_90Days=@is90days
   
   
END
return @@rowcount