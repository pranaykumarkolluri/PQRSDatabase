-- =============================================
-- Author:		Raju Gaddam
-- Create date: March 14,2018
-- Description:	Get ACI Gpro Activities for Generate ACI XML 2017
-- =============================================
CREATE PROCEDURE [dbo].[spGetGproACIXmlData]

@CMSYear int
AS
BEGIN

select distinct  s.Selected_MeasureIds,s.Denominator,s.Numerator,s.Attestion,I.TIN,I.CMSYear from tbl_TIN_GPRO T
join tbl_ACI_Users I  with (nolock) on T.TIN=I.TIN
join tbl_User_Selected_ACI_Measures s with (nolock) on s.Selected_Id=i.Selected_Id
where I.CMSYear=@CMSYear and T.is_GPRO=1 
--group by  s.Selected_MeasureIds,s.Denominator,s.Numerator,s.Attestion,I.TIN,I.CMSYear

END
