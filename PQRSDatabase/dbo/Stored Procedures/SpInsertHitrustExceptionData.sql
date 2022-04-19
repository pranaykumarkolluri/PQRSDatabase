
-- =============================================
-- Author:		Raju G
-- Create date:18-01-2021
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpInsertHitrustExceptionData] 
  @UserId int ,
  @ExceptionType varchar(256),
  @ExceptionMessage varchar(max)
AS
BEGIN
	INSERT INTO [dbo].[Tbl_Hitrust_Exceptions]
           ([ExceptionType]
           ,[ExceptionMessage]
           ,[CreatedBy]
           ,[CreatedDate])
     VALUES
           (@ExceptionType
           ,@ExceptionMessage
           ,@UserId
           ,GETDATE())

END

