-- =============================================
-- Author:		Raju
-- Create date: 31 ,jan,2019
-- Description:Getting	GPRO Tins Cms Submision status details
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_TINCMSSubStatusReports_ACRStaff]
	-- Add the parameters for the stored procedure here
@CmsYear int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
--select  '12121212'as Tin ,'QM' as CategoryName, 2018 as CMSYear, 
--'Submitted' as  , 23 as NoofMeasures, GETDATE() as LastSubmittedDate,26.96 as TotalScore, 15.69 as CategoryScore


select R.Tin ,R.Category_Name as CategoryName ,R.CMSStatus as CmsStatus,
R.CMSYear,R.Category_Id,
 (
 select top 1 Response_End_Date from tbl_CI_ResponseData A
 inner join  tbl_CI_RequestData B on A.Request_Id=B.Request_Id
 where B.Tin=R.Tin and B.CMSYear=R.CMSYear and B.Category_Id=R.Category_Id 
  order by B.Request_Id desc 
 ) as LastSubmitedDate,
  (
 select top 1 NoofMeasures from tbl_CI_ResponseData A
 inner join  tbl_CI_RequestData B on A.Request_Id=B.Request_Id
 where B.Tin=R.Tin  and B.CMSYear=R.CMSYear and B.Category_Id=R.Category_Id
 order by B.Request_Id desc 
 ) as NoofMeasures

   from 
(
select distinct Rq.Tin,c.Category_Name,'Submitted'as CMSStatus,Rq.CmsYear  as CMSYear,Rq.Category_Id from tbl_CI_RequestData Rq 
inner join tbl_CI_ResponseData Rs on Rq.Request_Id =Rs.Request_Id 
inner join tbl_CI_lookup_Categories C on C.Category_Id=Rq.Category_Id
inner join tbl_TIN_GPRO gt on
  gt.TIN=rq.Tin
  inner join tbl_CI_Source_UniqueKeys K on K.Tin=Rq.Tin   and K.CmsYear=Rq.CmsYear
where Rs.Method_Id in (5,6) and gt.is_GPRO=1 and  K.IsMSetIdActive=1 
and  isnull(Rq.Npi,'')='' and Rq.CmsYear=@CmsYear
) 
as R


END
