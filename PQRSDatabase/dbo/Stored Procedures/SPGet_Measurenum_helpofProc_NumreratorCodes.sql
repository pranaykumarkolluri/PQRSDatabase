-- =============================================
-- Author:		Hari J
-- Create date:01/08/2018
-- Description:	Filling EXcel/Text file if Measure Num empty while File Upload
-- JIRA-947
-- =============================================
CREATE PROCEDURE [dbo].[SPGet_Measurenum_helpofProc_NumreratorCodes]
	-- Add the parameters for the stored procedure here
	@CMSYear int,
	@Numerator_Code varchar(100),
	@Proc_code varchar(100)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--    select DISTINCT m.Measure_num as Measure_num from tbl_Lookup_Measure m
--inner join  tbl_lookup_Denominator_Proc_Code p on m.Measure_num=p.Measure_num and m.CMSYear=p.CMSYear
--inner join tbl_lookup_Numerator_Code n on m.Measure_num =p.Measure_num  and m.CMSYear=n.CMSYear
--where m.CMSYear=@CMSYear and p.Proc_code=@Proc_code and n.Numerator_Code=@Numerator_Code
set @Proc_code =UPPER(@Proc_code); -- JIRA-947
select DISTINCT  d.measure_num from tbl_lookup_Denominator_Proc_Code d, tbl_lookup_Numerator_Code n 
where d.cmsyear = @CMSYear 
and n.cmsyear = @CMSYear 
and d.measure_num = n.measure_num 
and UPPER(d.proc_code) = @Proc_code  -- JIRA-947
and n.numerator_code = @Numerator_Code 

END


