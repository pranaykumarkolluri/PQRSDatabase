-- =============================================
-- Author:		Raju
-- Create date: 
-- Description:	Get Measures list by Rule
-- =============================================
CREATE PROCEDURE [dbo].[SPGetMeasureslistByRuleId]
	
@RuleId int,@CMSYear int
AS
BEGIN


IF(@RuleId=1)--///Mandatory_Diagnos_Code
BEGIN
select Measure_Num as Measure, Measure_num as Value FROM tbl_Lookup_Measure Where Mandatory_Diagnos_Code=1 and CMSYear=@CMSYear order by DisplayOrder
END
ELSE IF(@RuleId=2)
BEGIN
select Measure_Num as Measure, Measure_num+' '+Measure_Scoring as Value FROM tbl_Lookup_Measure Where CMSYear =@CMSYear order by Measure_Scoring 
END

ELSE IF(@RuleId=3)
BEGIN
select Measure_Num as Measure, Measure_num + ' ' + Gender_Restriction as Value FROM tbl_Lookup_Measure Where (Gender_Restriction<>'NA' and Gender_Restriction is not null) and CMSYear =@CMSYear order by DisplayOrder
END

ELSE IF(@RuleId=4)
BEGIN

select Measure_Num as Measure, M.Measure_num+' - '+
  STUFF((SELECT ', ' + CAST(cast(cast(dr.acceptable_date_start as date) as varchar(50)) +'  '+ cast( cast(dr.acceptable_date_end as date) as varchar(50)) AS VARCHAR(50)) [text()] 
        from tbl_Lookup_Acceptable_DateRange dr where dr.Measure_ID =M.Measure_ID
   
         FOR XML PATH(''), TYPE)
        .value('.','NVARCHAR(MAX)'),1,2,' ') as Value 


from tbl_Lookup_Measure M where M.CMSYear=@CMSYear and M.IsAcceptableDateRange=1 order by DisplayOrder
--select m.Measure_num +' ('+cast(cast(dr.acceptable_date_start as date) as varchar(50))+'-'+cast(cast(dr.acceptable_date_end as date) as varchar(50)) +')' from tbl_Lookup_Measure m join tbl_Lookup_Acceptable_DateRange dr on m.Measure_num=dr.Measure_Num and m.IsAcceptableDateRange=1 and m.CMSYear=dr.CMSYear where m.CMSYear=@CMSYear

END

ELSE IF(@RuleId=5)
BEGIN
select Measure_Num as Measure, Measure_num as Value FROM tbl_Lookup_Measure Where IsStratum_Required =1 and CMSYear=@CMSYear order by DisplayOrder
END


ELSE IF(@RuleId=6)
BEGIN
 select Measure_Num as Measure, m.Measure_num +'  '+p.Name as Value from tbl_Lookup_Measure m join tbl_Lookup_Measure_Priority p on m.Priority_ID=p.Priority_ID and m.CMSYear=2019 where m.Priority_ID is not null order by DisplayOrder
END


ELSE IF(@RuleId=7)
BEGIN
select Measure_Num as Measure, Measure_num as Value FROM tbl_Lookup_Measure Where Is_DiagCodeAsKey =1 and CMSYear=@CMSYear order by DisplayOrder
END


ELSE IF(@RuleId=8)
BEGIN
 select Measure_Num as Measure, M.Measure_num+' - '+
  STUFF((SELECT ', ' + CAST(a.Avg_MeasureName AS VARCHAR(10)) [text()]
        from tbl_lookup_Measure_Average A where A.Measure_Id=M.Measure_ID
   
         FOR XML PATH(''), TYPE)
        .value('.','NVARCHAR(MAX)'),1,2,' ') as Value


from tbl_Lookup_Measure M where M.CMSYear=@CMSYear and M.Is_AvgMeasure=1 order by DisplayOrder

END


ELSE IF(@RuleId=9)
BEGIN
select distinct Measure_Num as Measure, Measure_num as Value from tbl_lookup_Denominator_Proc_Code where Denominator_Exclusion=1 and CMSYear=@CMSYear 
END


ELSE IF(@RuleId=10)
BEGIN
select distinct Measure_Num as Measure, Measure_num as Value from tbl_lookup_Denominator_Proc_Code where (Gender_Exclusion is not null and Gender_Exclusion<>'NA') and CMSYear=@CMSYear

END


ELSE IF(@RuleId=11)
BEGIN
select distinct Measure_Num as Measure, Measure_num as Value from tbl_lookup_Denominator_Proc_Code where Atleast_Condition_226 is not null and CMSYear=@CMSYear
END


ELSE IF(@RuleId=12)
BEGIN
select distinct Measure_Num as Measure, Measure_num as Value from tbl_lookup_Denominator_Proc_Code where Proc_Criteria is not null and CMSYear=@CMSYear

END
ELSE IF(@RuleId=13)
BEGIN
select distinct Measure_Num as Measure,Measure_num as Value from tbl_Lookup_Denominator_Diag_Code where Denominator_Exclusion is not null and CMSYear=@CMSYear

END
ELSE IF(@RuleId=14)
BEGIN
select MeasureId as Measure, MeasureId  as Value  from tbl_Lookup_ACI_Data where ACI_Id=3 and CMSYear=@CMSYear
END
ELSE IF(@RuleId=15)
BEGIN
select distinct Measure_Num as Measure, Measure_Num as Value from tbl_lookup_Numerator_Code where Criteria is not null and CMSYear=@CMSYear
END
ELSE IF(@RuleId=16)
BEGIN
select Measure_Num as Measure,  Measure_Num as Value from tbl_Lookup_Measure where Is_eCQM=1 and CMSYear=@CMSYear order by DisplayOrder 
END



END
