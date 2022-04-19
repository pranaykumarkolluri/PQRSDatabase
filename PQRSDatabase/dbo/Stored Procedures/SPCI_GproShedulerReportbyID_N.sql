-- =============================================
-- Author:		Hari & Sumanth
-- Create date: 13-November-2018
-- Description:	Get Details of Gpro response data
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_GproShedulerReportbyID_N]
	-- Add the parameters for the stored procedure here
	@Shedule_Requestid int,
	@isGpro bit
AS
BEGIN
if(@isGpro=1)
	begin
select rq.Tin,'' as Npi,rq.CmsYear,lk.Category_Name,res.Status_Code,res.Status,
it.MethodName,
res.NoofMeasures,
DATEDIFF(SECOND, res.Response_Start_Date ,res.[Response_End_Date]) AS SECONDSDiff from tbl_CI_Shedule_SubmitRequests sh 
inner join tbl_CI_BulkUpload_AvailableGPROTINs bk on sh.Shedule_Requestid=bk.Shedule_Requestid 
inner join tbl_CI_RequestData rq on rq.Request_Id=bk.Request_ID 
inner join tbl_CI_ResponseData res on res.Request_Id=rq.Request_Id 
inner join tbl_CI_lookup_Categories lk on lk.Category_Id=bk.Category_ID
inner join tbl_CI_lookup_Integration_Type it on it.Method_Id=res.Method_Id
where sh.Shedule_Requestid=@Shedule_Requestid

union  

select bk.Tin,'' as Npi,bk.CmsYear,lk.Category_Name,'0' as Status_Code, 'nojsondata' as Status,
'' as MethodName,
0 as NoofMeasures,
0 as SECONDSDiff from tbl_CI_Shedule_SubmitRequests sh 
inner join tbl_CI_BulkUpload_AvailableGPROTINs bk on sh.Shedule_Requestid=bk.Shedule_Requestid 
inner join tbl_CI_lookup_Categories lk on lk.Category_Id=bk.Category_ID
where sh.Shedule_Requestid=@Shedule_Requestid
and bk.Request_ID is null
end

else
begin

print 'TinNPI'

select rq.Tin,bk.NPI as Npi,rq.CmsYear,lk.Category_Name,res.Status_Code,res.Status,
it.MethodName,
res.NoofMeasures,
DATEDIFF(SECOND, res.Response_Start_Date ,res.[Response_End_Date]) AS SECONDSDiff from tbl_CI_Shedule_SubmitRequests_NPI sh 
inner join tbl_CI_BulkUpload_Available_TINNPIs bk on sh.SheduleNPI_Requestid=bk.Shedule_Requestid 
inner join tbl_CI_RequestData rq on rq.Request_Id=bk.Request_ID 
inner join tbl_CI_ResponseData res on res.Request_Id=rq.Request_Id 
inner join tbl_CI_lookup_Categories lk on lk.Category_Id=bk.Category_ID
inner join tbl_CI_lookup_Integration_Type it on it.Method_Id=res.Method_Id
where sh.SheduleNPI_Requestid=@Shedule_Requestid

union  

select bk.Tin,bk.NPI as Npi,bk.CmsYear,lk.Category_Name,'0' as Status_Code, 'nojsondata' as Status,
'' as MethodName,
0 as NoofMeasures,
0 as SECONDSDiff from tbl_CI_Shedule_SubmitRequests_NPI sh 
inner join tbl_CI_BulkUpload_Available_TINNPIs bk on sh.SheduleNPI_Requestid=bk.Shedule_Requestid 
inner join tbl_CI_lookup_Categories lk on lk.Category_Id=bk.Category_ID
where sh.SheduleNPI_Requestid=@Shedule_Requestid
and bk.Request_ID is null

end

END
