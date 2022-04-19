

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- create for migrating .net core
-- =============================================
CREATE FUNCTION [dbo].[DecimalToStringConvert]
(
	-- Add the parameters for the function here
	@value decimal(18,10)
	
)
RETURNS varchar(10)
AS
BEGIN
declare @str varchar(10)='';


set @str= Convert(varchar(10),convert(decimal(10,2), @value)); 
RETURN @str;

END


