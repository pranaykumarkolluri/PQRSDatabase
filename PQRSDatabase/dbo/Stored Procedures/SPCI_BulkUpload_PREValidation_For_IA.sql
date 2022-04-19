
-- =============================================
-- Author:		Alane Pavan
-- Create date: Dec 12,2021
-- Description:	Used to validate bulk upload data for IA Selected Measuers and loaf errors in
--		'tbl_CI_BulkFileUploadCmsDataforIA'
-- =============================================
CREATE  PROCEDURE [dbo].[SPCI_BulkUpload_PREValidation_For_IA]
	@IsGPRO bit ,
	@FileId int 
AS
BEGIN

	Declare @CmsYear int
	DECLARE @FacilityUserName varchar(50);

	SELECT  @CmsYear = Submission_year from tbl_Lookup_Active_Submission_Year where IsActive = 1
	SELECT  @FacilityUserName=  UserName from tbl_Users where UserID=CONVERT(int,(select Createdby from tbl_CI_BulkFileUpload_History where FileId=@FileId))

	Declare @UserTINs table(TIN varchar(9), IsGPRO bit)
	insert into @UserTINs
	Exec sp_getFacilityTIN_GPRO @FacilityUserName

	DECLARE @NPIPaymentData table(
	NPI varchar(10),
	InvoiceId int ,
	InvoicePaymentStatus varchar(10),
	CorporateID int
	)
	DECLARE @UserTINNPIs table( TIN varchar(9), NPI varchar(10))

	insert into @UserTINNPIs 
	select distinct C.TIN, V.NPI from tbl_CI_BulkFileUploadCmsDataforIA C
	join NRDR..PHYSICIAN_TIN_VW V on C.TIN = V.TIN Collate DATABASE_DEFAULT
	where V.IS_ENROLLED = 1 and V.IS_ACTIVE = 1  AND FileId = @FileId --AND REGISTRY_NAME='MIPS'

	Declare @currentNPI varchar(10)
			
	Declare NPI_Cursor CURSOR FOR (select NPI from @UserTINNPIs)
		OPEN NPI_Cursor
			FETCH NEXT FROM NPI_Cursor INTO @currentNPI
			WHILE @@FETCH_STATUS = 0
			BEGIN
				insert into @NPIPaymentData
				exec [NRDR]..[sp_GetPhysicianInvoices] @FacilityUserName, @CMSYear, @currentNPI
				FETCH NEXT FROM NPI_Cursor INTO @currentNPI
			END
		CLOSE NPI_Cursor;
	DEALLOCATE NPI_Cursor;
	Declare @ErrorMessage varchar(5000)
	IF(@IsGPRO = 1 )
		BEGIN
			set @ErrorMessage = Case
					When @ErrorMessage IS NOT NULL THEN @ErrorMessage
					when ((select count(*) from tbl_CI_BulkFileUploadCmsDataforIA where TIN NOT IN ( Select TIN from @UserTINs where IsGPRO=@IsGPRO ) and FileId = @FileId ) > 0 )
					THEN 'Some of TINs not registered under MIPS for given facility' 
					ELSE NULL
					END
		END
	ELSE
		BEGIN
			Declare @Cur_TIN varchar(9)
			Declare @Cur_NPI varchar(10)
			DECLARE TIN_NPI_CURSOR CURSOR FOR (select distinct TIN ,NPI from tbl_CI_BulkFileUploadCmsDataforIA where FileId = @FileId)
			OPEN TIN_NPI_CURSOR
				FETCH NEXT FROM TIN_NPI_CURSOR INTO @Cur_TIN, @Cur_NPI
				WHILE @@FETCH_STATUS = 0
				BEGIN
				IF( @ErrorMessage IS NULL)
				BEGIN
					set @ErrorMessage = Case
						When @ErrorMessage IS NOT NULL THEN @ErrorMessage
						when ((select count(*) from @UserTINNPIs where TIN = @Cur_TIN and NPI = @Cur_NPI) = 0)
						THEN 'Some of TIN and NPIs not registered under MIPS for given facility' 
						ELSE NULL
						END
				END
					FETCH NEXT FROM TIN_NPI_CURSOR INTO @Cur_TIN, @Cur_NPI
				END
				CLOSE TIN_NPI_CURSOR;
			DEALLOCATE TIN_NPI_CURSOR;
		END
	IF(@ErrorMessage IS NULL)
	BEGIN
		set @ErrorMessage = Case
			when ((@IsGPRO = 1) AND (select count(*) from @NPIPaymentData where InvoicePaymentStatus ='Unpaid' ) > 0 )
			THEN 'Please Complete all Payment Invoices for NPIs under selected TINs before Submitting to CMS' 
			when ((@IsGPRO = 0) AND (select count(*) from @NPIPaymentData where InvoicePaymentStatus ='Unpaid' ) > 0 )
			THEN 'Please Complete all Payment Invoices for selected NPIs before Submitting to CMS' 					
			when (NOT EXISTS(select 1 from tbl_GPRO_TIN_EmailAddresses G join tbl_CI_BulkFileUploadCmsDataforIA A on A.TIN = G.GPROTIN and G.Tin_CMSAttestYear = A.CmsYear
					join tbl_CI_BulkFileUpload_History B on B.FileId = A.FileId 
					where  G.AttestedBy = B.CreatedBy and G.IsAttested = 1 and A.FileId = @FileId) )
			THEN 'Please Complete TIN Attestation before Submitting to CMS' 
			when ((select count(*) from tbl_GPRO_TIN_EmailAddresses G join tbl_CI_BulkFileUploadCmsDataforIA A on A.TIN = G.GPROTIN and G.Tin_CMSAttestYear = A.CmsYear
					join tbl_CI_BulkFileUpload_History B on B.FileId = A.FileId 
					where  G.AttestedBy = B.CreatedBy and G.IsAttested = 1 and A.FileId = @FileId) < (select distinct count(TIN) from tbl_CI_BulkFileUploadCmsDataforIA where Fileid = @FileId))
			THEN 'Please Complete TIN Attestation before Submitting to CMS' 
			When ((@IsGPRO = 1) AND ((select count(*) from tbl_CI_Lookup_OptinData D join tbl_CI_BulkFileUploadCmsDataforIA A on 
				A.TIN = D.TIN and D.NPI IS NULL and D.CmsYear = A.CmsYear where A.FileId = @FileId AND IsOptInEligible = 1 and IsOptedIn IS NULL and D.CmsYear = @CmsYear ) > 0 ) )
			THEN 'Please Complete Opt-In Selection for selected TINs before Submitting to CMS' 
			when
			((@IsGPRO = 0) AND (select count(*) from tbl_CI_Lookup_OptinData D join tbl_CI_BulkFileUploadCmsDataforIA A on 
				A.TIN = D.TIN and D.NPI = A.Npi and D.CmsYear = A.CmsYear where A.FileId = @FileId AND IsOptInEligible = 1 and IsOptedIn IS NULL  and D.CmsYear = @CmsYear ) > 0 ) 
			THEN 'Please Complete Opt-In Selection for selected TINs and NPIs before Submitting to CMS' 
			ELSE null

			END
	END
	update tbl_CI_BulkFileUpload_History set ErrorMessage = @ErrorMessage, Status = 24 where @ErrorMessage IS NOT NULL and FileId =@FileId
	update tbl_CI_BulkFileUpload_History set ErrorMessage = NULL, Status = 11 where @ErrorMessage IS NULL and FileId =@FileId

END