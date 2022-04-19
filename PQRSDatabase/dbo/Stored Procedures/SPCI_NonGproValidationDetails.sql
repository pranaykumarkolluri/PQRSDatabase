-- =============================================
-- Author:		Raju & Sumanth
-- Create date: 09-03-2020
-- Description:	NonGpro SubmittoCMS validation checking
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_NonGproValidationDetails]
	-- Add the parameters for the stored procedure here
	@Tin varchar(10),
	@UserName varchar(50),
	@Role int,
	@CMSYear int
AS
BEGIN

  declare @FacilityPhysicianNPISTINS table(	
		FirstName varchar(256),
		LastName varchar(256),
		NPI varchar(10),
		TIN varchar(9),
		is_active bit, 
		deactivation_date datetime,
		is_enrolled bit
		)

 IF(@Role=1)   --facility user
	   BEGIN
				   insert into @FacilityPhysicianNPISTINS
						exec sp_getFacilityPhysicianNPIsTINs @UserName,@Tin
						

	   END
	   ELSE IF(@Role=2) --AcrStaff
	   BEGIN
					 declare @ACRStaffNPISTINS table(
					 NPI varchar(10),	
					FirstName varchar(256),
					LastName varchar(256),		
					TIN varchar(9),
					isgpro bit,
					is_enrolled bit
					)
					insert into @ACRStaffNPISTINS
						exec sp_getNPIsOfTin @Tin

						insert into @FacilityPhysicianNPISTINS
						select FirstName,LastName,NPI,TIN,null,null,is_enrolled from @ACRStaffNPISTINS

	   END

	   select @Tin as Tin,f.Npi,opt.isOptedIn,opt.isOptInEligible,att.IsAttested,p.IsAttested as PIAttestation from @FacilityPhysicianNPISTINS f  left join tbl_CI_OptIn_Details opt
	   on f.TIN=opt.Tin
	   and f.NPI=opt.Npi
	   and opt.Method_Id=14  --14 means Optin Get
	   and opt.OptinYear=@CMSYear	   

	   left join tbl_CMS_Attestation_Year att on f.TIN=att.TIN
	   and f.NPI=att.PhysicianNPI and att.IsAttested=1
	   and att.CMSAttestYear=@CMSYear

	    left join tbl_ACI_TINNPILevelAttestation p on 
	    p.PhysicianNPI=f.Npi 
	   and p.CMSAttestYear=@CMSYear
	   where f.NPI is not null
	   
	  


END
