-- =============================================
-- Author:		Raju Gaddam
-- Create date: March 14,2018
-- Description:	Get ACI NonGpro MeasureData for Generate ACI XML 2017
-- =============================================
CREATE PROCEDURE [dbo].[spGetNonGproACIXmlData_Tin_NPI]

@CMSYear int,
@Tin varchar(9),
@Npi varchar(10)
AS
BEGIN


Declare @PhysicinaTins as Table(NPI Varchar(10),
TIN Varchar(9))
--INSERT into @PhysicinaTins
--select DISTINCT  NPI,TIN from NRDR..[PHYSICIAN_TIN_VW] where TIN=@Tin

	select distinct S.Selected_MeasureIds,S.Attestion,S.Denominator,S.Numerator, I.TIN,
I.NPI,I.CMSYear 
--from tbl_Physician_TIN P
from tbl_ACI_Users I
join tbl_User_Selected_ACI_Measures S on S.Selected_Id =I.Selected_Id 
where I.CMSYear=@CMSYear 
--and P.NPI =I.NPI
and I.NPI =@Npi
and I.TIN not in(select TIN from tbl_TIN_GPRO where is_GPRO=1) and I.TIN=@Tin
--group by S.Selected_MeasureIds,I.Selected_Id,I.TIN,I.NPI,I.CMSYear,S.Attestion,S.Denominator,S.Numerator
and 
not exists (select  1 from tbl_lookup_block_submission B 
												INNER JOIN tbl_lookup_MeasureBlockList BM
												ON B.BlockId=BM.BlockId
												   AND B.TIN=I.TIN
												   AND B.CMSYear=I.CMSYear
												   AND B.CategoryId=3
												   AND BM.Measure=s.Selected_MeasureIds
												)
END


