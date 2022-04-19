-- =============================================
-- Author:		<Sumanth,,Raju>
-- Create date: <04-12-2018>
-- Description:	<used to get Delete measures filter data>
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_DeleteMeasureswithFilter]
	-- Add the parameters for the stored procedure here
	@Tin varchar(9)=null,
	@Npi varchar(10)=null,
	@Cmsyear varchar(4),
	@Type int
as
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	SET NOCOUNT ON;
if(@Type=1)
begin
	select [Key_Id]
      ,[Tin]
      ,[Npi]
      ,[Submission_Uniquekey_Id]
      ,[MeasurementSet_Unquekey_id]
      ,[Category_Id]
      ,[Response_Id]
      ,[IsMSetIdActive]
      ,[CmsYear] 
	  
	  from tbl_CI_Source_UniqueKeys where
Tin=ISNULL(@Tin,Tin) and 
isnull(Npi,'')=  isnull(@Npi,'')  and
CmsYear=ISNULL(@Cmsyear,CmsYear) and 
	IsMSetIdActive=1
end
else 
begin
select [Key_Id]
      ,[Tin]
      ,[Npi]
      ,[Submission_Uniquekey_Id]
      ,[MeasurementSet_Unquekey_id]
      ,[Category_Id]
      ,[Response_Id]
      ,[IsMSetIdActive]
      ,[CmsYear] from tbl_CI_Source_UniqueKeys where
Tin=ISNULL(@Tin,Tin) and 
Npi= ISNULL(@Npi,Npi)    
and
 ISNULL(Npi,'')<>'' and
CmsYear=ISNULL(@Cmsyear,CmsYear) and 
--isnull(CmsYear,'')=ISNULL(@Cmsyear,'') and 
	IsMSetIdActive=1
end
  
END
