
-- =============================================
-- Author:		Raju Gaddam
-- Create date: feb 16 2018
-- Description:	Get TIN Realated Measure Data Based on tin and cms year
-- =============================================
CREATE PROCEDURE [dbo].[spNPIRelatedmeasureData] 
	-- Add the parameters for the stored procedure here
	@cmsyear int ,
	@npi varchar(11),
	@TIN varchar(9),
	@isExport bit,
	@is90days bit,
	@Measure_Num varchar(50)=''
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

select LM.Measure_num ,
TAY.TotalExamsCount,
TAY.SelectedForCMSSubmission, 
isnull(GTSM.TotalCasesReviewed,0) as TotalCasesReviewed
,@TIN as Tin
,@cmsyear as CMSYear
,@is90days as is90days
,TAY.Last_Mod_Date,
case when (GTSM.HundredPercentSubmit=0 and isnull(GTSM.TotalCasesReviewed,'')='') then CONVERT(bit,0) else CONVERT(bit,1) end as isSavedPreviously,
case when @isExport=0 then 
(case when GTSM.HundredPercentSubmit=1 then GTSM.HundredPercentSubmit
 when  isnull(GTSM.TotalCasesReviewed,'')='' then CONVERT(bit,1) else CONVERT(bit,0) end) else isnull(GTSM.HundredPercentSubmit,CONVERT(bit,0)) end as HundredPercentSubmit,
 LM.PhysGroupMeasure
 ,TAY.Performance_rate
 ,TAY.Decile_Val
 ,TAY.Reporting_Rate

from  tbl_Lookup_Measure LM inner join tbl_Physician_Aggregation_Year TAY    on
   TAY.CMS_Submission_Year =LM.CMSYear and lm.Measure_num = TAY.Measure_Num
    left join tbl_Physician_Selected_Measures GTSM on 
	GTSM.Submission_year  = LM.CMSYear
	and TAY.Is_90Days=GTSM.Is_90Days
	and TAY.Exam_TIN=GTSM.TIN
	and TAY.Physician_NPI=GTSM.NPI
	and LM.Measure_Num=GTSM.Measure_num_ID
	where
LM.CMSYear=@cmsyear
and TAY.Exam_TIN=@TIN 
and TAY.Physician_NPI=@npi
and (TAY.TotalExamsCount > 0)
and TAY.Is_90Days=@is90days
and TAY.Measure_Num = CASE  ISNULL(@Measure_Num,'') WHEN '' THEN TAY.Measure_Num ELSE @Measure_Num END
			
END

