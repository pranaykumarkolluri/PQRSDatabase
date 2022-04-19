-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SpgetEligibleMeasuresOnAge
	-- Add the parameters for the stored procedure here
	@CMSYear int,
	@Gender_Restriction varchar(5),
	@Age int,
	@examDate datetime

AS
BEGIN
	
	select M.Measure_ID,M.Measure_num,M.Measure_Desc from tbl_Lookup_Measure m 
  left join tbl_Lookup_Acceptable_DateRange a
   on m.Measure_ID=a.Measure_ID 
   where m.CMSYear=@CMSYear
   and m.Allow_Portal_Submit=1
   and m.Age_Restriction_From <= @Age and @Age<= m.Age_Restriction_To
   AND( M.IsAcceptableDateRange=0 OR 
   ( CONVERT(datetime,a.acceptable_date_start,105) <= CONVERT(datetime,@examDate,105)
					and CONVERT(datetime,A.acceptable_date_end,105) >=  CONVERT(datetime,@examDate,105)
					))
END
