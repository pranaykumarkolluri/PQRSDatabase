
-- =============================================
-- Author:		Sumanth Hari
-- Create date: 25 march 2019
-- Description:	Used to get IA Activities data
--@Role:   1--Facility  , 2--AcrStaff  ,3--Physician 
--Change#1: changed by Sumanth 05 april 2019 Jira# 688
--Change#2:Jira#785
--Change#2: change by raju
--Change#3: JIRA#955, Hari on 10th June 2021
--Change#4: JIRA#90, Pavan on 3rd Aug 2021
--Change#5: JIRA#1074, Pavan on 14th Dec 2021
-- =============================================
CREATE PROCEDURE [dbo].[SPPI_Activitieslist]	
    
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
				   --select distinct @SelectedID=Selected_Id from tbl_ACI_Users where TIN=@Tin and CMSYear=@CMSYear
				   select distinct @SelectedID=Selected_Id from tbl_ACI_Users s where s.TIN=@Tin  and s.CMSYear=@CMSYear
				                                                and ((@CMSYear >=2020 and s.IsGpro=1) or @CMSYear<2020)  --Change#2    --Change#2

               

				   IF(@SelectedID>0)
				   BEGIN
						   select   @SelectedActivity=COALESCE(@SelectedActivity+', ' ,'') + Selected_MeasureIds
						   from tbl_User_Selected_ACI_Measures where Selected_Id=@SelectedID
						  
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
								'' as LastSubmittedBy,		--Change#5
								@CMSYear as CMSYear,
								CASE
								WHEN (@SelectedActivity='' or @SelectedActivity is null) then ''
								WHEN A.ACI_Id=1 THEN 'PI:' WHEN A.ACI_Id=2 THEN 'PI_TRANS:' ELSE '' END as ACI_Id,
								CONVERT(bit,0) as SubmittoCMS,
								t.is_enrolled,
								t.is_active,
								'' as OptInDate,
								CONVERT(bit,0) as  isOptedIn         
									from 
									PHYSICIAN_TIN_VW V INNER JOIN  @FacilityPhysicianNPISTINS t 
						ON V.NPI COLLATE DATABASE_DEFAULT = t.NPI  and V.IS_ACTIVE=1 --#Change#3
						and V.IS_ENROLLED = 1 -- Change#4
									 LEFT JOIN tbl_ACI_Users A
									on t.TIN=A.TIN and A.CMSYear=@CMSYear
									     and ((@CMSYear >=2020 and A.IsGpro=1) or @CMSYear<2020)     --Change#2
									where t.TIN=@Tin
					

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
							dbo.fnGetCOALESCEByTinNpi(t.TIN, t.NPI,@CMSYear,3) as SelectedActivites,
							 @isGPRO as isGpro,
						   '' as emailid,
							@defaultbit as isFinalize,
							@defaultdate as finalizeAgreeDate,
							@defaultdate as finalizeDisAgreeDate,
							dbo.fnCI_GetIsSubmittoCI(t.TIN,t.NPI,@CMSYear,@Category_Id) as isSubmitToCI,
							dbo.fnCI_GetLastSubmittedDate(t.TIN,t.NPI,@CMSYear,@Category_Id) as LastSubmittedDateTime,
								dbo.fnCI_GetLastSubmittedUser(t.TIN,t.NPI,@CMSYear,@Category_Id) as LastSubmittedBy,		--Change#5
							@CMSYear as CMSYear,
						    CASE
							WHEN (@SelectedActivity='' or @SelectedActivity is null) then ''
							 WHEN A.ACI_Id=1 THEN 'PI:' WHEN A.ACI_Id=2 THEN 'PI_TRANS:' ELSE '' END as ACI_Id,
							@SubmittoCMS_Status as SubmittoCMS,
							t.is_enrolled,
							CONVERT(varchar(50), o.optInDecisionDate) as OptInDate,
						     CONVERT(bit,o.isOptedIn) as  isOptedIn  
									from  
									PHYSICIAN_TIN_VW V INNER JOIN  @FacilityPhysicianNPISTINS t 
						ON V.NPI COLLATE DATABASE_DEFAULT = t.NPI  and V.IS_ACTIVE=1 --#Change#3
						and V.IS_ENROLLED = 1 -- Change#4
									LEFT JOIN tbl_ACI_Users A
									on t.TIN=A.TIN 
										and t.NPI=A.NPI 
										and A.CMSYear=@CMSYear
									
									LEFT JOIN tbl_CI_OptIn_Details o on t.TIN=o.TIN and t.NPI=o.NPI and o.OptinYear=@CMSYear and o.Method_Id=14   --OptInGet  
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
							dbo.fnGetCOALESCEByTinNpi(t.TIN, t.NPI,@CMSYear,3) as SelectedActivites,
							 @isGPRO as isGpro,
						   @facilityemail as emailid,
							I.isFinalize as isFinalize,
						   Convert(varchar(250),I.FinalizeAgreeTime) as finalizeAgreeDate,
							Convert(varchar(250),I.FinalizeDisagreeTime) as finalizeDisAgreeDate,
							@defaultbit as isSubmitToCI,
							'' as LastSubmittedDateTime,
								'' as LastSubmittedBy,		--Change#5
							@CMSYear as CMSYear,
							CASE 
							WHEN (@SelectedActivity='' or @SelectedActivity is null) then ''
							WHEN A.ACI_Id=1 THEN 'ACI:' WHEN A.ACI_Id=2 THEN 'ACI_TRANS:' ELSE '' END as ACI_Id,
							CONVERT(bit,0) as SubmittoCMS,
							t.is_enrolled,
							t.is_active,
							'' as OptInDate,
								CONVERT(bit,0) as  isOptedIn   
							---s.SelectedActivity	

						from PHYSICIAN_TIN_VW V INNER JOIN  @FacilityPhysicianNPISTINS t 
						ON V.NPI COLLATE DATABASE_DEFAULT = t.NPI  and V.IS_ACTIVE=1 --#Change#3
						and V.IS_ENROLLED = 1 -- Change#4
						  left join tbl_CMS_ACI_Finalization I
									on t.TIN=i.TIN and t.NPI= I.NPI and i.Finalize_Year=@CMSYear 
									left join tbl_ACI_Users A on t.TIN=A.TIN and t.NPI=A.NPI and A.CMSYear=@CMSYear 
									
									where   t.TIN=@Tin
				END


		END    ---NonGpro End
END


