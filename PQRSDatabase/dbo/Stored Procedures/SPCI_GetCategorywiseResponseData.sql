-- =============================================
-- Author:		<Sumanth>
-- Create date: <07-dec-2018>
-- Description:	Get Category related response data
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_GetCategorywiseResponseData]
	-- Add the parameters for the stored procedure here
	@Tin varchar(9),
	@Npi varchar(10),
	@Cmsyear int,
	@CategotyId int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select top 1 res.Response_Data from tbl_CI_RequestData req  join tbl_CI_ResponseData res on req.Request_Id=res.Request_Id

where req.Tin=@Tin and req.Npi=@Npi and req.Category_Id=@CategotyId and res.Status='success' and res.Method_Id in(5,6)
and req.CmsYear=@Cmsyear
order by req.Request_Id desc
END

