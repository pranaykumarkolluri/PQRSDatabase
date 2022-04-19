CREATE PROCEDURE [dbo].[sp_getACRTINsWithOptInStatus] 
	-- Add the parameters for the stored procedure here
	@IsGpro bit,
	@CmsYear int
AS
BEGIN
		declare @UserRelatedTINS table(	
		TIN varchar(9),
		IsGpro bit
		)

		declare @ACRStaffTINS table(
		TIN varchar(9)
		)
		insert into @ACRStaffTINS
			Exec SPGetNpisofTin_VW ''

		insert into @UserRelatedTINS
		select a.TIN,ISNULL(g.is_GPRO,0) from @ACRStaffTINS a left join tbl_TIN_GPRO g on a.TIN=g.TIN

		if(@IsGpro = 1)
			BEGIN
				select distinct U.TIN as TIN,
						O.IsOptInEligible as OptinEligibleStatus,
						O.IsOptedIn as OptedIn,
						OptInDecisionDate as OptinDecisionDate,
						cast(NULL as varchar(10)) as NPI
				from @UserRelatedTINS as U 
				left join tbl_CI_Lookup_OptinData as O on U.TIN = O.TIN  and O.NPI is NULL 
				where U.IsGpro = @IsGpro
				order by OptinEligibleStatus DESC
			END
		if(@IsGpro = 0)
			BEGIN
				select distinct U.TIN as TIN,
						O.IsOptInEligible as OptinEligibleStatus,
						O.IsOptedIn as OptedIn,
						OptInDecisionDate as OptinDecisionDate,
						cast(O.NPI as varchar(10)) as NPI
				from @UserRelatedTINS as U
				join PHYSICIAN_TIN_VW as V on U.TIN = V.TIN COLLATE Database_Default 
				left join tbl_CI_Lookup_OptinData as O on U.TIN = O.TIN and O.NPI = V.NPI COLLATE Database_Default
				where U.IsGpro = @IsGpro
			    order by OptinEligibleStatus DESC
			END
END