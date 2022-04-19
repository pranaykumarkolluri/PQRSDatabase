-- =============================================
-- Author:		Sumanth 
-- Create date: 16 April 2019
-- Description:	Used to Delete Data based on KeyId
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_DeleteMeasureData]
@KeyId int
AS
BEGIN
	--  Delete from tbl_CI_Measure_Data where KeyId=@KeyId
	Delete from tbl_CI_Measuredata_value where KeyId=@KeyId


	delete from tbl_CI_Source_UniqueKeys where Key_Id=@KeyId
END



