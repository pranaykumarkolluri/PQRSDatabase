
-- =============================================
-- Author:		Sumanth Hari
-- Create date: 25 march 2019
-- Description:	Used to get IA Activities data
--@Role:   1--Facility  , 2--AcrStaff  ,3--Physician 
--Change#1: changed by Sumanth 05 april 2019 Jira# 688
--Change#2: changed by Hari 10 June 2021 Jira# 955
--change#3: Changed by Pavan 17 Nov 2021 Jira#1072
--change#4: Changed by Pavan 17 Nov 2021 Jira#1074
-- =============================================
CREATE PROCEDURE [dbo].[SPQM_FacilityPhyFinalizeDetails]	
    
	 @CMSYear int,	 	 
	 @Category_Id int,
	  @Tin varchar(9), 
	  --@Npi varchar(10)='',
	  @isGPRO bit,
	   @Userid int=0,
	   @RoleId int=1,
	 @facilityusername varchar(50)=''
	
	 
AS
BEGIN


		declare @SelectedActivity varchar(max);
		declare @SubmittoCMS_Status bit;
		declare @SelectedID int;
	   declare @defaultdate varchar(10)=''; --for default structure
	   declare @defaultbit bit=0;--for default structure
	   declare @facilityemail varchar(100);

	   declare @FacilityPhysicianNPISTINS table(	
		FirstName varchar(256),
		LastName varchar(256),
		NPI varchar(10),
		TIN varchar(9),
		is_active bit, 
		deactivation_date datetime,
		is_enrolled bit
		)


	   IF(@RoleId=1)   --facility user
	   BEGIN
				   insert into @FacilityPhysicianNPISTINS
						exec sp_getFacilityPhysicianNPIsTINs @facilityusername,@Tin

	   END
	   ELSE IF(@RoleId=2) --AcrStaff
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
		        IF(@CMSYear>=2018)
				BEGIN
				Select @SubmittoCMS_Status=IsSubmittoCMS from tbl_Lookup_Active_Submission_Year where Submission_Year=@CMSYear and IsActive=1  --Change#1:	   	
							select distinct 
								t.FirstName as Firstname,				
								t.LastName as Lastname,
								t.NPI as NPI,
								t.TIN as Tin,
							--dbo.fnGetCOALESCEByTinNpi(t.TIN, t.NPI,@CMSYear,2) as SelectedActivites,
							 @isGPRO as isGpro,
						   '' as emailid,
							@defaultbit as isFinalize,
							@defaultdate as finalizeAgreeDate,
							@defaultdate as finalizeDisAgreeDate,
							dbo.fnCI_GetIsSubmittoCI(t.TIN,t.NPI,@CMSYear,@Category_Id) as isSubmitToCI,
							dbo.fnCI_GetLastSubmittedDate(t.TIN,t.NPI,@CMSYear,@Category_Id) as LastSubmittedDateTime,
								dbo.fnCI_GetLastSubmittedUser(t.TIN,t.NPI,@CMSYear,@Category_Id) as LastSubmittedBy,			--change#4
							@CMSYear as CMSYear, 
							Convert(bit,0) as is90Days,
							@SubmittoCMS_Status as SubmittoCMS,
							t.is_enrolled,
							CONVERT(varchar(50), o.optInDecisionDate) as OptInDate,
						     CONVERT(bit,o.isOptedIn) as  isOptedIn        
							---s.SelectedActivity	

						from PHYSICIAN_TIN_VW V INNER JOIN  @FacilityPhysicianNPISTINS t 
						ON V.NPI COLLATE DATABASE_DEFAULT = t.NPI 
						--Change#3
						-- and V.IS_ACTIVE=1-- Change#2
						LEFT JOIN tbl_CI_Lookup_OptinData o
						 on t.TIN=o.TIN and t.NPI=o.NPI and o.CmsYear=@CMSYear   --OptInGet  
						where t.TIN=@Tin
			    END
				ELSE
				BEGIN
				Select top 1 @facilityemail=GPROTIN_EmailAddress from tbl_GPRO_TIN_EmailAddresses where Tin_CMSAttestYear=@CMSYear and CreatedBy =@Userid
				      select distinct 
								t.FirstName as Firstname,				
								t.LastName as Lastname,
								t.NPI as NPI,
								t.TIN as Tin,
							--dbo.fnGetCOALESCEByTinNpi(t.TIN, t.NPI,@CMSYear,2) as SelectedActivites,
							 @isGPRO as isGpro,
						   @facilityemail as emailid,
							I.isFinalize as isFinalize,
						   Convert(varchar(250),I.FinalizeAgreeTime) as finalizeAgreeDate,
							Convert(varchar(250),I.FinalizeDisagreeTime) as finalizeDisAgreeDate,
							@defaultbit as isSubmitToCI,
							'' as LastSubmittedDateTime,
							'' as LastSubmittedBy,			--change#4
							@CMSYear as CMSYear,
							C.is90Days_Checked as is90Days,
							CONVERT(bit,0) as SubmittoCMS,
							t.is_enrolled,
							'' as OptInDate,
								CONVERT(bit,0) as  isOptedIn   
							
							---s.SelectedActivity	

						from @FacilityPhysicianNPISTINS t  left join tbl_CMS_Finalization I
									on t.TIN=i.TIN and t.NPI= I.NPI and i.Finalize_Year=@CMSYear
									LEFT JOIN tbl_Tin_NPI_90Days_Check C
									on C.TIN=i.TIN and C.NPI= I.NPI and C.CMSYear=@CMSYear
									 
									where   t.TIN=@Tin
				END
END


