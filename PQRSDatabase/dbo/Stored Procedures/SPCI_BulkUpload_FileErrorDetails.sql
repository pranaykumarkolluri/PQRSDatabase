-- =============================================
-- Author:		Pavan
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_BulkUpload_FileErrorDetails]
@CMSYear Int,
@FileId int,
@UserId int,
@UserRole int
AS
BEGIN
		--#Declaring variables
		Declare @ErrorMessage varchar(5000)
		Declare @IsGPRO bit
		DECLARE @FacilityUserName varchar(50)
		Declare @UserTINs table(TIN varchar(9), IsGPRO bit)
		DECLARE @UserTINNPIs table( TIN varchar(9), NPI varchar(10))
		Declare @currentNPI varchar(10)
		DECLARE @NPIPaymentData table(NPI varchar(10), InvoiceId int ,InvoicePaymentStatus varchar(10),CorporateID int)

		SELECT  @FacilityUserName=  UserName from tbl_Users where UserID=CONVERT(int,(select Createdby from tbl_CI_BulkFileUpload_History where FileId=@FileId))
		select @IsGPRO = IsGpro, @ErrorMessage = ErrorMessage from tbl_CI_BulkFileUpload_History where Fileid = @FileId

		--#step getting Facility TIn and NPI Data 
		insert into @UserTINs
		Exec sp_getFacilityTIN_GPRO @FacilityUserName

		insert into @UserTINNPIs 
		select distinct C.TIN, V.NPI from tbl_CI_BulkFileUploadCmsDataforIA C
		join NRDR..PHYSICIAN_TIN_VW V on C.TIN = V.TIN Collate DATABASE_DEFAULT
		where V.IS_ENROLLED = 1 and V.IS_ACTIVE = 1 AND FileId = @FileId

		--#Check for NPI Payment data
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
		--#Step Check for Error
		
		update B set b.ErrorMessage = CASE
							WHEN ((@IsGPRO = 1) AND (NOT EXISTS(select 1 from @UserTINs where TIN = B.TIN and IsGPRO = @IsGPRO)))
							THEN 'TIN not registered under MIPS for given facility'
							WHEN ((@IsGPRO = 0) AND (NOT EXISTS(select 1 from @UserTINNPIs where TIN = B.TIN AND NPI = B.Npi )))
							THEN 'TIN - NPI not registered under MIPS for given facility'
							when EXISTS(select 1 from @UserTINNPIs where TIN = B.TIN and NPI IN (select NPI from @NPIPaymentData where InvoicePaymentStatus = 'Unpaid'))
							THEN 'Complete payments invoice for all NPI under selected TIN'
							when (NOT EXISTS(select 1 from tbl_GPRO_TIN_EmailAddresses G  
									join tbl_CI_BulkFileUpload_History A on A.CreatedBy = G.CreatedBy and A.CmsYear= G.Tin_CMSAttestYear
									where  G.GPROTIN = B.TIN and A.FileId = B.FileId and G.IsAttested = 1 ) )
							THEN 'TIN Attestation is not done for the following TIN'
							WHEN ((@IsGPRO = 1) AND ( select count(*) from tbl_CI_Lookup_OptinData where TIN = B.TIN AND NPI IS NULL AND IsOptInEligible = 1  and IsOptedIn IS NULL and CmsYear = @CMSYear) > 0 )
							THEN 'Opt-In Decision is not made for the given TIN'
							WHEN ((@IsGPRO = 0) AND ( select count(*) from tbl_CI_Lookup_OptinData where TIN = B.TIN AND NPI = B.Npi AND IsOptInEligible = 1  and IsOptedIn IS NULL and CmsYear = @CMSYear) > 0 )
							THEN 'Opt-In Decision is not made for the given TIN - NPI'
							--WHEN @ErrorMessage IS NOT NULL THEN @ErrorMessage
						ELSE NULL END --as ErrorMEssage
			from tbl_CI_BulkFileUploadCmsDataforIA B 
				where FileId = @FileId --and ErrorMessage is NOT NULL

		select distinct TIN,
						Npi,
						ErrorMessage
				from tbl_CI_BulkFileUploadCmsDataforIA where FileId = @FileId and ErrorMessage is NOT NULL
	select @ErrorMessage = ErrorMessage from tbl_CI_BulkFileUpload_History where Fileid = @FileId
END
