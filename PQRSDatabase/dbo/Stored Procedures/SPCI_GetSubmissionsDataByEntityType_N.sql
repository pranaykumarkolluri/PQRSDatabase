-- =============================================
-- Author:		Raju G
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [SPCI_GetSubmissionsDataByEntityType_N] 
	@EntityType varchar(50)
AS
BEGIN
declare @RequestId uniqueidentifier;
select @RequestId= Submissions_Req_Id from tbl_CI_SubmissionRequestData  where isactive=1 and EntityType=@EntityType

select A.Tin,A.Npi, 
A.CmsYear,
B.Category,
A.EntityType, 
B.Measure_Name,
B.value 
from tbl_CI_Submissions_Data A inner join tbl_CI_Submissions_MSet_Data B 
on A.SubmissionUniqueKey=B.SubmissionUniqueKey
where A.Submissions_Req_Id=@RequestId
END
