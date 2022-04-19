-- =============================================
-- Author:		hari j
-- Create date: 2/1/18
-- Description:	this is getting the files which are in pending status using API for the validation process.
--   
--exec spLockPendingFilesforExamAPI               
-- =============================================
CREATE PROCEDURE [dbo].[spLockPendingFilesforExamAPI]

@excelFilename varchar(100)=''
AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

	Declare @GUI [uniqueidentifier]
	Declare @mytime datetime

	DECLARE @intErrorCode INT

	select @mytime=DATEADD(mi,-5,getdate())
		 
		  Begin transaction
		  set @GUI=NEWID()

		   insert into 
		  tbl_PendingFilesAPI-- make FILE_id as ForeignKey for this table
		  select ID,@GUI,getdate() from tbl_PQRS_FILE_UPLOAD_HISTORY where 
		  UPLOAD_END_DATE_TIME < @mytime and 
		  STATUS='Pending' and FILE_NAME=   Case  isnull(@excelFilename,'')  when ''  then FILE_NAME else @excelFilename end 
		  
		   
		   update tbl_PQRS_FILE_UPLOAD_HISTORY
		   set 
		   STATUS = 'PreProcessingLock'
		   ,Load_Start_Time = getdate()
		   where STATUS='Pending' AND Id in (select Id from tbl_PendingFilesAPI where GUI=@GUI)

           SELECT @intErrorCode = @@ERROR
           IF (@intErrorCode <> 0) GOTO PROBLEM

		   Commit transaction
		  
        PROBLEM:
        IF (@intErrorCode <> 0) BEGIN
        PRINT 'Unexpected error occurred!'
        ROLLBACK TRAN
        END

          set nocount off
           select FILE_NAME,[UserID],UPLOAD_END_DATE_TIME,isFacility from tbl_PQRS_FILE_UPLOAD_HISTORY WHERE STATUS = 'PreProcessingLock' AND ID IN (select Id from tbl_PendingFilesAPI where GUI=@GUI) order by ID 
		 delete from tbl_PendingFilesAPI where GUI=@GUI

	return @@Rowcount

  
END



