CREATE FUNCTION [dbo].[IntToStringConvert]
(
	-- Add the parameters for the function here
	@value int
	
)
RETURNS varchar(50)
AS
BEGIN
declare @str varchar(50)='';


set @str= Convert(varchar(50),@value); 
RETURN @str;

END


