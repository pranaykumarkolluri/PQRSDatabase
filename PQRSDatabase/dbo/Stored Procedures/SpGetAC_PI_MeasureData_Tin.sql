-- =============================================
-- Author:		RAJU J
-- Create date:     Oct 22, 2018,
-- Description:	get pi and ia measure data for cms integration
-- =============================================
CREATE PROCEDURE  [dbo].[SpGetAC_PI_MeasureData_Tin] 
	-- Add the parameters for the stored procedure here
	 @TIN varchar(9),
	 @CMSYear int
AS
BEGIN
declare @IAStartDate datetime
declare @IAEndDate datetime
declare @PIStartDate datetime
declare @PIEndDate datetime
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
  select @PIStartDate=Min(Start_Date) ,  @PIEndDate=Max(End_Date)  from tbl_User_Selected_ACI_Measures
 where Selected_Id  in (select Selected_id from tbl_ACI_Users where CMSYear=@CMSYear
  and TIN=@TIN)

  select  @IAStartDate= Min(StartDate) , @IAEndDate=Max(EndDate)  from tbl_IA_User_Selected
 where selectedid  in (select SelectedID from tbl_IA_Users where CMSYear=@CMSYear
  and TIN=@TIN)

select distinct  s.Selected_MeasureIds,
s.Denominator,
s.Numerator,
s.Attestion,
I.TIN,
I.CMSYear,
'PI' as Category ,

@PIStartDate as StarDate
,@PIEndDate as EndDate
from tbl_TIN_GPRO T
join tbl_ACI_Users I on T.TIN=I.TIN
join tbl_User_Selected_ACI_Measures s on s.Selected_Id=i.Selected_Id
where I.CMSYear=@CMSYear and T.is_GPRO=1 
and I.TIN=@TIN 

union 

select distinct s.SelectedActivity as Selected_MeasureIds,
'' as Denominator,
'' as Numerator,
'' as Attestion,
I.TIN,
I.CMSYear,
'IA' as Category, 
@IAStartDate as StartDate,
@IAEndDate as EndDate
from tbl_TIN_GPRO T
join tbl_IA_Users I on T.TIN=I.TIN
join tbl_IA_User_Selected s on s.SelectedID=i.SelectedID
where I.CMSYear=@CMSYear and T.is_GPRO=1 	
and  I.TIN=@TIN
END



