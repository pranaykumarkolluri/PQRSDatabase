-- =============================================
-- Author:		Hari J
-- Create date: May-3-2018
-- Description:	Check and merge single npi with multiple Records and returns NPI's USERID from tbl_USERS
-- =============================================
CREATE PROCEDURE [dbo].[SPMerge_Delete_NPI_tbl_Users](@NPI varchar(50))
	
AS
BEGIN

Declare @userID int=0
Declare @StatusMsg varchar(50)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	SET NOCOUNT ON;

--STEP #1 find no of NPI Matching records
IF ((select COUNT(*) from tbl_Users where NPI=@NPI)>1)

BEGIN
Print('more than one')
--STEP #2 find NRDRUserID=NPI record
IF ((select COUNT(*) from tbl_Users where NPI=@NPI and NRDRUserID=@NPI)>=1)
BEGIN
Print('NRDR UserID same as NPI')
-- Merging code
declare @Merge_Usertable as table(UserName varchar(50)
,NRDRUserID nvarchar(50)
,NPI Varchar(50)

)


insert into @Merge_Usertable
select top 1 UserName,NRDRUserID,NPI from tbl_Users where npi=@NPI
 and
  NRDRUserID !=@NPI 
  and (ISNULL(NRDRUserID ,'')<>'')


IF EXISTS (select * from @Merge_Usertable)
BEGIN


select @userID=UserID  from tbl_Users where NPI=@NPI and NRDRUserID=@NPI
update u
set u.UserName=m.UserName
,u.NRDRUserID=m.NRDRUserID
,u.Attested=1
,u.Last_Mod_Date=GETDATE()

from tbl_Users u inner join @Merge_Usertable m

on u.NPI=m.NPI

--PRINT(convert(varchar,@userID)+'  USER iDD')

delete from tbl_UserRoles where UserID in (
select UserID from tbl_Users where NPI=@NPI and UserID !=@userID

)

delete from tbl_Users where NPI=@NPI and UserID !=@userID

END
ELSE
BEGIN
select top 1 @userID=UserID from tbl_Users where NPI=@NPI
END


END

END

ELSE
BEGIN

--Print('only one record')

select top 1 @userID=UserID from tbl_Users where NPI=@NPI
END

--finally return values
select @userID as USERID

END
