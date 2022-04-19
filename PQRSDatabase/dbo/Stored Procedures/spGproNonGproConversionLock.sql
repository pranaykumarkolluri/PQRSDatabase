-- =============================================
-- Author:		Raju Gaddam
-- Create date: <Feb 15,17>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGproNonGproConversionLock]
	-- Add the parameters for the stored procedure here
@CMSYear int ,
@facilityuseranme varchar(100)
AS
BEGIN
declare @facilitytins table(TIN varchar(9) , IS_GPRO bit)
delete from @facilitytins
insert into @facilitytins exec  [dbo].[sp_getFacilityTIN_GPRO] @facilityuseranme

select C.TIN,
C.IS_GPRO, 
case 
when (select COUNT(*) from  tbl_TINConvertion_Lock B  Where B.TIN=C.TIN and B.CMSYear=@CMSYear and C.IS_GPRO=1 and b.NPI is null and (B.isACIFinalize =1 or B.isIAFinalize=1 or B.isQMFinalize=1)) >0 then 1
 when (select COUNT(*) from  tbl_TINConvertion_Lock B  Where B.TIN=C.TIN and B.CMSYear=@CMSYear  and c.IS_GPRO=0 and b.NPI is not null  and (B.isACIFinalize =1 or B.isIAFinalize=1 or B.isQMFinalize=1)) >0 then 1
  
 else 0 end as islock
from @facilitytins C 
END
