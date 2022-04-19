-- =============================================
-- Author:		Sumanth S
-- Create date: 17/03/2020
-- Description:	get TIN and Email Address 
-- =============================================
CREATE PROCEDURE [dbo].[spGetFacilityTins_EmailAddress]
	@UserName varchar(50),
	@CMSYear int
AS
BEGIN
	declare @FacilityTins table(		
		TIN varchar(9),		
		IS_GPRO bit
		)

		insert into @FacilityTins exec sp_getFacilityTIN_GPRO @UserName

		select f.TIN,f.IS_GPRO,e.GPROTIN_EmailAddress from @FacilityTins f left join tbl_GPRO_TIN_EmailAddresses e
		on f.TIN=e.GPROTIN and e.Tin_CMSAttestYear=@CMSYear
END
