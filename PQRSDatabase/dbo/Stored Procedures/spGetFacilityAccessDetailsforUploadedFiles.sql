

-- =============================================
-- Author:        Prashanth kumar Garlapally
-- Create date: 23 Nov 2017
-- Description:    Used to get Access properties for passed FacilityUser for files uploade over a date range updated 
--          with filters for atleast 1  NPI and atleast 1 TIN  of facility must be in the file to view statistics
--Change #1: Hari on 05-07-2018
--Change #1: For JIRA#566
--Change#2:Raju G Desp: Everytime fetching limit records for file upload(Pagination)
--Change Desc: JIRA-692 file upload performance issue
--Change By: HARI and RAJU
--Change Date: april,29
--Change#3:Desp: Filename filter added


--Change By: HARI and RAJU
--Change Date: Aug,09,2019  
--Change#4: Jira# 718 

--Change By: RAJU
--Change Date: Jan,16,2020  
--Change#5:  https://stackoverflow.com/questions/6585417/stored-procedure-slow-when-called-from-web-fast-from-management-studio   

--Change#6 : By Pavan JIRA#1125
--Change#7 : By Pavan JIRA#1120
-- =============================================
CREATE PROCEDURE [dbo].[spGetFacilityAccessDetailsforUploadedFiles]
    -- Add the parameters for the stored procedure here
  @FacilityUserName varchar(50),
  @StartDate datetime =  null,
    @EndDate datetime=null,
    @FacilityUserId as int = 0,
  	@SearchStatus varchar(100)='All',
	@PageNo int=1,
	@PageLimit int=5000,
	@ISASC bit=0,
	@SortColumn varchar(50)='UPLOAD_END_DATE_TIME',
	@SortDirection varchar(5)='DESC',
	@Filename varchar(100)=null,
	@TIN varchar(9) = null, --Change#5
	@SubmitterName varchar(500) = null --Change#6
	    --Change#3 
AS
BEGIN               ---Change#4
    Declare   @_FacilityUserName varchar(50);
    Declare   @_StartDate datetime;
	Declare   @_EndDate datetime ;
	Declare   @_FacilityUserId int;
	Declare   @_SearchStatus  varchar(100);
	Declare   @_PageNo int;
	Declare   @_PageLimit int;
	Declare   @_ISASC bit;
	Declare   @_SortColumn varchar(50);
	Declare   @_SortDirection varchar(5);
	Declare   @_Filename varchar(100);
	Declare	  @_TIN varchar(9); --Change#5
	Declare @_SubmitterName varchar(500);  --Change#6

	  SET @_FacilityUserName = @FacilityUserName;
	  SET @_StartDate=@StartDate;
	  SET @_EndDate =@EndDate;
	  SET @_FacilityUserId=@FacilityUserId;
	  SET @_SearchStatus =@SearchStatus;
	  SET @_PageNo =@PageNo;
	  SET @_PageLimit=@PageLimit;
	  SET @_ISASC =@ISASC;
	  SET @_SortColumn =@SortColumn;
	  SET @_SortDirection =@SortDirection;
	  SET @_Filename =@Filename;
	  SET @_TIN = @TIN;  --Change#5
	  SET @_SubmitterName = @SubmitterName;  --Change#6


--set @StartDate = Case when @StartDate is null then DATEADD(month,-8,getdate()) else @StartDate end;
--set @EndDate = Case when @EndDate  is null then GETDATE() else @EndDate end;


declare @SortingColname varchar(100)='UPLOAD_END_DATE_TIME';        --Change#4
 set	@_SortColumn= @SortingColname;          
declare @FacilityFiles table (FileId int,[FileName] varchar(256),Access bit);
declare @FacilityTINs table ( TINs varchar(10))
declare @FacilityIDs table(FacilityID int);
declare @FacilityPhysicianNPISTINS table(	
first_name varchar(256),
last_name varchar(256),
npi varchar(10),
tin varchar(9),
is_active bit, 
deactivation_date datetime,
is_enrolled bit
)
declare @skiprows int=0;
declare @FacilityNpis table(Npi varchar(10));

