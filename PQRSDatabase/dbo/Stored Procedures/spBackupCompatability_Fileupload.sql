CREATE PROCEDURE [dbo].[spBackupCompatability_Fileupload]
@year int 
AS
begin 

DECLARE @Fileid int
DECLARE @username varchar(50)
DECLARE @facilityid varchar(50)

DECLARE @FacilityidTbl table (facilityid varchar(50)  null) 

DECLARE Cur_fileupload CURSOR READ_ONLY FOR  

select B.UserName,A.ID from tbl_PQRS_FILE_UPLOAD_HISTORY A join  tbl_Users B WITH(NOLOCK)  on A.UserID = B.UserID
where  A.NPI is  null and B.UserName <> '' and B.UserName is not null  and year(A.UPLOAD_START_DATE_TIME)=@year
--may be not require
OPEN Cur_fileupload   
FETCH NEXT FROM Cur_fileupload INTO @username,@Fileid
WHILE @@FETCH_STATUS = 0   
BEGIN 
--select @username
delete from @FacilityidTbl
insert @FacilityidTbl exec NRDR..sp_getFacilityIDbyUsername @username
			--select * from @FacilityidTbl
		  if not exists (select top 1 FileId from tblFileAccessFacilityList where FileId=@Fileid)
		  begin
			insert  into tblFileAccessFacilityList(FileId,FacilityId)  select @Fileid, facilityid from @FacilityidTbl
		end

		FETCH NEXT FROM Cur_fileupload INTO @username,@Fileid
END   
CLOSE Cur_fileupload   
DEALLOCATE Cur_fileupload
end 

