
-- =============================================
-- Author:		Raju Gaddam
-- Create date: March 15,2018
-- Description:	 Get StartDate and End Date Based on seletion id for IA 
-- JIRA#785  -- change by raju g
-- =============================================
CREATE PROCEDURE [dbo].[spGetStartEndDateForACI]

@CMSYear int,
@TIN varchar(9),
@NPI varchar(10),
@isGpro bit
AS
BEGIN
if(@isGpro=1)
begin
select Min(Start_Date) as StartDate, Max(End_Date) as EndDate from tbl_User_Selected_ACI_Measures
 where Selected_Id  in (select Selected_id from tbl_ACI_Users where CMSYear=@CMSYear
  and TIN=@TIN
  and ((@CMSYear >=2020 and IsGpro=1) or @CMSYear <2020 )  --JIRA#785
  )

end
else
begin
select Min(Start_Date) as StartDate, Max(End_Date) as EndDate from tbl_User_Selected_ACI_Measures
  where Selected_Id in (select Selected_id from tbl_ACI_Users where CMSYear=@CMSYear
  and TIN=@TIN 
  and NPI =@NPI
  and NPI is not null --JIRA#785
  )
end
END

