
-- =============================================
-- Author:		<Hari>
-- Create date: <08-03-2018>
-- Description:	<hide the finalized tins in drop down in ACI>
-- =============================================
CREATE procedure [dbo].[sp_getFacilityUnFinializedTins_ACI]
(@facilityusername varchar(50),@CMSYear int)
as
begin
declare @facilityfinializetins table(TIN varchar(9), IS_GPRO bit)

insert into @facilityfinializetins
exec sp_getFacilityTIN_GPRO @facilityusername

select * from @facilityfinializetins where Tin not in (
select tin from tbl_CMS_ACI_Finalization where Finalize_Year=@CMSYear 
and isFinalize=1
and isGpro=1
)
--select * from @facilityfinializetins
end
