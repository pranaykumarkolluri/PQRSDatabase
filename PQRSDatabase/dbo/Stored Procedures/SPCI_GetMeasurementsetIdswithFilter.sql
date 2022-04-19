-- =============================================
-- Author:		<Sumanth,,Raju>
-- Create date: <04-12-2018>
-- Description:	<used to get Delete measures filter data>
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_GetMeasurementsetIdswithFilter]
	-- Add the parameters for the stored procedure here
	@Tin varchar(9)=null,
	@Npi varchar(10)=null,
	@Cmsyear int=0,
	@Type int
as
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	--SET NOCOUNT ON;
if(@Type=1)
begin
	select k.[Key_Id]
      ,k.[Tin]
      ,k.[Npi]
      ,k.[Submission_Uniquekey_Id]
      ,k.[MeasurementSet_Unquekey_id]
      ,k.[Category_Id] 
	  ,(select c.Category_Name  from tbl_CI_lookup_Categories c where c.Category_Id=k.Category_Id) as Category_Name  
      ,k.[CmsYear] from tbl_CI_Source_UniqueKeys k where
k.Tin=ISNULL(@Tin,k.Tin) and 
isnull(k.Npi,'')=  isnull(@Npi,'')  and
k.CmsYear=ISNULL(@Cmsyear,k.CmsYear) and 
	k.IsMSetIdActive=1
end
else 
begin
select k.[Key_Id]
      ,k.[Tin]
      ,k.[Npi]
      ,k.[Submission_Uniquekey_Id]
      ,k.[MeasurementSet_Unquekey_id]
      ,k.[Category_Id] 
	  ,(select c.Category_Name  from tbl_CI_lookup_Categories c where c.Category_Id=k.Category_Id) as Category_Name  
      ,k.[CmsYear] from tbl_CI_Source_UniqueKeys k where
k.Tin=ISNULL(@Tin,k.Tin) and 
k.Npi= ISNULL(@Npi,k.Npi)    
and
 ISNULL(k.Npi,'')<>'' and
k.CmsYear=ISNULL(@Cmsyear,k.CmsYear) and 
--isnull(CmsYear,'')=ISNULL(@Cmsyear,'') and 
	k.IsMSetIdActive=1
end
  
END