set @skiprows = CASE WHEN  @_PageNo >1 THEN (@_PageNo-1) * @_PageLimit ELSE 0 END 
--Step#1  Get user facility ids  list from NRDR.
print '--Step#1 Get user facility ids list from NRDR.'
print getdate()
insert into @FacilityIDs
exec nrdr.[dbo].[sp_getFacilityIDbyUsername] @UserName = @_FacilityUserName

--Step#2  Get user facility tin list from NRDR.
print '--Step#2 Get user facility tin list from NRDR.'
print getdate()
insert into @FacilityTINs
exec [dbo].[sp_getFacilityTIN] @_FacilityUserName

--Step#3  Get user facility TIN/NPIS from NRDR.
print '--Step#3  Get user facility TIN/NPIS from NRDR.'
print getdate()
insert into @FacilityPhysicianNPISTINS
exec sp_getFacilityPhysicianNPIsTINs @_FacilityUserName

--Step#4  Get user facility NPIS 
print '--Step#4  Get user facility NPIS '
print getdate()
insert into @FacilityNpis
select distinct npi from @FacilityPhysicianNPISTINS


 if @_FacilityUserId < 1
 begin
  select @_FacilityUserId=UserID  from tbl_Users readonly with(Nolock) where UserName = @_FacilityUserName
 End
 
 --Step#5:
