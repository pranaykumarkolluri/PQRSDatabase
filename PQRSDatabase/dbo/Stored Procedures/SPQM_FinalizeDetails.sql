
-- =============================================
-- Author:		Sumanth Hari
-- Create date: 25 march 2019
-- Description:	Used to get IA Finalize & Submit to CMS  data
--Change#1: changed by Sumanth 05 april 2019 Jira# 688
--Change#2 : changed by Sai Pavan 09/16/2021
--Change#3 : changed by Sai Pavan 12/1/2021
-- =============================================
CREATE PROCEDURE [dbo].[SPQM_FinalizeDetails]	
    
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
								C.is90Days_Checked as is90Days ,
								CONVERT(bit,0) as SubmittoCMS,  
								 '' as OptInDate,
								CONVERT(bit,0) as  isOptedIn 
									from @UserRelatedTINS f left join tbl_CMS_Finalization I
									on f.TIN=i.TIN and I.NPI is null and i.Finalize_Year=@CMSYear 
									left join tbl_Tin_NPI_90Days_Check C 
									on f.TIN=C.TIN and (C.NPI is null or C.NPI='') and C.CMSYear=@CMSYear
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
								Convert(bit,0) as is90Days,
								CONVERT(bit,0) as SubmittoCMS,
								'' as OptInDate,
								CONVERT(bit,0) as  isOptedIn      
									from @UserRelatedTINS f 
									where  f.IsGpro=0
						   END
						   ELSE  --For 2018
						   BEGIN
						Select @SubmittoCMS_Status=IsSubmittoCMS from tbl_Lookup_Active_Submission_Year where Submission_Year=@CMSYear and IsActive=1   --Change#1:	   	
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
								Convert(bit,0) as is90Days,
								@SubmittoCMS_Status as SubmittoCMS,
								CONVERT(varchar(50), o.optInDecisionDate) as OptInDate,
								CONVERT(bit,o.isOptedIn) as  isOptedIn     
									from @UserRelatedTINS f LEFT JOIN tbl_CI_Lookup_OptinData o 
									on f.TIN=o.Tin and o.Npi is null and o.CmsYear=@CMSYear   --#Change2 
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
								Convert(bit,0) as is90Days,
								CONVERT(bit,0) as SubmittoCMS,
								'' as OptInDate,
								CONVERT(bit,0) as  isOptedIn     
									from @UserRelatedTINS f 
									where  f.IsGpro=0 order by f.IsGpro desc
					     END
	
END

