-- =============================================
-- Author:		Raju G
-- Create date:19 oct,2018
-- Description:	Get measurementset Unique Id 
-- =============================================
CREATE PROCEDURE [dbo].[SpCI_GetMeasurementSetKeyForPatch]
	
	@Tin varchar(9),
	@Npi varchar(10),
	@CmsYear int,
	@Category_Id int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	select  Sk.Submission_Uniquekey_Id, Sk.MeasurementSet_Unquekey_id
--select * from
from  tbl_CI_Source_UniqueKeys Sk 


where sk.Tin=@Tin
and ISNULL(sk.Npi,'')= case ISNULL(@Npi,'') when '' then '' else @Npi end 
 and sk.CmsYear=@CmsYear 
 and Sk.Category_Id=@Category_Id
 and sk.IsMSetIdActive=1
-- order by sk.[Key_Id] desc
END
