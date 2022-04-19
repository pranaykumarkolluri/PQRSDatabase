

-- =============================================
-- Author:		Prashanth kumar Garlapally
-- Create date: 20-jul-2014
-- Description:	This stored proc is used to delete previous migrated partial/full data
--              for which a new set, under new transaction has arrived.
-- =============================================

CREATE PROCEDURE [dbo].[spDeletePrevTransImportData] 
	@Transactionid as varchar(100),
	@prev_Transactionid as varchar(100),
	@Appid as varchar(100),
	@PartnerID as varchar(100),
	@facilityID as varchar(100)
AS
BEGIN
Set nocount on;
--#1 : delete from tbl_Exam_Measure_Data_Extension

 print('spDeletePrevTransImportData-1 started'+CONVERT( VARCHAR(24), GETDATE(), 113));	
delete from tbl_Exam_Measure_Data_Extension 
where Exam_Measure_Data_ID	in 
(
	select Exam_Measure_Id from  tbl_Exam_Measure_Data where Exam_Id in 
	(
		select exam_id from tbl_Exam where Transaction_ID in( @prev_Transactionid,@Transactionid)
		and PartnerID = @PartnerID
		and AppID  = @Appid
	)
)
 print('spDeletePrevTransImportData-2 started'+CONVERT( VARCHAR(24), GETDATE(), 113));	
--#2 : delete from tbl_Exam_Measure_Data	
delete from tbl_Exam_Measure_Data where Exam_Id
in (
select exam_id from tbl_Exam where Transaction_ID in(@prev_Transactionid,@Transactionid)
		and PartnerID = @PartnerID
		and AppID  = @Appid
		)
print('spDeletePrevTransImportData-3 started'+CONVERT( VARCHAR(24), GETDATE(), 113));	
--#3 : delete from tbl_Exam
delete from tbl_Exam where Transaction_ID in( @prev_Transactionid,@Transactionid)
		and PartnerID = @PartnerID
		and AppID  = @Appid
print('spDeletePrevTransImportData-4 started'+CONVERT( VARCHAR(24), GETDATE(), 113));	
		
--#3 : set status in tbl_Import_exams and tbl_import_Raw to 7 

		
		
		-- for  you need to check if tbl_Import_Raw any 1 received,3 successful,4 partially successful
		declare @intGoodExamsSet int;
		set @intGoodExamsSet = 0;
		
		Select @intGoodExamsSet = count(RawData_Id) from tbl_Import_Exams where Import_Status in (1,3,4,6,10,11) and 
		Transaction_ID = @prev_Transactionid
		and PartnerID = @PartnerID
		and AppID  = @Appid 
print('spDeletePrevTransImportData-5 started'+CONVERT( VARCHAR(24), GETDATE(), 113));		
		--Select count(RawData_Id)as '@intGoodExamsSet' from tbl_Import_Exams where Import_Status in (1,3,4,6,10,11) and 
		--Transaction_ID = @prev_Transactionid
		--and PartnerID = @PartnerID
		--and AppID  = @Appid 
		
		if @intGoodExamsSet > 0
		Begin
			--update R
			--set 
			--R.[Status] = 7
			--from tbl_Import_Raw as R inner join tbl_Import_Exams E  on
			--R.ImportID = E.RawData_Id
			--where E.Transaction_ID = @prev_Transactionid
			--and E.PartnerID = @PartnerID
			--and E.AppID  = @Appid 
			
			Update E
			set
			E.Import_Status  = 7
			from tbl_Import_Exams E 			
			where E.Transaction_ID = @prev_Transactionid
			and E.PartnerID = @PartnerID
			and E.AppID = @Appid 
print('spDeletePrevTransImportData-6 started'+CONVERT( VARCHAR(24), GETDATE(), 113));				
			
		End
		

END










