-- =============================================
-- Author:		Raju G
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPGetMeasureslistByRuleIdCompare]
	@RuleId int,
	@CompareYear int,
	@CurrentYear int
AS
BEGIN



declare @CurrentMes  table(Measure varchar(256), Value varchar(max)) 
declare @CompareMes table(Measure varchar(256), Value varchar(max)) 
insert into @CurrentMes
exec SPGetMeasureslistByRuleId @RuleId,@CurrentYear

insert into @CompareMes
exec SPGetMeasureslistByRuleId @RuleId,@CompareYear


select  P.Value as CompareMeasures ,C.Value as CurrentMeasures from  @CurrentMes C  inner join @CompareMes P on C.Measure=P.Measure 
union

select P.Value as  CompareMeasures ,'--' as CurrentMeasures  from @CompareMes P where P.Measure not in (select Measure from @CurrentMes) 
union

select '--' as  CompareMeasures ,C.Value as CurrentMeasures  from @CurrentMes C where C.Measure not in (select Measure from @CompareMes) 

END
