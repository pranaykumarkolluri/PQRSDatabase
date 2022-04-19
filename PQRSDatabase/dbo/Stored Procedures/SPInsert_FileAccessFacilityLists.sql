-- =============================================
-- Author:		Hari J
-- Create date: Jan 11th,2019
-- Description:	Bulk insert of file related fecilityids 
-- =============================================
CREATE PROCEDURE [dbo].[SPInsert_FileAccessFacilityLists]
	@FileID int,
	@tblFileAccessFacilityList_Type tblFileAccessFacilityList_Type readonly
AS
BEGIN


INSERT into tblFileAccessFacilityList

SELECT DISTINCT @FileID,FacilityId from @tblFileAccessFacilityList_Type

END
