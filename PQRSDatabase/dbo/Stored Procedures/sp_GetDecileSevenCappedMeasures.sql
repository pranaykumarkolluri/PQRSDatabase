CREATE PROCEDURE[dbo].[sp_GetDecileSevenCappedMeasures]
 @CmsYear int
 AS
 BEGIN
	select distinct Measure_num from tbl_Lookup_Decile_Data where CMSYear = @CmsYear and SevenPointCap_PY18 = 1 and Measure_num NOT IN ('436')
	union
	select '225'
 END 
 

