-- =============================================
-- Author:		Raju Gaddam
-- Create date: Feb 28, 2018
-- Description:	CMS TinLevel Attestation and Finalization Validation
---Validation Values Description : 
--								  ValidationValue =1 --> Facility Attestation Validation
--								  ValidationValue =2 --> Physician Attestation Validation
--								  ValidationValue =3 --> Facility ACI Attestation Validation
--								  ValidationValue =4 --> Physican ACI Attestation Validation
--								  ValidationValue =4 --> Measures/Activities Validation
-- =============================================
CREATE PROCEDURE [dbo].[spTinNpiLevelQMFinalizationValidation]
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
	
		
		--when (select COUNT(*) 
		--from  tbl_GPRO_TIN_EmailAddresses 
		--where GPROTIN =@TIN
		--and Tin_CMSAttestYear=@CMSYear and IsAttested=1) = 0 
		--then 1

		
		select case
		when 
		(select count(*) 
		from tbl_CMS_Attestation_Year with (nolock)
		where CMSAttestYear=@CMSYear and IsAttested=1 and PhysicianNPI=@Npi) =0
		then 2

		
		when (select count(*) from tbl_Physician_Selected_Measures_90days with (nolock) where TIN=@TIN and NPI=@Npi
		and Submission_year=@CMSYear and SelectedForSubmission = 1) =0
		then 5

		else 0 end as  validationvalue
	end
	else  -- 90 days validation 
	begin
	
		select case
		--when (select COUNT(*) 
		--from  tbl_ACI_TIN_LevelAttestation 
		--where GPROTIN =@TIN
		--and Tin_CMSAttestYear=@CMSYear and IsAttested=1) = 0 
		--then 1

		
		when 
		(select count(*) 
		from tbl_CMS_Attestation_Year  with (nolock)
		where CMSAttestYear=@CMSYear and IsAttested=1 and PhysicianNPI=@Npi) =0
		then 2

		
		when (select count(*) from tbl_Physician_Selected_Measures with (nolock) where TIN=@TIN and NPI=@Npi
		and Submission_year=@CMSYear and SelectedForSubmission = 1) =0
		then 5

		else 0 end as  validationvalue
	end
END
