-- =============================================
-- Author:		Raju Gaddam
-- Create date: Feb 28, 2018
-- Description:	CMS TinLevel Attestation and Finalization Validation
-- =============================================
CREATE PROCEDURE [dbo].[spTinNpiLevelPhysicianACIFinalizationValidation]
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


      select case

	  	when
	(select   count(*)
		from tbl_ACI_TINNPILevelAttestation 
		 where 
		 PhysicianNPI=@Npi 
		 and CMSAttestYear=@CMSYear and IsAttested=1)=0
		 and
		 (select count(*) 
		from tbl_CMS_Attestation_Year 
		where CMSAttestYear=@CMSYear and IsAttested=1 and PhysicianNPI=@Npi) =0
		then 6	

		when 
		(select   count(*)
		from tbl_ACI_TINNPILevelAttestation 
		 where 
		 PhysicianNPI=@Npi 
		 and CMSAttestYear=@CMSYear and IsAttested=1)=0
		 then 4

		 	when 
		(select count(*) 
		from tbl_CMS_Attestation_Year 
		where CMSAttestYear=@CMSYear and IsAttested=1 and PhysicianNPI=@Npi) =0
		then 2

		 when 
		 (select count(*)
		 from tbl_ACI_Users where CMSYear=@CMSYear and TIN=@TIN and NPI=@Npi
		 )=0
		 then 5
		 else 0 end as ValidationValue		
			
END

