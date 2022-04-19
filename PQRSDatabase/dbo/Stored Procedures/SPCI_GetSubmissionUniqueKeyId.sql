-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_GetSubmissionUniqueKeyId] 
	-- Add the parameters for the stored procedure here
	@Tin varchar(9),
	@Npi varchar(10),
	@CmsYear int

AS
BEGIN
	select top 1  Sk.Submission_Uniquekey_Id
from  tbl_CI_Source_UniqueKeys Sk 
where sk.Tin=@Tin
and ISNULL(sk.Npi,'')= case ISNULL(@Npi,'') when '' then '' else @Npi end 
 and sk.CmsYear=@CmsYear 
 and sk.IsMSetIdActive=1
 order by Sk.[Key_Id] desc
END

