-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE GetExcelSelectQuery
@SheetName varchar(250)
AS
BEGIN
declare @Query varchar(max);
set @Query ='Select* from ['''+@SheetName+''']';
select @Query;
END
