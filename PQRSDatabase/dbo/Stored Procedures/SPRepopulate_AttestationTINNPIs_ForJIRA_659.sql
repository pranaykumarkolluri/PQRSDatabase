-- =============================================
-- Author:		HARIKRISHNA J
-- Create date: 29TH, MAR -2019
-- Description: REPOPULATING THE TIN/NPIS IN tbl_Attestation_TINNPIS on before  '2019-03-10 00:00:00'(i.e 5.6.10 release date)
--COMMENTS: JIRA#659:We should correct the data, make some script and assign all previously loaded authorization files to all corresponding TINs and NPIs
-- =============================================
CREATE PROCEDURE [dbo].[SPRepopulate_AttestationTINNPIs_ForJIRA#659]
	
AS
BEGIN
	

	  DECLARE @PreviouFilesDate as DATETIME ='2019-03-10 00:00:00' --considering this date on before 5.6.10 release
	  DECLARE  @FileId int
	  DECLARE  @UserId int
	  DECLARE @CreatedDate datetime;

	  ---BACKUP THE tbl_Attestation_TINNPIS 
	    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = N'tbl_Attestation_TINNPIS_BACKUP_FORJIRA#659')
		  BEGIN
		      SELECT * INTO tbl_Attestation_TINNPIS_BACKUP_FORJIRA#659 FROM tbl_Attestation_TINNPIS WHERE FileId IN (
                                                               SELECT [FileId]
        
	                                                          FROM tbl_AttestationFiles 
												   WHERE CreateDate < @PreviouFilesDate 
												   AND IsActive=1)

		  END
	


	  -----------------FILEs Cursor STARTS------------------------------

    DECLARE CurFiless CURSOR FOR

    SELECT [FileId]
        ,[CreatedBy]
	   ,CreateDate

	   FROM tbl_AttestationFiles WHERE CreateDate < @PreviouFilesDate and IsActive=1

    OPEN CurFiless

    FETCH NEXT FROM CurFiless INTO @FileId,@UserId,@CreatedDate

    WHILE @@FETCH_STATUS=0

    BEGIN
     PRINT 'Files Cursor Started with  File: ' + CAST(@FileId AS VARCHAR(10));

   DECLARE @CreatedBy varchar(100);
   DECLARE @FACILITYTINS_NPIS TABLE(first_name varchar(100),lastname varchar(100),npi varchar(11),tin varchar(10))


    SELECT TOP 1 @CreatedBy=UserName FROM tbl_Users 
                                     WHERE UserID=@UserId 

    INSERT INTO @FACILITYTINS_NPIS EXEC sp_getFacilityPhysicianNPIsTINs  @CreatedBy

    --Deleting the previous records for that fileid
    DELETE FROM tbl_Attestation_TINNPIS WHERE FileId=@FileId


    ---REPOPULATE TIN/NPIS FOR EFFECTED FILEID
    INSERT INTO tbl_Attestation_TINNPIS
    (
    FileId
    ,TIN
    ,NPI
    ,CreateDate
    ,CreatedBy
    )

    SELECT DISTINCT  @FileId,F.TIN,F.NPI,@CreatedDate,@UserId  FROM  @FACILITYTINS_NPIS F 
  


    FETCH NEXT FROM CurFiless INTO @FileId,@UserId,@CreatedDate
    
    END

    CLOSE CurFiless;
    DEALLOCATE CurFiless;

     -----------------Files Cursor END------------------------------


END

