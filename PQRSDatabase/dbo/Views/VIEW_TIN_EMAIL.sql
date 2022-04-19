

CREATE VIEW [dbo].[VIEW_TIN_EMAIL]

AS

       select distinct rt.number as TIN,
	  'kchakali@acr.org' as email 
	  -- am.email

       from [nrdr]..nrdr_user_profile nup

       inner join [nrdr]..aspnet_membership am on (am.userid = nup.userid)

       inner join [nrdr]..registry_tin rt on (rt.facility_id = nup.facilityid)

       where

       nup.UserTypeForSorting = 1

       and am.IsApproved = 1

       and rt.number is not null

