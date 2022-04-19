-- =============================================
-- Author:		HARI J
-- Create date: 12 June 2019
-- Description: Used to get tbl_ApiRequstedFilesList details based on FileId & ReqId
-- =============================================
CREATE PROCEDURE SPGetProcessRecordCount
	-- Add the parameters for the stored procedure here
	@FileId int,
	@ReqId int
AS
BEGIN
IF(@ReqId >0)
BEGIN
		SELECT  [Id]
			  ,[ReqId]
			  ,[FileId]
			  ,[ProcessedRecords]
			  ,[CountUpdateOn]
			  ,[Status_CnstID]
			  ,[isValidationState]
			  ,[Validation_StartDate]
			  ,[Validation_UpdateDate]
		  FROM [tbl_ApiRequstedFilesList] with(nolock) where FileId=@FileId and ReqId=@ReqId
  END
  ELSE
  BEGIN
       SELECT TOP 1   [Id]
			  ,e.[ReqId]
			  ,[FileId]
			  ,[ProcessedRecords]
			  ,[CountUpdateOn]
			  ,e.[Status_CnstID]
			  ,[isValidationState]
			  ,[Validation_StartDate]
			  ,[Validation_UpdateDate]
		  FROM tbl_ApiRequestFileProcessHistory e with(nolock) join
		   [tbl_ApiRequstedFilesList] f with(nolock) on e.ReqId=f.ReqId and e.Process_CnstID=4		   
		    where FileId=@FileId order by Id desc
  END
END
