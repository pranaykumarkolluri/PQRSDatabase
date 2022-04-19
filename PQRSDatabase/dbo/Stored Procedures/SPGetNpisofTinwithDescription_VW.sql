-- =============================================
-- Author:		<Sumanth>
-- Create date: <05/07/2018>
-- Description:	<used to get Npis of Tins with Description using NRDR PHYSICIAN_TIN_VW view>
-- =============================================
CREATE PROCEDURE [dbo].[SPGetNpisofTinwithDescription_VW]
	-- Add the parameters for the stored procedure here
	@NPI varchar(10)=''
AS
BEGIN
	
select distinct TIN,
(select TOP 1 TIN_DESCRIPTION from NRDR..PHYSICIAN_TIN_VW P where p.TIN=W.TIN) as TIN_DESCRIPTION
,npi 
from NRDR..PHYSICIAN_TIN_VW W
where W.NPI=CASE @NPI when '' THEN NPI

	ELSE @NPI END

END

