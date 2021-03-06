-- =============================================
-- Author:	raju g
-- Create date: Feb-26- 2018
-- Description:	Getting the measure related data using TIN
--Chnage#1 Date: March 12,2018
--Change#1 Des : Get CMS_Message from tbl_lookup_measures --jira-522
-- =============================================
CREATE PROCEDURE [dbo].[spTinRelatedMeasureDataFor90days]
	-- Add the parameters for the stored procedure here
   @TIN varchar(9),
   @CMSYear int,
   @isExport bit
AS
BEGIN
declare @tbl_TinMeasureData_test table(
Measure_num varchar(10),
TotalExamsCount int,
SelectedForCMSSubmission bit,
TotalCasesReviewed int,
Tin varchar(9),
CMSYear int,
is90days bit,
Last_Mod_Date datetime,
isSavedPreviously bit,
HundredPercentSubmit bit,
PhysGroupMeasure bit,
totalPhysiansSubmittedCount int,
Performance_rate decimal(18,4),
Decile_Val varchar(25),
Reporting_Rate decimal(18,4),
CMS_Message varchar(5000)  --Change#1

);


declare @CurMeasure_num varchar(10);
declare @CurphysicicanGroupMeasure bit; 
declare @CurMeasure_ID int;
declare @CurCMS_Message varchar(5000); --Change#1


DECLARE Cur_MeasureData CURSOR READ_ONLY FOR  
--
select Measure_num,PhysGroupMeasure,Measure_ID,CMS_Message  
from tbl_Lookup_Measure where 
CMSYear=@CMSYear and ForCMSSubmission=1 
OPEN Cur_MeasureData   
FETCH NEXT FROM Cur_MeasureData INTO @CurMeasure_num,@CurphysicicanGroupMeasure,@CurMeasure_ID,@CurCMS_Message
WHILE @@FETCH_STATUS = 0   
BEGIN 
	if exists(select * from tbl_GPRO_TIN_Selected_Measures_90days where TIN=@TIN and Submission_year=@CMSYear and Measure_num=@CurMeasure_num)
		begin
			insert into @tbl_TinMeasureData_test
					select 
					@CurMeasure_num,
					A.TotalExamsCount ,
					G.SelectedForSubmission,
					G.TotalCasesReviewed,
					G.TIN,
					A.CMS_Submission_Year,
					A.Is_90Days,
					case when (G.DateLastSelected is not null and G.DateLastUnSelected is not null) and (G.DateLastSelected> G.DateLastUnSelected) then G.DateLastSelected
						 when (G.DateLastSelected is not null and G.DateLastUnSelected is not null) and (G.DateLastSelected < G.DateLastUnSelected) then G.DateLastUnSelected
						 when (G.DateLastSelected is not null and G.DateLastUnSelected is  null)  then G.DateLastSelected
						 when (G.DateLastSelected is null and G.DateLastUnSelected is not null)  then G.DateLastUnSelected
						 else NULL end as DateLastSelected,

					case when (G.HundredPercentSubmit=0 and isnull(G.TotalCasesReviewed,'')='') then CONVERT(bit,0) else CONVERT(bit,1) end as isSavedPreviously,
					case when @isExport=0 then (case when G.HundredPercentSubmit=1 then G.HundredPercentSubmit
					when  isnull(G.TotalCasesReviewed,'')='' then CONVERT(bit,1) else CONVERT(bit,0) end) else isnull(G.HundredPercentSubmit,CONVERT(bit,0)) 
					end as HundredPercentSubmit,
					@CurphysicicanGroupMeasure,
					A.totalPhysiansSubmittedCount,
					A.Performance_rate,
					A.Decile_Val,
					A.Reporting_Rate,
					@CurCMS_Message
					from tbl_GPRO_TIN_Selected_Measures_90days G inner  join
					 tbl_TIN_Aggregation_Year A
					on A.Measure_num=G.Measure_num 
					and A.Exam_TIN=G.TIN
					where CMS_Submission_Year=@CMSYear
					and G.TIN=@TIN 
					and A.Is_90Days=1 
					--and G.Is_90Days=0 
					and G.[Submission_year]=@CMSYear
					and G.Measure_num=@CurMeasure_num
					
		end
	else
		begin
		insert into @tbl_TinMeasureData_test(Measure_num,PhysGroupMeasure,
		Tin,TotalExamsCount,HundredPercentSubmit,totalPhysiansSubmittedCount,
		CMSYear,is90days,CMS_Message)
					select 
					@CurMeasure_num
					,@CurphysicicanGroupMeasure
					,A.Exam_TIN
					,A.TotalExamsCount
					,1
					,A.totalPhysiansSubmittedCount
					,A.CMS_Submission_Year
					,A.Is_90Days
					,@CurCMS_Message
					from tbl_TIN_Aggregation_Year A
					where 
					A.Measure_num=@CurMeasure_num
					and A. CMS_Submission_Year=@CMSYear
					and A.Exam_TIN=@TIN 
					and A.Is_90Days=1
			 
		end

FETCH NEXT FROM Cur_MeasureData INTO @CurMeasure_num,@CurphysicicanGroupMeasure,@CurMeasure_ID,@CurCMS_Message
END   
CLOSE Cur_MeasureData   
DEALLOCATE Cur_MeasureData


select * from @tbl_TinMeasureData_test
END

