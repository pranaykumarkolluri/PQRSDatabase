
-- =============================================
-- Author:		raju G
-- Create date: 10-1-2021
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpInsertHitrustEventData] 
	@EventData varchar(max),
	@CreatedBy int
    
AS
BEGIN

	INSERT INTO [dbo].[Tbl_Hitrust_EventLogs]
           ([EventData]
           ,[CreatedDate]
           ,[CreatedBy])
     VALUES
           (@EventData,
           GETDATE()
           ,@CreatedBy
		   
		   )

END

