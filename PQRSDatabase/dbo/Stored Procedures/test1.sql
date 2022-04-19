CREATE PROCEDURE test1

@name varchar(20)='',
@val int=45
AS
BEGIN
Select @name as Name,@val as Value
END

EXEC test1;