print (' --Step#5: ')
print getdate()
;With  UserFileAccessList AS
(
-- no need to check any file access conditions for upload user.
select  ID, 1 as access from tbl_PQRS_FILE_UPLOAD_HISTORY with(Nolock) where UserID = @_FacilityUserId
UNION
--get physician upload files  
(select DISTINCT p.ID,null from tbl_PQRS_FILE_UPLOAD_HISTORY  p with(Nolock)
inner join @FacilityNpis f on p.Npi= f.Npi and p.UserID <> @_FacilityUserId
inner join tblFileAccessFacilityList a on p.ID=a.FileId 
inner join @FacilityIDs fid on fid.FacilityID=a.FacilityId
)
UNION
--Facility 2 can view the record  uploaded by Facility 1 only if,  both the facilities contains Common Facility Id, atleast one common TIN and atleast one common NPI in the uploaded file
--(select  DISTINCT A.ID,null as access from tblFileAccessFacilityList F with(Nolock) inner join  @FacilityIDs I on F.FacilityId=I.FacilityID  inner join tbl_PQRS_FILE_UPLOAD_HISTORY  A 
--on f.FileId=A.ID  and A.UserID <> @FacilityUserId 

(select  DISTINCT A.ID,null as access from tbl_PQRS_FILE_UPLOAD_HISTORY  A with(Nolock)  inner join tblFileAccessFacilityList F with(Nolock) on A.ID=F.FileId 
and A.UserID <> @_FacilityUserId   inner join   @FacilityIDs I on F.FacilityId=I.FacilityID  
--on f.FileId=A.ID  and A.UserID <> @FacilityUserId 
INTERSECT
select DISTINCT M.FileId, null as access from tbl_MultipleFileUpload_History M with(Nolock) inner join @FacilityTINs T on M.TIN=T.TINs and m.UserID <> @_FacilityUserId
INTERSECT
select DISTINCT M.FileId,null as access from tbl_MultipleFileUpload_History M with(Nolock) inner join @FacilityNpis T on M.NPI=T.npi and m.UserID <> @_FacilityUserId) --9sec
)
,  UserFileAccessListNew AS
(
select  p.[FILE_NAME],p.[UPLOAD_START_DATE_TIME]
      ,p.[UPLOAD_END_DATE_TIME]
      ,ISNULL(p.[ERROR_MESSAGE],'') as [ERROR_MESSAGE]
      ,ISNULL(p.[TOTAL_RECORDS_COUNT],0) as [TOTAL_RECORDS_COUNT]
      ,p.[STATUS]
      ,p.[NPI]
      ,p.[Load_Start_Time]
      ,p.[Load_End_Time]
      ,ISNULL(p.[Invalid_Records_Count],0) as [Invalid_Records_Count]
      ,ISNULL(p.[Updated_Records_Count],0) as [Updated_Records_Count]
      ,ISNULL(p.[Added_Records_Count],0) as [Added_Records_Count]
	 ,ISNULL(p.Added_Records_WithWarning_Count,0) as Added_Records_WithWarning_Count
	 ,ISNULL(p.Updated_Records_WithWarning_Count,0) as Updated_Records_WithWarning_Count
      ,ISNULL(p.Invalid_Records_WithExclusion_Count,0) as Invalid_Records_WithExclusion_Count
      ,p.[ID]
      ,p.[UserID]
	  ,B.access
	  ,U.UserName,
	   count(*) over()  as FilesCount from tbl_PQRS_FILE_UPLOAD_HISTORY p with(Nolock) inner join UserFileAccessList B 

on p.ID=B.ID 
		INNER JOIN tbl_PQRS_FileUpload_TINData D on D.FileId = p.ID
		Inner JOIN tbl_Users U on U.UserID = p.UserID 
and p.UPLOAD_START_DATE_TIME >= (CASE WHEN  @_StartDate IS NULL THEN P.UPLOAD_START_DATE_TIME ELSE @_StartDate END)
and p.UPLOAD_END_DATE_TIME <= (CASE WHEN @_EndDate IS NULL THEN P.UPLOAD_END_DATE_TIME ELSE @_EndDate END)
and( p.STATUS=@_SearchStatus or @_SearchStatus is null or @_SearchStatus ='All')
and p.FILE_NAME like '%'+(CASE WHEN @_Filename IS NULL THEN P.FILE_NAME ELSE @_Filename END)+'%'  --Change#3
and u.UserName like '%'+(CASE WHEN @_SubmitterName IS NULL THEN u.UserName ELSE @_SubmitterName END)+'%'  --Change#7
and (D.TIN like '%'+ ( CASE WHEN @_TIN IS NULL THEN D.TIN ELSE @_TIN END)+'%' ) --Change#6
 ORDER BY  
case
        when @_SortDirection <> 'ASC' then cast(null as date)
        when @_sortColumn = @SortingColname then p.UPLOAD_END_DATE_TIME         --Change#4:
        end ASC,
		case
        when @_SortDirection <> 'DESC' then cast(null as date)
        when @_sortColumn = @SortingColname then p.UPLOAD_END_DATE_TIME          --Change#4:
        end DESC,
case
        when @_SortDirection <> 'ASC' then cast(null as varchar)
        when @_sortColumn = @SortingColname then u.UserName         --Change#7:
        end ASC,
		case
        when @_SortDirection <> 'DESC' then cast(null as varchar)
        when @_sortColumn = @SortingColname then u.UserName          --Change#7:
        end DESC

 OFFSET @skiprows  ROWS
 FETCH NEXT @_PageLimit ROWS ONLY
 )

 select 
       p.[FILE_NAME],
	  p.[UPLOAD_START_DATE_TIME]
      ,p.[UPLOAD_END_DATE_TIME]
      ,p.[ERROR_MESSAGE]
      ,p.[TOTAL_RECORDS_COUNT]
      ,p.[STATUS]
      ,p.[NPI]
      ,p.[Load_Start_Time]
      ,p.[Load_End_Time]
      ,p.[Invalid_Records_Count]
      , p.[Updated_Records_Count]
      ,p.[Added_Records_Count]
	  ,p.Added_Records_WithWarning_Count
	   ,p.Updated_Records_WithWarning_Count
       , p.Invalid_Records_WithExclusion_Count
      ,p.[ID]
      ,p.[UserID]
	  ,p.UserName
	  --Facility 2 can have the permissions(i.e to download data file/log file) for the record only if, all  the NPI’s and TIN’s in the uploaded file are common for both facilities
	  ,ISNULL( Cast( CASE When p.access=1 Then 1 
			when exists( select 1 from tbl_MultipleFileUpload_History m  with(nolock) where  m.TIN not in ( select distinct tins from @FacilityTINs) and m.FileId =  p.ID and m.UserID <> @_FacilityUserId )  then 0
			when exists( select 1 from tbl_MultipleFileUpload_History m  with(nolock) where m.NPI not in ( select distinct npi from @FacilityNpis) and m.FileId =  p.ID and m.UserID <> @_FacilityUserId ) then 0		
			else 1 
			end as bit ),0) as Access
	  ,p.FilesCount

 from UserFileAccessListNew  p

 print ('--end')
print getdate()
END


