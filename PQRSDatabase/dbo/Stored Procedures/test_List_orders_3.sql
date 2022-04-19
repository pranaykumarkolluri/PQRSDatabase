
CREATE PROCEDURE test_List_orders_3 @fromdate datetime AS
   DECLARE @fromdate_copy datetime
   SELECT @fromdate_copy = @fromdate
   SELECT * FROM tbl_PQRS_FILE_UPLOAD_HISTORY WHERE UPLOAD_START_DATE_TIME > @fromdate_copy
