-- =============================================
-- Author:		Pavan
-- Create date: 10/29/2021
-- Description: Get unpaid Invoices list for given NPI under Given Facility
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetFacilityInvoices] 
	-- Add the parameters for the stored procedure here
	@UserName as varchar(250),
	@CMSYear int,
	@TIN varchar(10),
	@IsGpro bit
AS
BEGIN
/*	DECLARE @NPIPaymentData table(
	NPI varchar(10),
	InvoiceId int ,
	InvoicePaymentStatus varchar(10),
	CorporateID int
	)
	Declare @NPIofTins table( NPI Varchar(10),TIN varchar(10))

	Declare @FacilityUserTins table(TIN varchar(10), Is_Gpro bit)
	
	if(@TIN IS NULL)
		BEGIN
			insert into @FacilityUserTins
			Exec sp_getFacilityTIN_GPRO @UserName
			Insert into @NPIofTins
			select distinct NPI,V.TIN from NRDR..[PHYSICIAN_TIN_VW] v join @FacilityUserTins F on  V.TIN=F.TIN Collate DATABASE_DEFAULT where IS_ENROLLED= 1 and IS_ACTIVE= 1 and F.Is_Gpro = @IsGpro
		END
	ELSE
		BEGIN
			Insert into @NPIofTins
			select distinct NPI,@TIN from NRDR..[PHYSICIAN_TIN_VW] where TIN=@TIN and IS_ENROLLED= 1 and IS_ACTIVE= 1
		END

	Declare @currentNPI varchar(10)

	Declare NPI_Cursor CURSOR FOR (select NPI from @NPIofTins)
		OPEN NPI_Cursor
			FETCH NEXT FROM NPI_Cursor INTO @currentNPI
			WHILE @@FETCH_STATUS = 0
			BEGIN
				insert into @NPIPaymentData
				exec [NRDR]..[sp_GetPhysicianInvoices] @CMSYear, @currentNPI
				FETCH NEXT FROM NPI_Cursor INTO @currentNPI
			END
		CLOSE NPI_Cursor;
	DEALLOCATE NPI_Cursor;

	select distinct InvoiceId,CorporateID,P.NPI,TIN from @NPIPaymentData P join @NPIofTins T on T.NPI = P.NPI where InvoicePaymentStatus ='Unpaid'
*/
	Exec NRDR ..[sp_GetFacilityInvoices] @CMSYear,@TIN,@UserName,@IsGpro
END

