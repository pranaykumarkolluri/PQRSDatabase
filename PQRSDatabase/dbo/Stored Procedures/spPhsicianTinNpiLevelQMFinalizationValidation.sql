-- =============================================
-- Author:		Raju Gaddam
-- Create date: Feb 28, 2018
-- Description: Physician CMS TinNPILevel Attestation and Finalization Validation
-- =============================================
CREATE PROCEDURE [dbo].[spPhsicianTinNpiLevelQMFinalizationValidation]
	-- Add the parameters for the stored procedure here
@TIN varchar(10),
@Npi varchar(11),
@CMSYear int,
@is90days bit


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
-- fullyear 
	if (@is90days=1)
	begin
	----step #1 faciltiy cms attestation validation
	--	select case
	--	when (select COUNT(*) 
	--	from  tbl_GPRO_TIN_EmailAddresses 
	--	where GPROTIN =@TIN
	--	and Tin_CMSAttestYear=@CMSYear and IsAttested=1) = 0 
	--	then 1

		--step #2 npi level attestation validation
	    select case
		when 
		(select count(*) 
		from tbl_CMS_Attestation_Year 
		where CMSAttestYear=@CMSYear and IsAttested=1 and PhysicianNPI=@Npi) =0
		then 2

		--step#3 measure validation
		when (select count(*) from tbl_Physician_Selected_Measures_90days where TIN=@TIN 
		and NPI=@Npi
		and Submission_year=@CMSYear) =0
		then 5

		else 0 end as  validationvalue
	end
	else  -- 90 days validation 
	begin
	--step #1 faciltiy cms attestation validation
		--select case
		--when (select COUNT(*) 
		--from  tbl_ACI_TIN_LevelAttestation 
		--where GPROTIN =@TIN
		--and Tin_CMSAttestYear=@CMSYear and IsAttested=1) = 0 
		--then 1

		--step #2 npi level attestation validation
		select case
		when 
		(select count(*) 
		from tbl_CMS_Attestation_Year 
		where CMSAttestYear=@CMSYear and IsAttested=1 and PhysicianNPI=@Npi) =0
		then 2

		--step#3 measure validation
		when (select count(*) from tbl_Physician_Selected_Measures where TIN=@TIN 
		and NPI=@Npi
		and Submission_year=@CMSYear) =0
		then 5

		else 0 end as  validationvalue
	end
END

