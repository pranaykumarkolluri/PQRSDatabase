-- =============================================
-- Author:		Sumanth Hari
-- Create date: 25 march 2015
-- Description:	used to get TIN/NPI Submission Status
-- =============================================
CREATE FUNCTION [dbo].[fnCI_GetIsSubmittoCI]
(
	-- Add the parameters for the function here
	@Tin varchar(9),
	@Npi varchar(10),
	@CmsYear int,
	@Category_Id int
)
RETURNS  bit
AS
BEGIN
	-- Declare the return variable here
	DECLARE @isSubmittoCMS bit

	-- Add the T-SQL statements to compute the return value here
	 select @isSubmittoCMS=count(*) 
	 --Sk.Submission_Uniquekey_Id, Sk.MeasurementSet_Unquekey_id
--select * from
from  tbl_CI_Source_UniqueKeys Sk 


where sk.Tin=@Tin
and ISNULL(sk.Npi,'')= case ISNULL(@Npi,'') when '' then '' else @Npi end 
 and sk.CmsYear=@CmsYear 
 and Sk.Category_Id=@Category_Id
 and sk.IsMSetIdActive=1

	-- Return the result of the function
	RETURN @isSubmittoCMS

END

