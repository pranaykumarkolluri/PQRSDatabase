-- =============================================
-- Author:		Pavan
-- Create date: 10/29/2021
-- Description: Get unpaid Invoices list for given NPI
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetPhysicianInvoices] 
	-- Add the parameters for the stored procedure here
	@UserName as varchar(250),
	@NPI varchar(10),
	@CMSYear int
AS
BEGIN
	DECLARE @NPIPaymentData table(
	NPI varchar(10),
	InvoiceId int ,
	InvoicePaymentStatus varchar(10),
	CorporateID int
	)
	insert into @NPIPaymentData
	exec [NRDR]..[sp_GetPhysicianInvoices] @UserName, @CMSYear, @NPI
	select InvoiceId,CorporateID from @NPIPaymentData where InvoicePaymentStatus ='Unpaid'
END

