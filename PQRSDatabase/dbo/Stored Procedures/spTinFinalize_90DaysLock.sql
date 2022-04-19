-- =============================================
-- Author:		Sumanth Sandesari
-- Create date: <Feb 15,17>
-- Description:	<this is help to get tin related finalize data and we can check wheather 90days checked or not>
-- =============================================
CREATE PROCEDURE [dbo].[spTinFinalize_90DaysLock]
	-- Add the parameters for the stored procedure here
@CMSYear int ,
@facilityuseranme varchar(100),
@userId int

AS
BEGIN

declare @facilitytins table(TIN varchar(9) , IS_GPRO bit)

insert into @facilitytins exec  [dbo].[sp_getFacilityTIN_GPRO] @facilityuseranme
select C.TIN,C.IS_GPRO, 
e.FinalizeAgreeTime,
e.FinalizeDisagreeTime,
ISNULL(e.FinalizeEmail,(select GPROTIN_EmailAddress from tbl_GPRO_TIN_EmailAddresses where Tin_CMSAttestYear=@CMSYear and Modifiedby=82 and GPROTIN=c.TIN)) as FinalizeEmail

,e.Finalize_Year,
case when (select COUNT(*) from  tbl_Tin_NPI_90Days_Check B  Where B.TIN=c.TIN and B.CMSYear=@CMSYear and B.is90Days_Checked =1 AND B.NPI is null) >0 then 1 else 0 end as islock 
from @facilitytins C left join tbl_CMS_Finalization e on c.TIN = e.TIN  
where e.Finalize_Year = @CMSYear or e.Finalize_Year is null
delete from @facilitytins
END

--exec [dbo].[spTinFinalize_90DaysLock] 2017,'wicadmin',82
