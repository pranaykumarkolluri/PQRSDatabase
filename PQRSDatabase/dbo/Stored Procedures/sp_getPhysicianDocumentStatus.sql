
create PROCEDURE [dbo].[sp_getPhysicianDocumentStatus]   
	@NPI nvarchar(10),
	@TIN nvarchar(9),
	@CMSReportingYear int
AS
BEGIN

exec NRDR..sp_getPhysicianDocumentStatus @NPI,@TIN,@CMSReportingYear

END

