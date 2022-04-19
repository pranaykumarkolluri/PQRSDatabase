-- =============================================
-- Author:		Raju Gaddam
-- Create date: March 14,2018
-- Description:	Get IA NonGpro Activities for Generate IA XML 2017
--Change#1 Sumanth
--Change#1:Jira-784
-- =============================================
CREATE PROCEDURE [dbo].[spGetNonGproIAXmlData_Tin]

@CMSYear int,
@Tin varchar(9)
AS
BEGIN

Declare @PhysicinaTins as Table(NPI Varchar(10),
TIN Varchar(9))
INSERT into @PhysicinaTins
select DISTINCT  NPI,TIN from NRDR..[PHYSICIAN_TIN_VW] where TIN=@Tin

select distinct S.SelectedActivity,I.TIN,I.NPI,I.CMSYear 
--from tbl_Physician_TIN P
from @PhysicinaTins P 
join tbl_IA_Users I on P.TIN=I.TIN
join tbl_IA_User_Selected S on S.SelectedID =I.SelectedID 
where I.CMSYear=@CMSYear 
and I.TIN not in(select TIN from tbl_TIN_GPRO where is_GPRO=1) and I.TIN=@Tin
--group by S.SelectedActivity,I.SelectedID,I.TIN,I.NPI,I.CMSYear
and ((@CMSYear>=2020 and I.NPI is not null ) or @CMSYear<2020 )       --Change#1

END


