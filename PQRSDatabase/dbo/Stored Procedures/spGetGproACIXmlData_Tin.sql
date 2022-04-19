-- =============================================
-- Author:		Raju Gaddam
-- Create date: March 14,2018
-- Description:	Get ACI Gpro Activities for Generate IA XML/JSON 
-- Change#1:By raju g
--Chnage#1: JIRA-785 
-- =============================================
CREATE PROCEDURE [dbo].[spGetGproACIXmlData_Tin]

@CMSYear int,
@Tin varchar(9)
AS
BEGIN

select distinct  s.Selected_MeasureIds,s.Denominator,s.Numerator,s.Attestion,I.TIN,I.CMSYear from tbl_TIN_GPRO T
join tbl_ACI_Users I on T.TIN=I.TIN
and  I.CMSYear=@CMSYear and  ((@CMSYear>=2020 and I.IsGpro=1) or @CMSYear<2020 ) --Chnage#1
join tbl_User_Selected_ACI_Measures s on s.Selected_Id=i.Selected_Id
where T.is_GPRO=1 and T.TIN=@Tin
--group by  s.Selected_MeasureIds,s.Denominator,s.Numerator,s.Attestion,I.TIN,I.CMSYear
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


