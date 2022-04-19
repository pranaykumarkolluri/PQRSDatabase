
-- =============================================
-- Author:		Sumanth Hari
-- Create date: 25 march 2019
-- Description:	Used to get IA Activities data
--@Role:   1--Facility  , 2--AcrStaff  ,3--Physician 
--Change#1: changed by Sumanth 05 april 2019 Jira# 688
--Change#2:Sumanth
--Change#2:Jira#784
--Change#3:Jira#798
--Change#4: JIRA#955, Hari on 10th June 2021
--Change#5: JIRA#970, Pavan on 3rd Aug 2021
--Change#6: JIRA#1074, Pavan on 12th Dec 2021
-- =============================================
CREATE PROCEDURE [dbo].[SPIA_Activitieslist]	
    
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



		

		


			IF(@isGPRO=1)
			BEGIN
				   --select distinct @SelectedID=SelectedID from tbl_IA_Users where TIN=@Tin and CMSYear=@CMSYear
				   	 select distinct @SelectedID=SelectedID from tbl_IA_Users s where s.TIN=@Tin  and s.CMSYear=@CMSYear
				                                                and  ((@CMSYear>=2020 and s.IsGpro=1 ) or @CMSYear<2020 )     --Change#2

				   IF(@SelectedID>0)
				   BEGIN
						   select   @SelectedActivity=COALESCE(@SelectedActivity+', ' ,'') + SelectedActivity
						   from tbl_IA_User_Selected where 
						   SelectedID=@SelectedID
						   and attest=CASE WHEN @CMSYear >=2020 THEN 1 ELSE attest END --Change#3
						  
				   END

								select distinct 
								FirstName as Firstname,				
									LastName as Lastname,
									t.NPI as NPI,
									t.TIN as Tin,
									@SelectedActivity as SelectedActivites,
									@isGPRO as isGpro,
								'' as emailid,
								@defaultbit as isFinalize,
								@defaultdate as finalizeAgreeDate,
								@defaultdate as finalizeDisAgreeDate,
								@defaultbit as isSubmitToCI,
								'' as LastSubmittedDateTime,
								'' as LastSubmittedBy,  --Change#6
								@CMSYear as CMSYear,
								CONVERT(bit,0) as SubmittoCMS,
								t.is_enrolled,
								'' as OptInDate,
								CONVERT(bit,0) as  isOptedIn   
									from  PHYSICIAN_TIN_VW V INNER JOIN  @FacilityPhysicianNPISTINS t 
						ON V.NPI COLLATE DATABASE_DEFAULT = t.NPI  and V.IS_ACTIVE=1 and V.IS_ENROLLED = 1 -- Change#5
						 where T.TIN=@Tin -- Change#2 
					

			 END
		----------GPRO END-------------
		ELSE   ---NonGpro Starts
		BEGIN
		       Select @SubmittoCMS_Status=IsSubmittoCMS from tbl_Lookup_Active_Submission_Year where Submission_Year=@CMSYear and IsActive=1   --Change#1:
		        IF(@CMSYear>=2018)
				BEGIN
							select distinct 
								t.FirstName as Firstname,				
								t.LastName as Lastname,
								t.NPI as NPI,
								t.TIN as Tin,
							dbo.fnGetCOALESCEByTinNpi(t.TIN, t.NPI,@CMSYear,2) as SelectedActivites,
							 @isGPRO as isGpro,
						   '' as emailid,
							@defaultbit as isFinalize,
							@defaultdate as finalizeAgreeDate,
							@defaultdate as finalizeDisAgreeDate,
							dbo.fnCI_GetIsSubmittoCI(t.TIN,t.NPI,@CMSYear,@Category_Id) as isSubmitToCI,
							dbo.fnCI_GetLastSubmittedDate(t.TIN,t.NPI,@CMSYear,@Category_Id) as LastSubmittedDateTime,
								dbo.fnCI_GetLastSubmittedUser(t.TIN,'',@CMSYear,@Category_Id) as LastSubmittedBy,--Change#6
							@CMSYear as CMSYear,
							@SubmittoCMS_Status as SubmittoCMS,
							t.is_enrolled, 
							---s.SelectedActivity	
							 CONVERT(varchar(50), o.optInDecisionDate) as OptInDate,
						     CONVERT(bit,o.isOptedIn) as  isOptedIn  
						from PHYSICIAN_TIN_VW V INNER JOIN  @FacilityPhysicianNPISTINS t 
						ON V.NPI COLLATE DATABASE_DEFAULT = t.NPI  and V.IS_ACTIVE=1 --Change#4
						and V.IS_ENROLLED = 1 -- Change#5
						 LEFT JOIN tbl_CI_OptIn_Details o 
						on t.TIN=o.Tin and t.NPI=o.Npi and o.OptinYear=@CMSYear and o.Method_Id=14   --OptInGet  
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
							dbo.fnGetCOALESCEByTinNpi(t.TIN, t.NPI,@CMSYear,2) as SelectedActivites,
							 @isGPRO as isGpro,
						   @facilityemail as emailid,
							I.isFinalize as isFinalize,
						   Convert(varchar(250),I.FinalizeAgreeTime) as finalizeAgreeDate,
							Convert(varchar(250),I.FinalizeDisagreeTime) as finalizeDisAgreeDate,
							@defaultbit as isSubmitToCI,
							'' as LastSubmittedDateTime,
							'' as LastSubmittedBy,		--Change#6
							@CMSYear as CMSYear,
							CONVERT(bit,0) as SubmittoCMS,
							t.is_enrolled,
							'' as OptInDate,
								CONVERT(bit,0) as  isOptedIn    
							---s.SelectedActivity	

						from PHYSICIAN_TIN_VW V INNER JOIN  @FacilityPhysicianNPISTINS t 
						ON V.NPI COLLATE DATABASE_DEFAULT = t.NPI  and V.IS_ACTIVE=1 --Change#4
						and V.IS_ENROLLED = 1 -- Change#5
						 left join tbl_CMS_IA_Finalization I
									on t.TIN=i.TIN and t.NPI= I.NPI and i.Finalize_Year=@CMSYear 
									where   t.TIN=@Tin
				END


		END    ---NonGpro End
END


