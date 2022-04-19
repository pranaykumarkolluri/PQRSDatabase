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
CREATE PROCEDURE [dbo].[spALLTINNPIRelatedMeasureDataForFullYear_Physician]
	-- Add the parameters for the stored procedure here
 
   @NPI varchar(11),
   @IS_GPRO bit,
   @CMSYear int,
   @isExport bit

AS
BEGIN


DECLARE @CUR_TIN varchar(9)
  

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
Performance_rate decimal(18,4),
Decile_Val varchar(25),
Reporting_Rate decimal(18,4)
,NPI varchar(11)
,CMS_Message varchar(5000)
,isEndtoEndReported bit
,HundredPercentSubmit_C2 bit    --Change#6
,TotalCasesReviewed_C2 int      --Change#6
,HundredPercentSubmit_C3 bit
,TotalCasesReviewed_C3 int
,TotalExamsCount_C1 int
,TotalExamsCount_C3 int
,Measure_Scoring varchar(50)
,PR_CMeasure varchar(50)
,PriorityName varchar(50)
,ISSubmittedtoCMS bit
,Is_eCQM  bit
);

-- binding user related tins 




declare @tbl_NPIRelatedTINs table(TIN varchar(9))

INSERT into @tbl_NPIRelatedTINs
select distinct TIN from NRDR..PHYSICIAN_TIN_VW where NPI  =@NPI

---- declare TIN related NPIs

declare @tbl_TINRelated_NPIS table(NPI varchar(11))



declare @CurMeasure_num varchar(10);
declare @CurphysicicanGroupMeasure bit; 
declare @CurMeasure_ID int
declare @CurCMS_Message varchar(5000);



-----Cur_All Tins starts-----------

DECLARE Cur_NonGPROTINData CURSOR READ_ONLY FOR  
--
select t.TIN from @tbl_NPIRelatedTINs t inner join tbl_TIN_GPRO G on t.TIN=g.TIN where g.Is_GPRO =1

OPEN Cur_NonGPROTINData   

FETCH NEXT FROM Cur_NonGPROTINData INTO @CUR_TIN

WHILE @@FETCH_STATUS = 0   
BEGIN 


---cur_tin related measure starts------------
DECLARE Cur_MeasureData CURSOR READ_ONLY FOR  
--
select Measure_num,PhysGroupMeasure,Measure_ID ,CMS_Message 
from tbl_Lookup_Measure where 
CMSYear=2021 and ForCMSSubmission=1 
OPEN Cur_MeasureData   
FETCH NEXT FROM Cur_MeasureData INTO @CurMeasure_num,@CurphysicicanGroupMeasure,@CurMeasure_ID,@CurCMS_Message
WHILE @@FETCH_STATUS = 0   
BEGIN 

insert into @tbl_TinMeasureData_test
EXEC	 [dbo].[spNPIMeasureRelatedmeasureDataForFullYear]
		@cmsyear = @CMSYear,
		@npi =@NPI,
		@TIN = @CUR_TIN,
		@is90days = 0,
		@Measure_Num = @CurMeasure_num


FETCH NEXT FROM Cur_MeasureData INTO @CurMeasure_num,@CurphysicicanGroupMeasure,@CurMeasure_ID,@CurCMS_Message
END   
CLOSE Cur_MeasureData   
DEALLOCATE Cur_MeasureData




---cur_tin related measure ends------------

FETCH NEXT FROM Cur_NonGPROTINData INTO @CUR_TIN
END   
CLOSE Cur_NonGPROTINData   
DEALLOCATE Cur_NonGPROTINData



-----Cur_All Tins starts-----------

select * from @tbl_TinMeasureData_test
END


