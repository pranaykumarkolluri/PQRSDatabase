
-- =============================================
-- Author:		Raju Gaddam
-- Create date: September 28,2018
-- Description:	Get IA Gpro Activities for Generate IA XML/JSON 
-- Change#1: Sumanth
-- Change#1: 784

--Change#2: Raju G
--Change#2: JIRA-798 -IA attestation / added attest condition.

-- =============================================
CREATE PROCEDURE [dbo].[spGetGproIAXmlData_Tin]

@CMSYear int,
@Tin varchar(9)
AS
BEGIN

select distinct s.SelectedActivity,I.TIN,I.CMSYear from tbl_TIN_GPRO T
join tbl_IA_Users I on T.TIN=I.TIN 
and  I.CMSYear=@CMSYear and  ((@CMSYear>=2020 and I.IsGpro=1) or @CMSYear<2020 ) --Chnage#1
join tbl_IA_User_Selected s on s.SelectedID=i.SelectedID and s.attest=CASE WHEN @CMSYear >=2020 THEN 1 ELSE S.attest END --Change#2
where T.is_GPRO=1 and T.TIN=@Tin 
and 
not exists (select  1 from tbl_lookup_block_submission B 
												INNER JOIN tbl_lookup_MeasureBlockList BM
												ON B.BlockId=BM.BlockId
												   AND B.TIN=I.TIN
												   AND B.CMSYear=I.CMSYear
												   AND B.CategoryId=2
												   AND BM.Measure=s.SelectedActivity
												)

--group by  s.SelectedActivity,I.TIN,I.CMSYear

END




