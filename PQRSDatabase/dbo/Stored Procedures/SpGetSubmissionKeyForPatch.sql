-- =============================================
-- Author:		Raju G
-- Create date:19 oct,2018
-- Description:	Get Submission Unique Id 
-- =============================================
CREATE PROCEDURE [dbo].[SpGetSubmissionKeyForPatch]
	
	@Tin varchar(9),
	@CmsYear int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	select top 1  Sk.Submission_Uniquekey_Id as Submission_Uniquekey_Id
--select * from
from tbl_CI_RequestData Req inner join tbl_CI_ResponseData Res
on Req.Request_Id=Res.Request_Id inner join tbl_CI_Source_UniqueKeys Sk 
on Sk.Response_Id=Res.Respone_Id
where Req.Tin=@Tin
 and Req.CmsYear=@CmsYear 
 AND Req.CmsYear=SK.CmsYear
--and Res.Status_Id=2
 order by sk.[Key_Id] desc
END

