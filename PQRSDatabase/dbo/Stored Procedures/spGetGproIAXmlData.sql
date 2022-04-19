
-- =============================================
-- Author:		Raju Gaddam
-- Create date: March 14,2018
-- Description:	Get IA Gpro Activities for Generate IA XML 2017
-- =============================================
CREATE PROCEDURE [dbo].[spGetGproIAXmlData]

@CMSYear int
AS
BEGIN

select distinct s.SelectedActivity,I.TIN,I.CMSYear from tbl_TIN_GPRO T
join tbl_IA_Users I  with (nolock) on T.TIN=I.TIN
join tbl_IA_User_Selected s  with (nolock) on s.SelectedID=i.SelectedID
where I.CMSYear=@CMSYear and T.is_GPRO=1 
--group by  s.SelectedActivity,I.TIN,I.CMSYear

END


