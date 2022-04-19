CREATE PROCEDURE [dbo].[sp_getTINNPIsWithOptInStatus] 
	-- Add the parameters for the stored procedure here
	@IsGpro bit,
	@userRole int,
	@UserName varchar(50) = ''
AS
BEGIN
		declare @UserRelatedTINS table(	
		TIN varchar(9),
		IsGpro bit
		)

		declare @UserTins table(
		TIN varchar(9)
		)
		if(@userRole = 2)
			BEGIN
				insert into @UserRelatedTINS
					Exec sp_getFacilityTIN_GPRO @UserName
			END
		ELSE
			BEGIN
				declare @ACRStaffTINS table(
				TIN varchar(9)
				)
				insert into @ACRStaffTINS
					Exec SPGetNpisofTin_VW ''

				insert into @UserRelatedTINS
				select a.TIN,ISNULL(g.is_GPRO,0) from @ACRStaffTINS a left join tbl_TIN_GPRO g on a.TIN=g.TIN

			END

		if(@IsGpro = 1)
			BEGIN
				select distinct U.TIN as TIN,
					CASE WHEN O.IsOptInEligible =1 and O.IsOptedIn is NULL THEN 0
						ELSE 1 END as OptinEligibleStatus
				from @UserRelatedTINS as U left join tbl_CI_Lookup_OptinData as O on U.TIN = O.TIN  and O.NPI is NULL 
				where U.IsGpro = 1  order by OptinEligibleStatus DESC
			END
		ELSE
			BEGIN
				select distinct U.TIN as TIN, 1 as OptinEligibleStatus from tbl_CI_Lookup_OptinData as O 
				right join @UserRelatedTINS as U on U.TIN = O.TIN and O.NPI is NOT NULL
				where U.IsGpro = 0 and O.TIN NOT in (
					select distinct TIN from tbl_CI_Lookup_OptinData 
						where NPI is NOT NULL and IsOptedIn is NULL and IsOptInEligible = 1
					)
				union
				select distinct U.TIN as TIN , 0 as OptinEligibleStatus from tbl_CI_Lookup_OptinData as O 
				right join @UserRelatedTINS as U on U.TIN = O.TIN and O.NPI is NOT NULL
				where U.IsGpro = 0 and O.TIN in (
					select distinct TIN from tbl_CI_Lookup_OptinData 
						where NPI is NOT NULL and IsOptedIn is NULL and IsOptInEligible = 1
					)
			END
	END