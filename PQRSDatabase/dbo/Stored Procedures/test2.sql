CREATE PROCEDURE test2
@nam varchar(10)
AS
BEGIN
EXEC test1 @name=@nam
END






