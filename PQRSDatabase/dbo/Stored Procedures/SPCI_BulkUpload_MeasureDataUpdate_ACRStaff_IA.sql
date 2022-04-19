
-- =============================================
-- Author:		Alane Pavan
-- Create date: Dec 12,2021
-- Description:	Used to validate bulk upload data for IA Selected Measuers and loaf errors in
--		'tbl_CI_BulkFileUploadCmsDataforIA'
-- =============================================
CREATE  PROCEDURE [dbo].[SPCI_BulkUpload_MeasureDataUpdate_ACRStaff_IA]
	@IsGPORO bit ,
	@FileId int

AS
BEGIN
	Declare @UserTinNpis table(TIN varchar(10), NPI varchar(9));

	insert into @UserTinNpis
	select TIN,NPI from tbl_CI_BulkFileUploadCmsDataforIA C
	join tbl_CI_BulkFileUpload_History H on H.FileId = C.FileId
	where H.FileId = @FileId and H.Status = 11

	select * from @UserTinNpis

END