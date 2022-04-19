

-- =============================================
-- Author:		harikrishna j
-- Create date: NOV 16th ,2018
-- Description:	this is return status of tin or NPI
-- =============================================
CREATE FUNCTION [dbo].[FnCI_GetSubmissionStatusofTINNPI]
(
	-- Add the parameters for the function here
	@Submission_Uniquekey_Id varchar(100)
)
RETURNS VARCHAR(100)
AS
BEGIN
	
DECLARE @SUBSTATUS varchar(100)
 DECLARE @COUNTID int
  DECLARE @SUMID int

   SELECT @COUNTID=ISNULL(COUNT(*),0),@SUMID=ISNULL(SUM(Category_Id),0) from tbl_CI_lookup_Categories where Category_Id not in ((select Category_Id from tbl_CI_Source_UniqueKeys 
 where IsMSetIdActive=1 and Submission_Uniquekey_Id=@Submission_Uniquekey_Id)) and Category_Id NOT IN (4,5)

 --SELECT @COUNTID,@SUMID


SELECT @SUBSTATUS=(

Case  
WHEN  @COUNTID=0 and @SUMID=0 THEN  'Completed'
 WHEN  @COUNTID=1 and @SUMID=1 THEN  'QM Not Yet Submitted'
WHEN  @COUNTID=1 and @SUMID=2 THEN  'IA Not Yet Submitted'
WHEN  @COUNTID=1 and @SUMID=3 THEN  'PI Not Yet Submitted'
 WHEN  @COUNTID=2 and @SUMID=3 THEN  'QM IA Not Yet Submitted'

WHEN  @COUNTID=2 and @SUMID=4 THEN  'QM PI Not Yet Submitted'
WHEN  @COUNTID=2 and @SUMID=5 THEN  'IA PI Not Yet Submitted'
WHEN  @COUNTID=3 and @SUMID=6 THEN  'Not Yet Submitted'
ELSE 'Not Yet Submitted'

END)
RETURN @SUBSTATUS
END





