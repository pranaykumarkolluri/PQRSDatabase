CREATE FUNCTION [dbo].[My_ISDATE](@maybeDate varchar(max))
  returns bit
  as 
   Begin
   Declare @flag bit;
   set @flag = ISDATE(@maybeDate);
  return @flag;
  End
