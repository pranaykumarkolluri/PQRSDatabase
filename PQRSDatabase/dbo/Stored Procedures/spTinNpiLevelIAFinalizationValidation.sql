

-- =============================================
-- Author:		Raju Gaddam
-- Create date: Feb 28, 2018
-- Description:	CMS TinLevel Attestation and Finalization Validation
-- =============================================
CREATE PROCEDURE [dbo].[spTinNpiLevelIAFinalizationValidation]
	-- Add the parameters for the stored procedure here
@TIN varchar(10),
@Npi varchar(11),
@CMSYear int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
-- fullyear 

	--step #1 faciltiy cms attestation validation
		select case
		--when (select COUNT(*) 
		--from  tbl_GPRO_TIN_EmailAddresses 
		--where GPROTIN =@TIN
		--and Tin_CMSAttestYear=@CMSYear and IsAttested=1) = 0 
		--then 1

		--step #2 npi level attestation validation
		when 
		(select count(*) 
		from tbl_CMS_Attestation_Year 
		where CMSAttestYear=@CMSYear and IsAttested=1 and PhysicianNPI=@Npi) =0
		then 2

		--step#3 measure validation
		when (select count(*) from tbl_IA_Users where TIN=@TIN
		 and NPI=@Npi
		and CMSYear=@CMSYear) =0
		then 5

		else 0 end as  validationvalue

	
END



