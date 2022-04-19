-- =============================================
-- Author:		Raju Gaddam
-- Create date: Feb 28, 2018
-- Description:	CMS TinLevel Attestation and Finalization Validation
-- =============================================
CREATE PROCEDURE [dbo].[spTinLevelIAFinalizationValidation]
	-- Add the parameters for the stored procedure here
@TIN varchar(10),
@CMSYear int


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
--Step #1 tin level attestation validation

		select case
		when (select COUNT(*) 
		from  tbl_GPRO_TIN_EmailAddresses where GPROTIN =@TIN 
		and Tin_CMSAttestYear=@CMSYear and IsAttested=1)=0 then 1


		--Step #2 Measure validation
		when (select count(*) from tbl_IA_Users where TIN=@TIN
		and CMSYear=@CMSYear ) =0 then 5
		else 0 end as  ValidationValue


	

END