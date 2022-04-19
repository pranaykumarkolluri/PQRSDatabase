-- =============================================
-- Author:		raju g
-- Create date: <Create Date,,>
-- Description:	Get Activites, attestation , finalization of IA  information for non gpro tins based on year
-- =============================================
CREATE PROCEDURE [dbo].[spGetIANonGPROAttestation_Finalize_Activities]

AS
BEGIN


declare @NonGPROIAdata table (SelectedActivity varchar(max),TIN varchar(9),NPI varchar(10), CMSYear int,IsAttested bit,isFinalize bit)
insert into @NonGPROIAdata
select distinct S.SelectedActivity,I.TIN,I.NPI,I.CMSYear,
isnull((select IsAttested from tbl_CMS_Attestation_Year where NPI=I.NPI and CMSAttestYear=I.CMSYear),0) as isAttested,
isnull((select isFinalize from tbl_CMS_IA_Finalization where TIN=I.TIN and NPI=I.NPI and Finalize_Year=I.CMSYear),0) as isFinalize
 from tbl_Physician_TIN P 
join tbl_IA_Users I on P.TIN=I.TIN
join tbl_IA_User_Selected S on S.SelectedID =I.SelectedID 
where I.CMSYear=2017 
and I.TIN 
not in(select TIN from tbl_TIN_GPRO where is_GPRO=1)


select distinct tin,npi,cmsyear,case when  IsAttested=0 then 'N' else 'Y' end as IsAttested , case when  isFinalize=0 then 'N' else 'Y' end as isFinalize,
 STUFF((SELECT ','+  S.SelectedActivity  
    FROM @NonGPROIAdata S
    WHERE s.TIN=I.TIN
	and S.NPI=I.NPI
	and S.CMSYear=I.CMSYear
    FOR XML PATH('')),1, 1, '') [SelectedActivity] from @NonGPROIAdata I

END
