create procedure GetFileDetails
@FileId int
as
begin
  select [FileName],CategoryId from tbl_CI_BulkFileUpload_History where FileId = @FileId
end