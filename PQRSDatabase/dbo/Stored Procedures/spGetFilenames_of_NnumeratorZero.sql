


-- =============================================
-- Author:		Raju G
-- Create date: sep-03-18
-- Description: Get files details from tbl_PQRS_FILE_UPLOAD_HISTORY to retrieve numrator responsive value as 0
-- =============================================
CREATE PROCEDURE [dbo].[spGetFilenames_of_NnumeratorZero]
@startdate datetime,
@enddate datetime,
@status varchar(100)
AS
BEGIN

insert into [tbl_Numerator_Zero_Files]
select 
    ID,
	[FILE_NAME] ,
	[STATUS] ,
	[Extension],	
	[IsFile_Encrypted],
	[Encryption_Type],
	
	@status ,
	[UPLOAD_START_DATE_TIME]
	,TOTAL_RECORDS_COUNT


 from tbl_PQRS_FILE_UPLOAD_HISTORY where UPLOAD_START_DATE_TIME between @startdate and @enddate and STATUS <> 'rejected'
  and ID not in (select distinct fileid from tbl_Numerator_Zero_Files)

 --from tbl_PQRS_FILE_UPLOAD_HISTORY where [ID] in (  select distinct [File_ID]  from tbl_Exam where   Exam_Id in
 
 --( select distinct  Exam_Id from tbl_Exam_Measure_Data where Numerator_response_value=0 and Created_Date  between @startdate and @enddate)  )

 select * from [tbl_Numerator_Zero_Files] where UPLOAD_START_DATE_TIME between @startdate and @enddate and  Load_Data_STATUS=@status order by FileId ASC
END
