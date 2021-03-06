
-- =============================================
-- Author:		Sumanth Hari
-- Create date: 25 march 2019
-- Description:	Used to get IA Finalize & Submit to CMS  data
--Change#1: changed by Sumanth 05 april 2019 Jira# 688
--Change#2: changed by Sumanth  Jira#716
--Change#3: changed by Pavan 06 Aug 2021 JIRA#970
--Change#4: changed by Pavan 14 Dec 2021 JIRA#1074
-- =============================================
CREATE PROCEDURE [dbo].[SPPI_FinalizeDetails_Physician]	
    
	 @CMSYear int,	 	 
	 @Category_Id int,
	 @Role int=3,  --Physician
	 @Npi varchar(10)
	  --@Tin varchar(9)=''
	 --@physicianusername varchar(50)='',
	 --@Userid int=0
	 
AS
BEGIN		
		declare @facilityemail varchar(100);
		declare @SubmittoCMS_Status bit;
		--declare @finalizedate datetime
		declare @is_enrolled bit;	--Change#3

		declare @PhysicianRelatedTINS table(	
		TIN varchar(9)
		--IsGpro bit
		)

		declare @UserRelatedTINSwithGpro table(	
		TIN varchar(9),
		IsGpro bit
		)
		--Change#3
		select distinct  @is_enrolled=IS_ENROLLED from PHYSICIAN_TIN_VW where NPI=@Npi
		IF(@Role=3)  --Physician
		BEGIN
					insert into @PhysicianRelatedTINS
						exec SPGetNpisofTin_VW @Npi	
						
					insert into @UserRelatedTINSwithGpro select P.TIN,G.is_GPRO from @PhysicianRelatedTINS P join tbl_TIN_GPRO G
						on P.TIN=G.TIN				
		END
		--ELSE IF(@Role=2)       --ACRStaff
		--BEGIN
		--      IF(@Tin='' OR @Tin is null)
		--	  BEGIN
		--	      declare @ACRStaffTINS table(	
		--				TIN varchar(9)		
		--				)
		--				 insert into @ACRStaffTINS 
		--					exec SPGetNpisofTin_VW ''

		--					insert into @UserRelatedTINSwithGpro
		--					select a.TIN,g.is_GPRO from @ACRStaffTINS a left join tbl_TIN_GPRO g on a.TIN=g.TIN
		--	  END
		--	  ELSE
		--	  BEGIN
		--	                insert into @UserRelatedTINSwithGpro
		--					select TIN,ISNULL(is_GPRO,0) from tbl_TIN_GPRO where TIN=@Tin
		--	  END

						

		--END
		
			--Select top 1 @facilityemail=GPROTIN_EmailAddress from tbl_GPRO_TIN_EmailAddresses where Tin_CMSAttestYear=@CMSYear and CreatedBy =@Userid

				           IF(@CMSYear<=2017)
						   BEGIN
							   select distinct 														
									f.TIN as Tin,
									@Npi as Npi,									
									f.IsGpro as isGpro,
							 --CASE WHEN (I.FinalizeEmail IS NULL OR I.FinalizeEmail='') THEN (@facilityemail)
							 --else I.FinalizeEmail end as emailid,	
							 CASE WHEN (I.FinalizeEmail IS NULL OR I.FinalizeEmail='') THEN ''
							 else I.FinalizeEmail end as emailid,						  
								I.isFinalize as isFinalize,
							  Convert(varchar(250),I.FinalizeAgreeTime) as finalizeAgreeDate,
								Convert(varchar(250),I.FinalizeDisagreeTime) as finalizeDisAgreeDate,
								 CONVERT(bit,0) as isSubmitToCI,
								'' as LastSubmittedDateTime,
								'' as LastSubmittedBy,			--Change#4
								@CMSYear as CMSYear,
								CONVERT(bit,0) as SubmittoCMS,
								'' as CehrtId,                     --Change#2
								'' as OptInDate,
								CONVERT(bit,0) as  isOptedIn  ,
								@is_enrolled as is_enrolled	--Change#3
									from @UserRelatedTINSwithGpro f left join tbl_CMS_ACI_Finalization I
									on f.TIN=i.TIN and I.NPI=@Npi and i.Finalize_Year=@CMSYear 
									where  f.IsGpro=0 

									UNION

						select distinct 														
									f.TIN as Tin,
									@Npi as Npi,									
									f.IsGpro as isGpro,
							 @facilityemail as emailid,							  
								 CONVERT(bit,0) as isFinalize,
								'' as finalizeAgreeDate,
								'' as finalizeDisAgreeDate,
								  CONVERT(bit,0) as isSubmitToCI,
								'' as LastSubmittedDateTime,
								'' as LastSubmittedBy,			--Change#4
								@CMSYear as CMSYear,
								CONVERT(bit,0) as SubmittoCMS,
								'' as CehrtId,                         --Change#2
								'' as OptInDate,
								CONVERT(bit,0) as  isOptedIn , 
								@is_enrolled as is_enrolled			--Change#3
									from @UserRelatedTINSwithGpro f 
									where  f.IsGpro=1
						   END
						   ELSE  --For 2018
						   BEGIN
				Select @SubmittoCMS_Status=IsSubmittoCMS from tbl_Lookup_Active_Submission_Year where Submission_Year=@CMSYear and IsActive=1  --Change#1:   	
						    select distinct 														
									f.TIN as Tin,
									@Npi as Npi,									
									f.IsGpro as isGpro,
							       @facilityemail as emailid,							  
								 CONVERT(bit,0) as isFinalize,
								'' as finalizeAgreeDate,
								'' as finalizeDisAgreeDate,
								 dbo.fnCI_GetIsSubmittoCI(f.TIN,@Npi,@CMSYear,@Category_Id) as isSubmitToCI,
								 dbo.fnCI_GetLastSubmittedDate(f.TIN,@Npi,@CMSYear,@Category_Id) as LastSubmittedDateTime,
								dbo.fnCI_GetLastSubmittedUser(f.TIN,@Npi,@CMSYear,@Category_Id) as LastSubmittedBy,			--Change#4
								@CMSYear as CMSYear,
								@SubmittoCMS_Status as SubmittoCMS,
								c.CEHRTID as CehrtId,                           --Change#2
								CONVERT(varchar(50), o.optInDecisionDate) as OptInDate,
						       CONVERT(bit,o.isOptedIn) as  isOptedIn, 
								@is_enrolled as is_enrolled					--Change#3
									from @UserRelatedTINSwithGpro f LEFT JOIN
									tbl_TIN_CehrtIds c on f.TIN=c.TIN --and c.CMSYear=@CMSYear
									LEFT JOIN tbl_CI_OptIn_Details o 
									 on f.TIN=o.TIN and o.Npi=@Npi and o.OptinYear=@CMSYear and o.Method_Id=14   --OptInGet  
									where  f.IsGpro=0

									UNION

						select distinct 														
									f.TIN as Tin,
									@Npi as Npi,									
									f.IsGpro as isGpro,
							 @facilityemail as emailid,							  
								 CONVERT(bit,0) as isFinalize,
								'' as finalizeAgreeDate,
								'' as finalizeDisAgreeDate,
								  CONVERT(bit,0) as isSubmitToCI,
								'' as LastSubmittedDateTime,
								'' as LastSubmittedBy,			--Change#4
								@CMSYear as CMSYear,
								CONVERT(bit,0) as SubmittoCMS,
								c.CEHRTID as CehrtId,               --Change#2
								'' as OptInDate,
								CONVERT(bit,0) as  isOptedIn , 
								@is_enrolled as is_enrolled		--Change#3
									from @UserRelatedTINSwithGpro f LEFT JOIN
									tbl_TIN_CehrtIds c on f.TIN=c.TIN --and c.CMSYear=@CMSYear
									where  f.IsGpro=1
									order by f.IsGpro 
									
					     END
	
END

