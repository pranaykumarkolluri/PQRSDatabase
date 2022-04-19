-- =============================================
-- Author:	hari j
-- Create date: feb 16 2018
-- Description:	Get TIN and measure number Realated Measure Data Based on tin and cms year
-- this is used to get single tin data after calculating the performance report for single measure and tin
-- [spTinRelatedMeasureData] @cmsYear = is the year of data. 
--Change#1    : Display CMS_Message from tbl_lookup_measures. jira-522
--Change#1 By : Raju Gaddam Date: March 12,2018.
-- =============================================
CREATE PROCEDURE [dbo].[spTinMeasureRelatedMeasureDataFor90Days] 
	-- Add the parameters for the stored procedure here
	@cmsyear int , --is the year of data. 
	@TIN varchar(9), -- TIn for which data need to retrieved.
	@measureNum varchar(25),-- Measure num related data
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
,isnull(TAY.TotalExamsCount,0) as TotalExamsCount 
,TAY.SelectedForCMSSubmission
, isnull(GTSM.TotalCasesReviewed,0) as TotalCasesReviewed
--,@TIN as Tin
,TAY.Exam_TIN as Tin
,@cmsyear as CMSYear
,isnull(@is90days
,CONVERT(bit,0)) as is90days
,TAY.Last_Mod_Date,
case when (GTSM.HundredPercentSubmit=0 and isnull(GTSM.TotalCasesReviewed,'')='') then CONVERT(bit,0) else CONVERT(bit,1) end as isSavedPreviously,
GTSM.HundredPercentSubmit
 ,LM.PhysGroupMeasure
 ,isnull(TAY.totalPhysiansSubmittedCount,0) as totalPhysiansSubmittedCount 
 ,TAY.Performance_rate
 ,TAY.Decile_Val,TAY.Reporting_Rate
 ,LM.CMS_Message --Change#1
 from  tbl_Lookup_Measure LM inner join tbl_TIN_Aggregation_Year TAY    on
   TAY.CMS_Submission_Year =LM.CMSYear and lm.Measure_num = TAY.Measure_Num
    inner join tbl_GPRO_TIN_Selected_Measures_90days GTSM on 
	GTSM.Submission_year  = LM.CMSYear	
	and TAY.Exam_TIN=GTSM.TIN
	and LM.Measure_Num=GTSM.Measure_num
	where
LM.CMSYear=@cmsyear
and TAY.Exam_TIN=@TIN 
and GTSM.Measure_num=@measureNum
and TAY.Is_90Days=@is90days

   
END
return @@rowcount
