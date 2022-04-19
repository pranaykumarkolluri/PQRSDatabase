
-- =============================================
-- Author:		Sumanth Hari
-- Create date: 25 march 2019
-- Description:	Used to get IA Finalize & Submit to CMS  data
--Change#1: changed by Sumanth 05 april 2019 Jira# 688
--Change#2: changed by Sumanth  Jira#716
--Change#3: changed by Pavan  Jira#1074
-- =============================================
CREATE PROCEDURE [dbo].[SPPI_FinalizeDetails]	
    
	 @CMSYear int,	 	 
	 @Category_Id int,
	 @Role int,
	  @Tin varchar(9)='', 
	 @facilityusername varchar(50)='',
	 @Userid int=0
	 
AS
BEGIN		
		declare @facilityemail varchar(100);
		declare @SubmittoCMS_Status bit;
		--declare @finalizedate datetime
		declare @UserRelatedTINS table(	
		TIN varchar(9),
		IsGpro bit
		)
		IF(@Role=1)  --Facility
		BEGIN
					insert into @UserRelatedTINS
						exec sp_getFacilityTIN_GPRO @facilityusername						
		END
		ELSE IF(@Role=2)       --ACRStaff
		BEGIN
		      IF(@Tin='' OR @Tin is null)
			  BEGIN
			      declare @ACRStaffTINS table(	
						TIN varchar(9)		
						)
						 insert into @ACRStaffTINS 
							exec SPGetNpisofTin_VW ''

							insert into @UserRelatedTINS
							select a.TIN,ISNULL(g.is_GPRO,0) from @ACRStaffTINS a left join tbl_TIN_GPRO g on a.TIN=g.TIN
			  END
			  ELSE
			  BEGIN
			                insert into @UserRelatedTINS
							select TIN,ISNULL(is_GPRO,0) from tbl_TIN_GPRO where TIN=@Tin
			  END

						

		END
		
			Select top 1 @facilityemail=GPROTIN_EmailAddress from tbl_GPRO_TIN_EmailAddresses where Tin_CMSAttestYear=@CMSYear and CreatedBy =@Userid
			Select @SubmittoCMS_Status=IsSubmittoCMS from tbl_Lookup_Active_Submission_Year where Submission_Year=@CMSYear and IsActive=1  --Change#1:

				           IF(@CMSYear<=2017)
						   BEGIN
							   select distinct 														
									f.TIN as Tin,									
									f.IsGpro as isGpro,
							 CASE WHEN (I.FinalizeEmail IS NULL OR I.FinalizeEmail='') THEN (@facilityemail)
							 else I.FinalizeEmail end as emailid,							  
								I.isFinalize as isFinalize,
							  Convert(varchar(250),I.FinalizeAgreeTime) as finalizeAgreeDate,
								Convert(varchar(250),I.FinalizeDisagreeTime) as finalizeDisAgreeDate,
								 CONVERT(bit,0) as isSubmitToCI,
								'' as LastSubmittedDateTime,
								'' as LastSubmittedBy,			--Change#3
								@CMSYear as CMSYear,
								CONVERT(bit,0) as SubmittoCMS,
								'' as CehrtId,                           --Change#2
								'' as OptInDate,
								CONVERT(bit,0) as  isOptedIn 
									from @UserRelatedTINS f left join tbl_CMS_ACI_Finalization I
									on f.TIN=i.TIN and I.NPI is null and i.Finalize_Year=@CMSYear 
									where  f.IsGpro=1  

									UNION

						select distinct 														
									f.TIN as Tin,									
									f.IsGpro as isGpro,
							 @facilityemail as emailid,							  
								 CONVERT(bit,0) as isFinalize,
								'' as finalizeAgreeDate,
								'' as finalizeDisAgreeDate,
								  CONVERT(bit,0) as isSubmitToCI,
								'' as LastSubmittedDateTime,
								'' as LastSubmittedBy,			--Change#3
								@CMSYear as CMSYear,
								CONVERT(bit,0) as SubmittoCMS,
								'' as CehrtId,                         --Change#2
								'' as OptInDate,
								CONVERT(bit,0) as  isOptedIn 
									from @UserRelatedTINS f 
									where  f.IsGpro=0
						   END
						   ELSE  --For 2018
						   BEGIN
						   	
						    select distinct 														
									f.TIN as Tin,									
									f.IsGpro as isGpro,
							       @facilityemail as emailid,							  
								 CONVERT(bit,0) as isFinalize,
								'' as finalizeAgreeDate,
								'' as finalizeDisAgreeDate,
								 dbo.fnCI_GetIsSubmittoCI(f.TIN,'',@CMSYear,@Category_Id) as isSubmitToCI,
								 dbo.fnCI_GetLastSubmittedDate(f.TIN,'',@CMSYear,@Category_Id) as LastSubmittedDateTime,
								dbo.fnCI_GetLastSubmittedUser(f.TIN,'',@CMSYear,@Category_Id) as LastSubmittedBy,			--Change#3
								@CMSYear as CMSYear,
								@SubmittoCMS_Status as SubmittoCMS,
								c.CEHRTID as CehrtId,
								 CONVERT(varchar(50), o.optInDecisionDate) as OptInDate,
								 CONVERT(bit,o.isOptedIn) as  isOptedIn  
									from @UserRelatedTINS f LEFT JOIN
									tbl_TIN_CehrtIds c on f.TIN=c.TIN --and c.CMSYear=@CMSYear      --Change#2
									LEFT JOIN tbl_CI_OptIn_Details o on f.TIN=o.Tin and o.Npi is null and o.OptinYear=@CMSYear and o.Method_Id=14   --OptInGet  
									where  f.IsGpro=1

									UNION

						select distinct 														
									f.TIN as Tin,									
									f.IsGpro as isGpro,
							 @facilityemail as emailid,							  
								 CONVERT(bit,0) as isFinalize,
								'' as finalizeAgreeDate,
								'' as finalizeDisAgreeDate,
								  CONVERT(bit,0) as isSubmitToCI,
								'' as LastSubmittedDateTime,
								'' as LastSubmittedBy,			--Change#3
								@CMSYear as CMSYear,
								CONVERT(bit,0) as SubmittoCMS,
								c.CEHRTID as CehrtId,
								'' as OptInDate,
								CONVERT(bit,0) as  isOptedIn   
									from @UserRelatedTINS f LEFT JOIN
									tbl_TIN_CehrtIds c on f.TIN=c.TIN --and c.CMSYear=@CMSYear		 --Change#2						
									where  f.IsGpro=0 
									order by f.IsGpro desc
					     END
	
END


