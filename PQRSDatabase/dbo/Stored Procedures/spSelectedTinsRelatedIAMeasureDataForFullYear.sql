
-- =============================================
-- Author:		Pavan A
-- Create date: 26-nov-21
-- Description:	Getting the all tins realted IA measure data 
--======================================================
CREATE PROCEDURE [dbo].[spSelectedTinsRelatedIAMeasureDataForFullYear]
	-- Add the parameters for the stored procedure here

   @CMSYear int,
   @isExport bit,
   @tbl_CI_Tins_Type tbl_CI_Tins_Type Readonly
AS
BEGIN

	select distinct
		U.TIN as TIN,
		SelectedActivity as Selected_Activity
--		D.ActivityDescription as Description,
--		D.Weighing as ActivityWeighing,
--		S.attest as IsAttested
	from @tbl_CI_Tins_Type T join tbl_IA_Users U on T.Tin = U.TIN
	join tbl_IA_User_Selected s on s.SelectedID = U.SelectedID  
	join tbl_IA_User_Selected_Categories C on C.ID = U.SelectedID
	join Tbl_IA_Data D on D.ActivityID = s.SelectedActivity
	where s.CMSYear = @CMSYear and IsGpro = 1

END





