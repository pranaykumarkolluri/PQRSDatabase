-- =============================================
-- Author:	Hari J
-- Create date: May 4th-2018
-- Description:	it is used to check, NPI exist or not
                  --  if not exists ,then retrive from nrdr and insert in tbl_user table

--exec   SPCheck_NPI_Exists 'eee',0

-- =============================================
CREATE PROCEDURE [dbo].[SPCheck_NPI_Exists](@NPI varchar(50),
@StatusCode int output

)

AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;
set @StatusCode=0--initial value
declare @userID int

 SET @NPI =  ISNULL(@NPI,'');
      SET @NPI=LTRIM(RTRIM(@NPI)) ;

 IF NOT EXISTS(select 1 from tbl_Users where LTRIM(RTRIM(NPI))=@NPI)
BEGIN
--print('NPI not exists')

DECLARE @Tbl_PhysianProfileForNPI TABLE

(

 NPI NVARCHAR(50) ,

 FirstName NVARCHAR(50) ,

 LastName NVARCHAR(50),
UserId varchar(100),
UserName varchar(50),
Email varchar(50)

)

insert into @Tbl_PhysianProfileForNPI

exec  NRDR..sp_getPhysianProfileForNPI @NPI

IF EXISTS(select 1 from @Tbl_PhysianProfileForNPI)
BEGIN
--print('npi  exists in nrdr')
set @StatusCode=1--- new record inserting in tbl_user
-- insert tbl_users tables


INSERT INTO [dbo].[tbl_Users]
  ([UserName]
  ,[FirstName]
  ,[LastName]
  ,[NPI]
  ,[EMail_Address]
  ,[Attested]
  --,[Status]
  ,[Created_Date]
  --,[Created_By]
  --,[Last_Mod_Date]
  --,[Last_Mod_By]
  --,[ProfileImage]
  ,[NRDRUserID]
  ,Notes)
select TOP 1 UserName
,FirstName
,LastName
,LTRIM(RTRIM(ISNULL(NPI,'')))
,Email
,1--[Attested]
,GETDATE()--[Created_Date]
,UserId--[NRDRUserID]
,'From SP'
from @Tbl_PhysianProfileForNPI



SELECT @userid=SCOPE_IDENTITY()
----insert in tbl_userroles


insert into tbl_UserRoles

select @userID,2
---inserting NPIs related TINs

--EXECUTE dbo.spGetLatestTINsOfNPI @strNPI = @NPI;

-----------------

END

ELSE
BEGIN
set @StatusCode=2--- no record found in NRDR
--print('npi not exists in nrdr')

END
END

ELSE
BEGIN
set @StatusCode=3--- NPI already exist in tbl_users
--print('npi already exists') -- return values
END


select @StatusCode as StatusCode

END

