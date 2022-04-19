-- =============================================
-- Author:		Raju Gaddam
-- Create date: March 14,2018
-- Description:	 Get StartDate and End Date Based on seletion id for IA or ACI.
-- =============================================
CREATE PROCEDURE spGetStartEndDateForIAorACI
@isIA bit,
@SelectionId int
AS
BEGIN
if(@isIA=1)
begin
select Min(StartDate) as StartDate, Max(EndDate) as EndDate from tbl_IA_User_Selected where SelectedID=@SelectionId

end
else
begin
select Min(Start_Date) as StartDate, Max(End_Date) as EndDate from tbl_User_Selected_ACI_Measures where Selected_Id=@SelectionId
end

END
