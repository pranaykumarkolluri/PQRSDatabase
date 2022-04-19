CREATE Procedure [dbo].[Sp_SingleNPITINFiles]
@FileName varchar(256)
as
begin
if(@FileName ='All')
begin
select FILE_NAME,UPLOAD_START_DATE_TIME,Status,UserID,IsFile_Encrypted from tbl_PQRS_FILE_UPLOAD_HISTORY 

where npi is not null 
and
UPLOAD_START_DATE_TIME > 'mar 1 2017'

and status not like '%Rejected%'
and 
FILE_NAME not in (select FILE_NAME from tbl_MultipleFileUpload_History)
end
else
begin
select FILE_NAME,UPLOAD_START_DATE_TIME,Status,UserID,IsFile_Encrypted from tbl_PQRS_FILE_UPLOAD_HISTORY 

where npi is not null 
and
UPLOAD_START_DATE_TIME > 'mar 1 2017'

and status not like '%Rejected%' and FILE_NAME=@FileName
and 
FILE_NAME not in (select FILE_NAME from tbl_MultipleFileUpload_History)
end
end
