-- =============================================
-- Author:		HARIKRISHNA J on 09-06-2018
-- Description:	IF we miss any facilityIDs in tblFileAccessFacilityList in between date range it will helpful
-- =============================================
CREATE PROCEDURE SPBackendHandling_tblFileAccessFacilityList
	-- Add the parameters for the stored procedure here
	@StartDate DateTime,
	@EndDate DateTime
AS
BEGIN
     declare @FacilityIDs table(FacilityID int);
	declare @UserName as varchar(50);
	declare @UserID as INT;
	declare @FileId int;

	DECLARE @CountBeforeDelete int; --Facilityids count based on file id in tblFileAccessFacilityList_Back
	DECLARE @CountAfterInsert int;--Facilityids count based on file id in tblFileAccessFacilityList_Back

	---SELECT * into tblFileAccessFacilityList_Back_06_09_2018 from tblFileAccessFacilityList ---backup the table




	--CURSER STARTS
	declare FileID_UserNameData CURSOR FOR
	    


    --STEP #1: Getting Effected  FILEIDs to UPDATE into tblFileAccessFacilityList_Back
     select U.UserName,p.ID,p.UserID from tbl_PQRS_FILE_UPLOAD_HISTORY P  with(nolock)  inner JOIN tbl_Users U  with(nolock) 

     ON P.UserID=U.UserID where P.UPLOAD_START_DATE_TIME >= @StartDate and  P.UPLOAD_START_DATE_TIME < @EndDate and ISNULL(P.UserID ,'')<>''


	  --- ON P.UserID=U.UserID where P.UPLOAD_START_DATE_TIME >= '2018-08-17' and  P.UPLOAD_START_DATE_TIME < '2018-08-19' and ISNULL(P.UserID ,'')<>''



    OPEN FileID_UserNameData

    
    FETCH NEXT FROM FileID_UserNameData INTO  @UserName, @FileId,@UserID

    WHILE @@FETCH_STATUS=0

    BEGIN
     -----------------INSide Cursor STARTS------------------------------
	PRINT '-----------Curser Started with FileId : '+ CAST(@FileId AS VARCHAR) +' ,UserId :'+CAST(@UserID AS VARCHAR)+' and UserName : '+CAST(@UserName AS VARCHAR) +'--------------------'

	SET @CountBeforeDelete=0;
	SET @CountAfterInsert=0;

	--STEP #2: Getting the Actual Facility IDs from NRDR using UserName
     DELETE from @FacilityIDs
	insert into @FacilityIDs
     exec nrdr.[dbo].[sp_getFacilityIDbyUsername] @UserName 


	--SELECT @UserName AS UserName,@FileId AS FileId ,* from @FacilityIDs
	--SET @FileId=563

	--STEP #3: Deleteing the existing FileID data in tblFileAccessFacilityList_Back

	SELECT @CountBeforeDelete= COUNT(*) from tblFileAccessFacilityList_Back where FileId=@FileId
	PRINT 'BEFORE DELETE: FileId : '+ CAST(@FileId AS VARCHAR) +' Related FacilityIds Count :'+CAST(@CountBeforeDelete AS VARCHAR)+''

	DELETE from tblFileAccessFacilityList_Back where FileId=@FileId
	--STEP #4:INSETING the FILEID, FacilityIDs data in tblFileAccessFacilityList_Back

	INSERT INTo tblFileAccessFacilityList_Back
	SELECT @FileId,FacilityID from @FacilityIDs


	SELECT @CountAfterInsert= COUNT(*) from tblFileAccessFacilityList_Back where FileId=@FileId
	PRINT 'AFTER INSERT: FileId : '+ CAST(@FileId AS VARCHAR) +' Related FacilityIds Count :'+CAST(@CountAfterInsert AS VARCHAR)+''

	--PRINT '-----------------'
    

  PRINT '-----------Curser Ended with FileId : '+ CAST(@FileId AS VARCHAR) +' ,UserId :'+CAST(@UserID AS VARCHAR)+' and UserName : '+CAST(@UserName AS VARCHAR) +'--------------------'



  FETCH NEXT FROM FileID_UserNameData INTO  @UserName, @FileId,@UserID
  END
  
   
CLOSE FileID_UserNameData;
DEALLOCATE FileID_UserNameData;



END
