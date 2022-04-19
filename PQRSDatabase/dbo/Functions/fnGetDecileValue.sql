-- =============================================
-- Author:		HARI
-- Create date: <Create Date, ,>
-- Description:Geting the decile value 
--change #2: Dec 6,2018
--change #2: Jira #609--re changed logic 
--change #2: Feb 11,2019  by HARI
--change #3: Jira #655--if no measure or no value assigned for measure in lookup decile data, returning 'not available' message
--change #4: Aug,30 2019 by hari
--change #4: JIRA#723
-- =============================================
 CREATE FUNCTION [dbo].[fnGetDecileValue]
(
   
   @measure_num as varchar(50),
   @performance_rate as float,
   @CMSYear as int
)
RETURNS varchar(100) -- or whatever length you need
AS
BEGIN
  declare @decile_Val as varchar(100);

 --March 16, 2018 King - round performance rate to 2 decimal
 set @performance_rate = round(@performance_Rate,2)

 IF EXISTS (select * from tbl_Lookup_Decile_Data where Measure_num=@measure_num
 and CMSYear=@CMSYear
 )
  begin
    select  
@decile_Val = 
isnull(
case Is_Low_to_High
 when 1 then 

case 
when  @Performance_rate < Decile_3_from then '3 Points'
when  @Performance_rate >= Decile_3_from and @Performance_rate <= Decile_3_to then 'Decile 3'
when  @Performance_rate >= Decile_4_from and @Performance_rate <= Decile_4_to then 'Decile 4'
when  @Performance_rate >= Decile_5_from and @Performance_rate <= Decile_5_to then 'Decile 5'
when  @Performance_rate >= Decile_6_from and @Performance_rate <= Decile_6_to then 'Decile 6'
when  @Performance_rate >= Decile_7_from and @Performance_rate <= Decile_7_to then 'Decile 7'
when  @Performance_rate >= Decile_8_from and @Performance_rate <= Decile_8_to then 'Decile 8'
when  @Performance_rate >= Decile_9_from and @Performance_rate <= Decile_9_to then 'Decile 9'
when  @Performance_rate >= Decile_10_from and @Performance_rate <= Decile_10_to then 'Decile 10'
when  @Performance_rate > Decile_10_to then '3 Points'
end
when 0 then 

case 
when  @Performance_rate > Decile_3_from then '3 Points'
when  Decile_3_from >= @Performance_rate  and @Performance_rate >= Decile_3_to then 'Decile 3'
when  Decile_4_from >= @Performance_rate  and @Performance_rate >= Decile_4_to then 'Decile 4'
when  Decile_5_from >= @Performance_rate and @Performance_rate >= Decile_5_to then 'Decile 5'
when  Decile_6_from >= @Performance_rate and @Performance_rate >= Decile_6_to then 'Decile 6'
when  Decile_7_from >= @Performance_rate and @Performance_rate >= Decile_7_to then 'Decile 7'
when  Decile_8_from >= @Performance_rate and @Performance_rate >= Decile_8_to then 'Decile 8'
when  Decile_9_from >= @Performance_rate and @Performance_rate >= Decile_9_to then 'Decile 9'
when  Decile_10_from >= @Performance_rate and @Performance_rate >= Decile_10_to then 'Decile 10'
when  @Performance_rate < Decile_10_to then '3 Points' end

end,
'3 Points')
 from [dbo].[tbl_Lookup_Decile_Data] where 
 Measure_num = @measure_num 
 and Submission_Method IN ('Registry/QCDR','MIPS CQM', 'QCDR measure')--change #4: 
 and CMSYear=@CMSYear --added by hari on Aprit/11/2018
--select @decile_Val ,* from [dbo].[Tbl_Decile_Lookup_Data] where Measure_num = '1' and Submission_Method = 'Claims'
    

    end
    else
    begin
  -- SET @decile_Val='NoMeasure'
  SET @decile_Val='not available'    --Change #1
    end

	if(@CMSYear>=2018 and @decile_Val='3 Points')     --change #2:
	begin
	set @decile_Val='not available' --change#3
	end


    RETURN  @decile_Val

END


