
-- =============================================
-- Author:		Sumanth Hari
-- Create date: 25 march 2015
-- Description:	used to get TIN/NPI Submission Status
-- =============================================
CREATE FUNCTION [dbo].[fnCI_GetLastSubmittedUser]
(
	-- Add the parameters for the function here
	@Tin varchar(9),
	@Npi varchar(10),
	@CmsYear int,
	@Category_Id int
)
RETURNS  varchar(100)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @LastSubmittedUser varchar(100)

	-- Add the T-SQL statements to compute the return value here

/*
select @LastSubmittedDate=res.CreatedDate from tbl_CI_RequestData req join tbl_CI_ResponseData res on
req.Request_Id=res.Request_Id join tbl_CI_Source_UniqueKeys keys on keys.Tin=req.Tin

where req.Tin=@Tin 

and ISNULL(req.Npi,'')= case ISNULL(@Npi,'') when '' then '' else @Npi end 
and req.Category_Id=@Category_Id
and res.Method_Id in(5,6,12)
and res.Status='success'
and keys.IsMSetIdActive=1
*/

select  @LastSubmittedUser = U.UserName from tbl_CI_Source_UniqueKeys C 
						join tbl_CI_ResponseData R on C.Response_Id = R.Respone_Id
						join tbl_Users U on u.UserID = R.CreatedBy
						where isnull(Tin,'') =isnull(@Tin,'')
							  and isnull(C.Npi,'') =isnull(@Npi,'')
							  and Category_Id =@Category_Id
							  and CmsYear=@CmsYear
							  and IsMSetIdActive=1
	-- Return the result of the function
	RETURN @LastSubmittedUser

END








