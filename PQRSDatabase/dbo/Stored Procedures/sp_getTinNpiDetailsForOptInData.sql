-- =============================================
-- Author:		<Sai Pavan>
-- Create date: 02/09/2021
-- Description:	Get tin npi data for optIn Details
-- =============================================
CREATE PROCEDURE [dbo].[sp_getTinNpiDetailsForOptInData]
	@cmsYear int,
	@facilityusername varchar(50)='',
	@IsGpro int
AS
BEGIN
	SET NOCOUNT ON;
		declare @UserRelatedTINS table(	
		TIN varchar(9),
		IsGpro bit
		)
		insert into @UserRelatedTINS
				exec sp_getFacilityTIN_GPRO @facilityusername

		IF(@IsGpro=1) 
			BEGIN
				select distinct TIN,
					cast(Null as varchar(10)) as NPI 
				from @UserRelatedTINS; 
			END
		IF(@IsGpro=0)
			BEGIN
				select distinct U.TIN as TIN,
					cast(P.NPI as varchar(10)) as NPI
				 from @UserRelatedTINS as U join PHYSICIAN_TIN_VW as P on U.TIN collate database_default = P.TIN where U.IsGpro = 0
			END
END
