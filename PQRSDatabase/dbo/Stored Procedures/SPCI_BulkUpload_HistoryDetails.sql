-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_BulkUpload_HistoryDetails]
	-- Add the parameters for the stored procedure here
@CmsYear int,
@CategoryId int =1,
@Status int =0
AS
BEGIN
select 
u.username as CreatedBy,
A.FileName,

CASE 
WHEN  A.StatUS=7 AND A.IsPartallyCMSSumitted =1 THEN 'CMS Submission Partially Successful'
WHEN A.Status=7 AND A.IsPartallyCMSSumitted =1 THEN 'CMS Submission Successful'
ELSE  c.Description END AS STATUS,

CASE WHEN  A.CategoryId=1 THEN 'QM'
WHEN  A.CategoryId=2 THEN 'IA'
WHEN  A.CategoryId=3 THEN 'PI'
END AS CategoryId ,

B.NoofFailureSubmissions,
B.NoofSuccessSubmissions,
B.NoofSubmissions,
A.CreatedDate,
A.CompleteDate 
from tbl_CI_BulkFileUpload_History A  
INNER JOIN  tbl_Lookup_MIPS_Constants C ON  A.Status=C.Cnst_ID
INNER JOIN tbl_Users U ON U.USERID=CONVERT(int,a.CreatedBy)
			  LEFT JOIN tbl_CI_BulkUpload_FilesRequestDetails B
						 ON A.FileId=B.FileId AND B.IsLatest=1
              
END
