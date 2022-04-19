-- =============================================
-- Author:		Raju Gaddam
-- Create date: March 14,2018
-- Description:	Get IA NonGpro Activities for Generate IA XML 2017
-- =============================================
CREATE PROCEDURE [dbo].[spGetNonGproIAXmlData_Tin_NPI]

@CMSYear int,
@Tin varchar(9),
@Npi varchar(10)
AS
BEGIN

Declare @PhysicinaTins as Table(NPI Varchar(10),
TIN Varchar(9))
--INSERT into @PhysicinaTins
--select DISTINCT  NPI,TIN from NRDR..[PHYSICIAN_TIN_VW] where TIN=@Tin

select distinct S.SelectedActivity,I.TIN,I.NPI,I.CMSYear 
--from tbl_Physician_TIN P
from 
 tbl_IA_Users I 
join tbl_IA_User_Selected S on S.SelectedID =I.SelectedID 
where I.CMSYear=@CMSYear 
--and I.NPI =p.NPI   
and I.NPI=@Npi
and I.TIN not in(select TIN from tbl_TIN_GPRO where is_GPRO=1) and I.TIN=@Tin
and not exists (select  1 from tbl_lookup_block_submission B 
												INNER JOIN tbl_lookup_MeasureBlockList BM
												ON B.BlockId=BM.BlockId
												   AND B.TIN=I.TIN
												   AND B.CMSYear=I.CMSYear
												   AND B.CategoryId=2
												   AND BM.Measure=s.SelectedActivity
												)
--group by S.SelectedActivity,I.SelectedID,I.TIN,I.NPI,I.CMSYear

END


