CREATE PROCEDURE [dbo].[sp_getFacilityTINsWithOptInStatus] 
	-- Add the parameters for the stored procedure here
	@FacilityUserName as varchar(250),
	@IsGpro bit,
	@CMSYear int
AS
BEGIN
		declare @UserRelatedTINS table(	
		TIN varchar(9),
		IsGpro bit
		)
		insert into @UserRelatedTINS
				exec sp_getFacilityTIN_GPRO @FacilityUserName

		if(@IsGpro = 1)
			BEGIN
				select distinct U.TIN as TIN,
						O.IsOptInEligible as OptinEligibleStatus,
						O.IsOptedIn as IsOptedIn,
						O.OptInDecisionDate,
						cast(NULL as varchar(10)) as NPI
				from @UserRelatedTINS as U
				left join tbl_CI_Lookup_OptinData as O on U.TIN = O.TIN and O.NPI is NULL
				where U.IsGpro=1 and O.CmsYear = @CMSYear order by OptinEligibleStatus DESC
			END
		if(@IsGpro = 0)
			BEGIN
				select distinct U.TIN as TIN,
						O.IsOptInEligible as OptinEligibleStatus,
						O.IsOptedIn as IsOptedIn,
						O.OptInDecisionDate,
						cast(O.NPI as varchar(10)) as NPI
				from @UserRelatedTINS as U join PHYSICIAN_TIN_VW as V on U.TIN = V.TIN COLLATE Database_Default  
				join tbl_CI_Lookup_OptinData as O on U.TIN = O.TIN and O.NPI = V.NPI COLLATE Database_Default
			    where U.IsGpro=0 and O.CmsYear = @CMSYear order by OptinEligibleStatus DESC
			END
END