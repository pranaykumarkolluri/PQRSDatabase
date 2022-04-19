CREATE PROCEDURE[dbo].[sp_getFacilityIDbyUsername]
 @UserName nvarchar(256)
 AS
 BEGIN
exec nrdr..sp_getFacilityIDbyUsername @UserName
  return @@rowCount;
 END 
 
