-- =============================================
-- Author:		Sumanth Sandesari
-- Create date: <Feb 15,17>
-- Description:	<this is help to get tin related finalize data and we can check wheather 90days checked or not>
-- =============================================
CREATE PROCEDURE [dbo].[spTinNpiFinalize_90DaysLock]
	-- Add the parameters for the stored procedure here
@TIN varchar(9),
@CMSYear int ,
@facilityuseranme varchar(100)


AS
BEGIN

declare @facilitynpis table(Npi varchar(11),FirstName varchar(50),LastName varchar(50),Tin varchar(9),isgpro bit)

insert into @facilitynpis exec  [dbo].sp_getNPIsOfTin @TIN


declare @selectedfacilitynpis table(firstname varchar(50), lastname varchar(50),npi varchar(11))

insert into @selectedfacilitynpis exec sp_getFacilityManagedPhysicianNPIs @facilityuseranme 


select distinct c.FirstName,c.LastName,c.Npi ,
e.FinalizeAgreeTime,
e.FinalizeDisagreeTime,
ISNULL(e.FinalizeEmail,(select GPROTIN_EmailAddress from tbl_GPRO_TIN_EmailAddresses where Tin_CMSAttestYear=@CMSYear and Modifiedby=82 and GPROTIN=@TIN)) as FinalizeEmail

,e.Finalize_Year
,case when (select COUNT(*) from  tbl_Tin_NPI_90Days_Check B  Where B.TIN=e.TIN and B.CMSYear=@CMSYear and B.is90Days_Checked =1 AND B.NPI=c.Npi) >0 then 1 else 0 end as islock 


from @facilitynpis c inner join @selectedfacilitynpis d on c.Npi=d.npi
left join tbl_CMS_Finalization e on d.npi = e.NPI
where e.Finalize_Year = @CMSYear or e.Finalize_Year is null


delete from @facilitynpis

delete from @selectedfacilitynpis

END
