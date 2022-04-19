-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpGetNonGproIA_PI_MeasureData_Tin]
	-- Add the parameters for the stored procedure here
	 @TIN varchar(9),
	 @NPI varchar(10),
	 @CMSYear int
AS
BEGIN
	
declare @IAStartDate datetime
declare @IAEndDate datetime
declare @PIStartDate datetime
declare @PIEndDate datetime

Declare @PhysicinaTins as Table(NPI Varchar(10),
TIN Varchar(9))
INSERT into @PhysicinaTins
select DISTINCT  NPI,TIN from NRDR..[PHYSICIAN_TIN_VW]

-- Below Select Query For IA  
select @IAStartDate= Min(StartDate)
,@IAEndDate= Max(EndDate) 
 from tbl_IA_User_Selected
where selectedid  in (select SelectedID from tbl_IA_Users where CMSYear=@CMSYear
 and TIN=@TIN and NPI=@NPI)

-- Below Select Query For ACI
 select @PIStartDate=Min(Start_Date) ,  @PIEndDate=Max(End_Date)  from tbl_User_Selected_ACI_Measures
where Selected_Id  in (select Selected_id from tbl_ACI_Users where CMSYear=@CMSYear
 and TIN=@TIN and NPI=@NPI)

select distinct  s.Selected_MeasureIds,
s.Denominator,
s.Numerator,
s.Attestion,
I.TIN,
I.NPI,
I.CMSYear,
'PI' as Category ,
@PIStartDate as StartDate,
@PIEndDate as EndDate

--from @PhysicinaTins P 
 
--join tbl_ACI_Users I on P.TIN=I.TIN
from  tbl_ACI_Users I 
join tbl_User_Selected_ACI_Measures S on S.Selected_Id =I.Selected_Id 
where I.CMSYear=@CMSYear 
and I.TIN not in(select TIN from tbl_TIN_GPRO where is_GPRO=1)
and I.TIN=@TIN and I.NPI=@NPI

union 

select distinct s.SelectedActivity as Selected_MeasureIds,
'' as Denominator,
'' as Numerator,
'' as Attestion,
I.TIN,
I.NPI,
I.CMSYear,
'IA' as Category  
,@IAStartDate as StarDate
,@IAEndDate as EndDate
--from @PhysicinaTins P 
--join tbl_IA_Users I on P.TIN=I.TIN
from tbl_IA_Users I
join tbl_IA_User_Selected S on S.SelectedID =I.SelectedID 
where I.CMSYear=@CMSYear 
and I.TIN not in(select TIN from tbl_TIN_GPRO where is_GPRO=1)
and I.TIN=@TIN and I.NPI=@NPI
END
