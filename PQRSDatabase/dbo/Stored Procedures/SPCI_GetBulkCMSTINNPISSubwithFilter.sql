-- =============================================
-- Author:		<Sumanth>
-- Create date: <MAR ,7TH,2019>
-- Description:	<used to get BULK TIN/TINNPIS FOR SUBMIT TO CMS filter data>
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_GetBulkCMSTINNPISSubwithFilter]
	-- Add the parameters for the stored procedure here
	@Tin varchar(9)=null,
	@Npi varchar(10)=null,
	@Cmsyear int,
	@IsSubmittoCMS bit=0,
	@Category_Id int=0,--0 means all
	@Type int
as
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	--SET NOCOUNT ON;

if(@Type=1)
begin
	select k.Bulk_ID
      ,k.[Tin]
      ,k.[Npi]
      ,k.[Category_Id] 
	  ,(select c.Category_Name  from tbl_CI_lookup_Categories c where c.Category_Id=k.Category_Id) as Category_Name  
      ,k.[CmsYear] 
	  ,k.IsSubmittoCMS
	  ,k.CMSStatus	  
	  from tbl_CI_BulkTINNPI_CMSSubmission k where
k.Tin=ISNULL(@Tin,k.Tin) and 
isnull(k.Npi,'')=  isnull(@Npi,'')  and
k.CmsYear=ISNULL(@Cmsyear,k.CmsYear)  
AND	k.IsSubmittoCMS=@IsSubmittoCMS
AND K.Category_ID= CASE WHEN @Category_Id=0 THEN K.Category_ID
                   ELSE @Category_Id END 
end
else 
begin
select k.Bulk_ID
      ,k.[Tin]
      ,k.[Npi]
      ,k.[Category_Id] 
	  ,(select c.Category_Name  from tbl_CI_lookup_Categories c where c.Category_Id=k.Category_Id) as Category_Name  
      ,k.[CmsYear] 
	  ,k.IsSubmittoCMS
	  ,k.CMSStatus	  
	  from tbl_CI_BulkTINNPI_CMSSubmission k where
k.Tin=ISNULL(@Tin,k.Tin) and 
k.Npi= ISNULL(@Npi,k.Npi)    
and
 ISNULL(k.Npi,'')<>'' and
k.CmsYear=ISNULL(@Cmsyear,k.CmsYear)  
--isnull(CmsYear,'')=ISNULL(@Cmsyear,'') and 
AND	k.IsSubmittoCMS=@IsSubmittoCMS
AND K.Category_ID= CASE WHEN @Category_Id=0 THEN K.Category_ID
                   ELSE @Category_Id END
end
  
END

