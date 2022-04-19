
-- =============================================
-- Author:		hari j
-- Create date: Jan 3ed,2019
-- Description:	added year wise conditons for decile
--change#1: hari Feb, 11th, 2019
--change#1: @TotalExamsCount not required 
-- =============================================
CREATE FUNCTION [dbo].[fnYearwiseDecileLogic]
(
	-- Add the parameters for the function here
 @strMeasure_num as varchar(50),
   @performanceRate as float,
   @intCurActiveYear as int,
   @reportingRate as float,
   @TotalExamsCount as int
)
RETURNS varchar(100)
AS
BEGIN
	-- Declare the return variable here
	declare @decile_Val as varchar(100);

	 IF(@intCurActiveYear <=2017)
						BEGIN
														
				--Change #13
			 SET @decile_Val=NULL
				  IF((@reportingRate < 50 ) and (@reportingRate is not null ) )
				 begin
				SET @decile_Val='3 Points'
				 end
				 else if(@reportingRate >= 50)
				 begin
				 -- call function fnGetDecileValue
				select @decile_Val= dbo.fnGetDecileValue(@strMeasure_num,@performanceRate,@intCurActiveYear) --change# 20
				 select @decile_Val=ISNULL(@decile_Val,'3 Points')
				 end


				END



				ELSE IF(@intCurActiveYear >= 2018)--Change #23
				BEGIN

				 SET @decile_Val=NULL
				-- IF(((@reportingRate < 60 ) and (@reportingRate is not null ) )OR  (@TotalExamsCount < 20))
				  IF(((@reportingRate < 60 ) and (@reportingRate is not null ) ))
				 begin
				  SET @decile_Val='1 Point'
				 end
				 --else if(@reportingRate >= 60)

				 -- 20191106 King Lo - find the decile value even if reporting rate is not available
				  else if ((@reportingRate >= 60) or (@reportingRate is null))
				 begin
				 -- call function fnGetDecileValue
				select @decile_Val= dbo.fnGetDecileValue(@strMeasure_num,@performanceRate,@intCurActiveYear) --change# 20
				
				-- select @decile_Val=ISNULL(@decile_Val,'1 Point')
				 end

				END


	-- Return the result of the function
	RETURN @decile_Val

END
