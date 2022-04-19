-- =============================================
-- Author:		Raju G
-- Create date:19 oct,2018
-- Description: Is Tin submitted to cms or not and Last Submitted date
-- =============================================
CREATE PROCEDURE [dbo].[SpCI_GetIsSubmittoCMSAndSubmittedDate]
	
	@Tin varchar(9),
	@Npi varchar(10),
	@CmsYear int,
	@Category_Id int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	declare @isSubmittoCMS bit
	declare @LastSubmittedDate varchar(50)
	 select @isSubmittoCMS=count(*) 
	 --Sk.Submission_Uniquekey_Id, Sk.MeasurementSet_Unquekey_id
--select * from
from  tbl_CI_Source_UniqueKeys Sk 


where sk.Tin=@Tin
and ISNULL(sk.Npi,'')= case ISNULL(@Npi,'') when '' then '' else @Npi end 
 and sk.CmsYear=@CmsYear 
 and Sk.Category_Id=@Category_Id
 and sk.IsMSetIdActive=1
-- order by sk.[Key_Id] desc

select @LastSubmittedDate=res.CreatedDate from tbl_CI_RequestData req join tbl_CI_ResponseData res on
req.Request_Id=res.Request_Id join tbl_CI_Source_UniqueKeys keys on keys.Tin=req.Tin 
and req.CmsYear=keys.CmsYear
and req.Category_Id=keys.Category_Id

where req.Tin=@Tin 

and ISNULL(req.Npi,'')= case ISNULL(@Npi,'') when '' then '' else @Npi end 
and req.Category_Id=@Category_Id
and res.Method_Id in(5,6)
and res.Status='success'
and keys.IsMSetIdActive=1
and req.CmsYear=@CmsYear

select @isSubmittoCMS as isSubmittedtoCMS,@LastSubmittedDate as LastSubmittedDate


END

