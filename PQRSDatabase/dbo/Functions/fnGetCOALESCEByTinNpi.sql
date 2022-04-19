



-- =============================================
-- Author:		Hari 
-- Create date: 22 march 2019
-- Description:	Used to get comma seperated values --1=Homepage,2=IA Result,3=PI result
-- =============================================
 CREATE FUNCTION [dbo].[fnGetCOALESCEByTinNpi]
(
   
@TIN VARCHAR(9),
@npi VARCHAR(10),
@Cmsyear int,
@ResultType int --1=Homepage,2=IA Result,3=PI result
)
RETURNS VARCHAR(MAX) -- or whatever length you need
AS
BEGIN
DECLARE @RECORDS VARCHAR(MAX)
  
  if(@ResultType=1)
  BEGIN

(SELECT @RECORDS= COALESCE(@RECORDS+ ', ', '')+ CAST((CONVERT(VARCHAR(MAX),A.CMS_Year)+':'+(CASE WHEN A.TotalCount IS NOT NULL AND A.TotalCount >0 THEN CONVERT(varchar(50), A.TotalCount) ELSE '' END)) AS VARCHAR(50)) FROM tbl_Physian_Tin_Count A WHERE A.TIN=@TIN AND A.NPI=@npi )
order by CMS_Year desc
SET @RECORDS=ISNULL(@RECORDS,'No Records')
END

ELSE IF(@ResultType=2)
BEGIN
select  
  @RECORDS=COALESCE(@RECORDS+', ' ,'') + SelectedActivity--,i.NPI,i.TIN

from 
 tbl_IA_Users I 
join tbl_IA_User_Selected S on S.SelectedID =I.SelectedID 
where I.CMSYear=@Cmsyear 
--and I.NPI =p.NPI 
and I.NPI=@npi  
--and ISNULL(I.NPI,'')= case when @IsGpro=1 then '' else @npi end
and I.TIN=@TIN
END

ELSE IF(@ResultType=3)
BEGIN
select  
  @RECORDS=COALESCE(@RECORDS+', ' ,'') + Selected_MeasureIds--,i.NPI,i.TIN

from 
 tbl_ACI_Users I 
join tbl_User_Selected_ACI_Measures S on S.Selected_Id =I.Selected_Id 
where I.CMSYear=@Cmsyear 
--and I.NPI =p.NPI   
and I.NPI=@npi
and I.TIN=@TIN
END



RETURN @RECORDS

END


