-- =============================================
-- Author:		harikrishna J
-- Create date: June 4th,2019
-- Description:	remove duplicate users from tbl_user
--chage#1:hari J,on Aug2nd,2019
--chage#1: update dependent tables with MAX(UserID) before delteing the duplicate user records 
-- =============================================
CREATE PROCEDURE  [dbo].[spRemoveDuplicate_Users]
AS
BEGIN


declare @duplicateNPis table (NpisCount int,NPI varchar(50))
----find out duplicate records
insert into @duplicateNPis
select COUNT(*),NPI from tbl_Users where NPI is not null group by NPI having COUNT(*)>1


------baqckup duplicate records
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'tbl_Users_Duplicates_bak')
		 BEGIN
           drop table tbl_Users_Duplicates_bak
           END
select * into tbl_Users_Duplicates_bak from tbl_Users where NPI in( select NPI from @duplicateNPis)



declare @countNPI int
Declare @NPI varchar(50)
declare @maxUserID int
declare @error_msg varchar (max)


----cursur starts---------
declare curDuplicate cursor for
  select * from @duplicateNPis 
 OPEN curDuplicate  
	FETCH NEXT FROM curDuplicate INTO @countNPI,@NPI

WHILE @@FETCH_STATUS = 0  
BEGIN

BEGIN TRY
print('@NPI:m '+@NPI)

select @maxUserID=MAX(UserID) from tbl_Users where NPI=@NPI--findout latest userid

-------chage#1: starts
UPDATE ELMAH_Error SET [User]=@maxUserID where [user] in (select UserID from tbl_Users where NPI=@NPI and UserID !=@maxUserID)
UPDATE tbl_FacilityManaged_NPI_List SET UserId =@maxUserID where UserId in (select UserID from tbl_Users where NPI=@NPI and UserID !=@maxUserID)
UPDATE tbl_Invalid_Data_For_CMSXML SET UserId=@maxUserID where UserId in (select UserID from tbl_Users where NPI=@NPI and UserID !=@maxUserID)
UPDATE tbl_MultipleFileUpload_History SET UserId=@maxUserID where UserId in (select UserID from tbl_Users where NPI=@NPI and UserID !=@maxUserID)
UPDATE tbl_Physian_Tin_Count SET UserId=@maxUserID where UserId in (select UserID from tbl_Users where NPI=@NPI and UserID !=@maxUserID)
UPDATE tbl_Physician_TIN SET UserId=@maxUserID where UserId in (select UserID from tbl_Users where NPI=@NPI and UserID !=@maxUserID)
UPDATE tbl_PQRS_FILE_UPLOAD_HISTORY SET UserId=@maxUserID where UserId in (select UserID from tbl_Users where NPI=@NPI and UserID !=@maxUserID)
UPDATE tbl_Tin_Invalid_Data_For_CMSXML SET UserId=@maxUserID where UserId in (select UserID from tbl_Users where NPI=@NPI and UserID !=@maxUserID)
UPDATE tbl_User_Settings SET UserId=@maxUserID where UserId in (select UserID from tbl_Users where NPI=@NPI and UserID !=@maxUserID)
--UPDATE tbl_UserRoles SET UserId=@maxUserID where UserId in (select UserID from tbl_Users where NPI=@NPI and UserID !=@maxUserID)

------END

 
delete tbl_UserRoles where UserID in (select UserID from tbl_Users where NPI=@NPI and UserID !=@maxUserID) -- delete remaining userids from roles

delete from tbl_Users where NPI=@NPI and UserID !=@maxUserID -- delete remaining userids from tbl_Users


print('@@maxUserID:m '+convert ( varchar,@maxUserID))
END TRY

BEGIN CATCH
SET @error_msg = error_message()
print('Error Message '+@error_msg)
END CATCH

FETCH NEXT FROM curDuplicate INTO @countNPI,@NPI
End

CLOSE curDuplicate  
DEALLOCATE curDuplicate

END
