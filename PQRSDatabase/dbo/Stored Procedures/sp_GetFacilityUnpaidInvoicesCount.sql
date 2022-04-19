-- =============================================
-- Author:		Pavan
-- Create date: 10/29/2021
-- Description: Get unpaid Invoices list for given NPI under Given Facility
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetFacilityUnpaidInvoicesCount] 
	-- Add the parameters for the stored procedure here
	@UserName as varchar(250),
	@CMSYear int,
	@TIN varchar(10)
AS
BEGIN
	DECLARE @NPIPaymentData table(
	NPI varchar(10),
	InvoiceId int ,
	InvoicePaymentStatus varchar(10),
	CorporateID int
	)
	Declare @NPIofTins table( NPI Varchar(10))

	Insert into @NPIofTins
	select distinct NPI from NRDR..[PHYSICIAN_TIN_VW] where TIN=@tin and IS_ENROLLED= 1 and IS_ACTIVE= 1
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

	select count(*) from @NPIPaymentData where InvoicePaymentStatus ='Unpaid'
	select @@rowCount
END

