-- =============================================
-- Author:		Raju Gaddam
-- Create date: March 15,2018
-- Description:	 Get StartDate and End Date Based on tin,npi,cmsyear.
-- =============================================
CREATE PROCEDURE [dbo].[spGetStartEndDateForIA]

@CMSYear int,
@TIN varchar(9),
@NPI varchar(10),
@isGpro bit

AS
BEGIN
if(@isGpro=1)
begin
select Min(StartDate) as StartDate, Max(EndDate) as EndDate from tbl_IA_User_Selected
 where selectedid  in (select SelectedID from tbl_IA_Users where CMSYear=@CMSYear
  and TIN=@TIN and ((@CMSYear >=2020 and IsGpro=1 and attest=1) or @CMSYear<2020))
  
end
else
begin
select Min(StartDate) as StartDate, Max(EndDate) as EndDate from tbl_IA_User_Selected
 where selectedid  in (select SelectedID from tbl_IA_Users where CMSYear=@CMSYear
  and TIN=@TIN 
  and NPI =@NPI)
end
END
