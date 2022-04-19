-- =============================================
-- Author:		raju g
-- Create date: <Create Date,,>
-- Description:	Get Activites, attestation , finalization of IA  information for  gpro tins based on year
-- =============================================
CREATE PROCEDURE [dbo].[spGetIAGPROAttestation_Finalize_Activities]

AS
BEGIN
declare @IAdata table (SelectedActivity varchar(max),TIN varchar(9), CMSYear int,IsAttested bit,isFinalize bit)
insert into 
@IAdata
select distinct s.SelectedActivity,I.TIN,I.CMSYear,
isnull ((select IsAttested from tbl_GPRO_TIN_EmailAddresses where GPROTIN=I.TIN and Tin_CMSAttestYear=I.CMSYear),0),
isnull ((select isFinalize from tbl_CMS_IA_Finalization A where A.TIN = I.TIN and A.Finalize_Year=I.CMSYear and A.NPI is null ),0)
from tbl_TIN_GPRO T
inner join tbl_IA_Users I on T.TIN=I.TIN
inner join tbl_IA_User_Selected s on s.SelectedID=i.SelectedID
where I.CMSYear=2017 
and T.is_GPRO=1 

select distinct tin,cmsyear,case when  IsAttested=0 then 'N' else 'Y' end as IsAttested , case when  isFinalize=0 then 'N' else 'Y' end as isFinalize,
 STUFF((SELECT ', '+ S.SelectedActivity 
    FROM @IAdata S
    WHERE s.TIN=I.TIN
    FOR XML PATH('')),1,1,'') [SelectedActivity]

from @IAdata I
END
