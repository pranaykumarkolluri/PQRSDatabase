-- =============================================
-- Author:		Raju G
-- Create date: May 27,2019
-- Description:	JIRA #704
-- =============================================
CREATE PROCEDURE [dbo].[spFileProcessHistoryDetails]
@SortColumn varchar(50)='StartDate',
@SortDirection varchar(5)='DESC',
    @StartDate dateTime =null,
    @EndDate datetime=null,
	@PageNo int=1,
	@PageLimit int=20,
	@CmsYear int=0,
	@ProcessType int=0,
	@Status int =0
AS
BEGIN

declare @skiprows int=0;
declare @username varchar(256);


set @skiprows = CASE WHEN  @PageNo >1 THEN (@PageNo-1) * @PageLimit ELSE 0 END 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
;With  ApiHistoryDetails AS
(
select  ISNULL(U.UserName,'NA') as Uname, Y.*,count(*) over()  as RequestsCount from  

tbl_ApiRequestFileProcessHistory  Y with(nolock) 
left join tbl_Users U on Y.CreatedBy =U.UserID  
--or Y.CreatedBy=-1


--Y with(nolock) 
--inner join tbl_Users U on Y.CreatedBy =U.UserID


where 
--StartDate =ISNULL(@StartDate,StartDate)
--and EndDate =ISNULL(@Enddate,endDate)
 Process_CnstID = CASE WHEN @ProcessType=0 THEN Process_CnstID ELSE @ProcessType END
and Status_CnstID =CASE WHEN @Status=0 THEN Status_CnstID ELSE @Status END
and Y.CMSYear=@CmsYear
 ORDER BY  
 Y.ReqId desc,
case
        when @SortDirection <> 'ASC' then cast(null as date)
        when @sortColumn = 'StartDate' then  Y.StartDate
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as date)
        when @sortColumn = 'StartDate' then Y.EndDate
        end DESC
		OFFSET @skiprows  ROWS
		FETCH NEXT @PageLimit ROWS ONLY
 
)
,ApiHistoryDetailsNew AS
(

select 
distinct
A.ReqId
,A.RequestsCount
, A.Notes
,A.StartDate
,A.EndDate
, case when (a.CreatedBy=-1 or a.CreatedBy=-2) then  (select ServiceName from tbl_FileService_Details where ServiceId=A.ServiceId)
else A.Uname end as Uname
,SUM( Case when F.STATUS='Successful' or f.STATUS='Successful With Warning' then 1 else 0 end)  over(Partition By B.ReqId) as Successfull_files
,SUM( Case when F.STATUS='Pending' then 1 else 0 end) over(Partition By B.ReqId) as Pending_files
,SUM( Case when F.STATUS='Rejected' then 1 else 0 end) over(Partition By B.ReqId) as Rejected_files 
,SUM( Case when F.STATUS='Processing' then 1 else 0 end) over(Partition By B.ReqId) as Processing_files
,Count(B.FileId) over(Partition By A.ReqId order by A.ReqId desc) as TotalFiles
 ,CASE WHEN A.Process_CnstID=1 THEN 'Check box API Processing'
  WHEN A.Process_CnstID=2 THEN 'URL API Processing'
  WHEN A.Process_CnstID=3 THEN 'Validate Single File Processing'
  WHEN A.Process_CnstID=4 THEN 'Re-Process'
   WHEN A.Process_CnstID=22 THEN 'Windows Service'
 End as ProcessType
,Case When A.Status_CnstID=5 then 'Start'
When A.Status_CnstID=6 then 'Stop'
When A.Status_CnstID=7 then 'Complete'
When A.Status_CnstID=8 then 'Reset'
When A.Status_CnstID=9 then 'Pending'
When A.Status_CnstID=10 then 'Processing'  end as Status


from ApiHistoryDetails A 
inner  join tbl_ApiRequstedFilesList B  with(nolock)
on A.ReqId=B.ReqId
inner join tbl_PQRS_FILE_UPLOAD_HISTORY F with(nolock)
 on B.FileId=F.ID


 )
 
 select * from ApiHistoryDetailsNew ReqId order by
 ReqId desc,
case
        when @SortDirection <> 'ASC' then cast(null as date)
        when @sortColumn = 'StartDate' then  StartDate
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as date)
        when @sortColumn = 'StartDate' then EndDate
        end DESC
END


