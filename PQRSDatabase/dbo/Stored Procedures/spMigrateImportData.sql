
-- =============================================
-- Author:		spMigrateImportData
-- Create date: 19 jul 2014
-- Description:	This proc is used to migrate import files with status 2 and with data status 3 , 4
--				and their respective measure data with status 3(this must always be 3!!!!)
--change #1:Hari on 10/01/18
--change #1:--added new logic for insert/update records as file records
--Change #2:Import_Exam_Unique_ID varchar size increased varchar(100) to varchar(500)
-- Change #3:  Hari J
-- Change Date: April 5th, 2019
-- Change Desc:JIRA#684
--Change#3: Hari j,May 3ed 2019
--Change#3: JIRA#694
--Change#4: JIRA#707: Increase the  processing performance of Web-Services
--Change#4 By: Raju G
--Change#5: Hari j,OCT  14th 2019
--Change5#: JIRA#741
--Change#6: Hari j,DEC  14th 2020, JIRA#806 (commented the --Change#3 changes)
--Change#7: JIRA#1103
-- =============================================
CREATE PROCEDURE [dbo].[spMigrateImportData]
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;
             DECLARE @ImportID INT, @examsid INT, @Transaction_ID VARCHAR(100), @PartnerId VARCHAR(100), @Transaction_DateTime VARCHAR(100), @Prev_Transction_ID VARCHAR(100), @Appid VARCHAR(100), @Import_examID INT, @Import_Facility_ID VARCHAR(100), @Import_Physician_Group_TIN VARCHAR(20), @Import_Exam_Unique_ID VARCHAR(500), --Change #2
             @Import_Exam_DateTime VARCHAR(100), @Import_Physician_NPI VARCHAR(20), @Import_First_Name VARCHAR(200), @Import_Last_Name VARCHAR(200), @Import_Patient_ID VARCHAR(50), @Import_Patient_Age VARCHAR(5), @Import_Patient_Gender VARCHAR(2), @Import_Patient_Medicare_Beneficiary VARCHAR(2), @Import_Patient_Medicare_Advantage VARCHAR(2), @Import_isEncrypt BIT;
             DECLARE @ProsTransactionID VARCHAR(100), @prosPrev_Transaction_ID VARCHAR(100);
  -- bug-too small          @prosPrev_Transaction_ID VARCHAR(20)
             DECLARE @tblExam_ExamID AS INT;
             DECLARE @ImportId_max INT; --Change#4
             IF OBJECT_ID('tempdb..#Imports') IS NOT NULL
                 DROP TABLE #Imports;
             CREATE TABLE #Imports
(ImportID INT
 PRIMARY KEY NOT NULL
);
--Change#4
             INSERT INTO #Imports
                    SELECT R.ImportID
                    FROM tbl_Import_Raw R
                    WHERE [R].[status] = 2
                          AND r.Data_Status IN(3, 4);
             SET @ProsTransactionID = '';
             SET @prosPrev_Transaction_ID = '';

  --print('spMigrateImportData_6_6_19 validation-1 started ' +CONVERT( VARCHAR(24), GETDATE(), 113));	
  --Change#4
/*
        IF OBJECT_ID('tempdb..#Imports') IS NOT NULL 
            DROP TABLE #Imports
        CREATE TABLE #Imports
            (
              ImportID INT PRIMARY KEY
                           NOT NULL,
			[Transaction_ID] [varchar](50) NULL,
			[Prev_Transction_ID] [varchar](50) NULL,
			[PartnerId] [varchar](50) NULL,
			[Facility_Id] [varchar](50) NULL,
			[Appid] [varchar](50) NULL,
			ExamsID int null
            )
        INSERT  INTO #Imports
                SELECT 
                        
						R.ImportID,
						Es.Transaction_ID
						,Es.PartnerId
						,Es.Prev_Transction_ID
						,Es.Appid
						,ES.Facility_Id
						,Es.ExamsID
                FROM    tbl_Import_Raw R
                        INNER JOIN tbl_Import_Exams ES ON ES.RawData_Id = R.ImportID and R.ImportID <=@ImportId_max
                        INNER JOIN tbl_Import_Exam e ON e.Import_ExamsID = es.ExamsID
                        INNER JOIN tbl_Import_Exam_Measure_Data m ON m.Import_ExamID = e.Import_examID
                WHERE   ISNULL([R].[status], 0) = 2
                        AND ISNULL(r.Data_Status, 0) IN ( 3, 4 )
						
                        AND ISNULL(e.Status, 0) IN ( 3, 4 )

						*/

--print('spMigrateImportData_6_6_19 validation-2-00 '+CONVERT( VARCHAR(24), GETDATE(), 113));
             SELECT @ImportId_max = MAX(ImportID)
             FROM #Imports; 
--print 'after insert into #imports'
             DECLARE Cursor_MigrateExam_Delete CURSOR
             FOR SELECT R.ImportID,
                        Es.Transaction_ID,
                        Es.PartnerId,
                        Es.Prev_Transction_ID,
                        Es.Appid,
                        ES.Facility_Id,
                        Es.ExamsID
                 FROM tbl_Import_Raw R
                      INNER JOIN tbl_Import_Exams ES ON ES.RawData_Id = R.ImportID
                                                        AND R.ImportID <= @ImportId_max
                        --INNER JOIN tbl_Import_Exam e ON e.Import_ExamsID = es.ExamsID
                        --INNER JOIN tbl_Import_Exam_Measure_Data m ON m.Import_ExamID = e.Import_examID
                 WHERE [R].[status] = 2
                       AND r.Data_Status IN(3, 4)


                      --  AND ISNULL(e.Status, 0) IN ( 3, 4 )
                 ORDER BY ES.ExamsID;
             OPEN Cursor_MigrateExam_Delete;
             FETCH NEXT FROM Cursor_MigrateExam_Delete INTO @ImportID, @Transaction_ID, @PartnerId, @Prev_Transction_ID, @Appid, @Import_Facility_ID, @examsid;
             WHILE @@FETCH_STATUS = 0
                 BEGIN
  --print('spMigrateImportData_6_6_19 validation-2-1 '+CONVERT( VARCHAR(24), GETDATE(), 113));
--print concat ('here1:',@Transaction_ID, ' ,import id:',convert(varchar(100),@ImportID))
/*
1 for every different @Transction_ID and @Prev_Transction_ID set file transaction status to cancelledwithnewtransaction if exists
2)for every different @import_Exams_ID: create a new exam table entry and note its trans_examid and migrate.


*/



                     IF @Transaction_ID <> @prosPrev_Transaction_ID
                         BEGIN
                             IF @prosPrev_Transaction_ID <> @Prev_Transction_ID
                                 BEGIN
                                     IF @Prev_Transction_ID <> ''
                                         BEGIN
		
			-- update status of files in tbl_import_Exams
			-- delete transaction of previous transaction from tbl_exam, tbl_exam_measure_Data and tbl_Measure_Data_Ext
	--print 'call spDeletePrevTransImportData'		
                                             EXEC dbo.spDeletePrevTransImportData
                                                  @Transaction_ID,
                                                  @Prev_Transction_ID,
                                                  @Appid,
                                                  @PartnerId,
                                                  @Import_Facility_ID;
                                             SET @Prev_Transction_ID = @Prev_Transction_ID;
                                         END;
                                     SET @prosPrev_Transaction_ID = @Prev_Transction_ID;
                                 END;
                             SET @Prev_Transction_ID = @Transaction_ID;
	-- Here delete any "NEW" @Transaction_ID duplicates submissions due to technical reasons	
	--print 'call dbo.spDeleteNewTransImportData'
                             EXEC dbo.spDeleteNewTransImportData
                                  @ImportID,
                                  @Transaction_ID,
                                  @Appid,
                                  @PartnerId,
                                  @Import_Facility_ID;
                         END;
                     FETCH NEXT FROM Cursor_MigrateExam_Delete INTO @ImportID, @Transaction_ID, @PartnerId, @Prev_Transction_ID, @Appid, @Import_Facility_ID, @examsid;
                 END;
             CLOSE Cursor_MigrateExam_Delete;
             DEALLOCATE Cursor_MigrateExam_Delete;


  --print('spMigrateImportData_6_6_19 validation-3 '+CONVERT( VARCHAR(24), GETDATE(), 113));
  --Change#4
--print 'after first loop'
/*
        IF OBJECT_ID('tempdb..#Imports1') IS NOT NULL 
            DROP TABLE #Imports1
        CREATE TABLE #Imports1
            (
              ImportID INT PRIMARY KEY
                           NOT NULL
            )
        INSERT  INTO #Imports1
                SELECT DISTINCT
                        ImportID
                FROM    tbl_Import_Raw R
                        INNER JOIN tbl_Import_Exams ES ON ES.RawData_Id = R.ImportID
                        INNER JOIN tbl_Import_Exam e ON e.Import_ExamsID = es.ExamsID
                        INNER JOIN tbl_Import_Exam_Measure_Data m ON m.Import_ExamID = e.Import_examID
                WHERE   ISNULL([R].[status], 0) = 2
                        AND ISNULL(r.Data_Status, 0) IN ( 3, 4 )
                        AND ISNULL(e.Status, 0) IN ( 3, 4 )
                        AND R.ImportID IN ( SELECT  ImportID
                                            FROM    #Imports )

*/

--print 'after insert into #imports1'
  -- Change #3:
             --DECLARE @CurrentActive_Year INT;
             --SELECT TOP 1 @CurrentActive_Year = Submission_Year
             --FROM tbl_Lookup_Active_Submission_Year
             --WHERE IsActive = 1;
           --  DECLARE @IsAcceptableDateRange BIT;
             DECLARE Cursor_MigrateExam CURSOR
             FOR SELECT DISTINCT
                        R.ImportID,
                        examsid,
                        Transaction_ID,
                        PartnerId,
                        Transaction_DateTime,
                        Prev_Transction_ID,
                        Appid,
                        e.Import_examID,
                        Facility_ID,
                        Import_Physician_Group_TIN,
                        Import_Exam_Unique_ID,
                        Import_Exam_DateTime,
                        Import_Physician_NPI,
                        Import_First_Name,
                        Import_Last_Name,
                        Import_Patient_ID,
                        Import_Patient_Age,
                        Import_Patient_Gender,
                        CASE UPPER(LTRIM(RTRIM(ISNULL(Import_Patient_Medicare_Beneficiary, ''))))
                            WHEN ''
                            THEN '-1'
                            WHEN 'Y'
                            THEN '1'
                            WHEN 'N'
                            THEN '0'
                            WHEN 'NA'
                            THEN '-1'
                        END,
                        CASE UPPER(LTRIM(RTRIM(ISNULL(Import_Patient_Medicare_Advantage, ''))))
                            WHEN ''
                            THEN '-1'
                            WHEN 'Y'
                            THEN '1'
                            WHEN 'N'
                            THEN '0'
                            WHEN 'NA'
                            THEN '-1'
                        END,
                        e.isEncrypt
                 FROM tbl_Import_Raw R
                      INNER JOIN tbl_Import_Exams ES ON ES.RawData_Id = R.ImportID
                                                        AND R.ImportID <= @ImportId_max
                      INNER JOIN tbl_Import_Exam e ON e.Import_ExamsID = es.ExamsID
                      INNER JOIN tbl_Import_Exam_Measure_Data m ON m.Import_ExamID = e.Import_examID
	--INNER JOIN tbl_Lookup_Measure L on L.Measure_ID=m.Import_Exam_MeasureID and L.CMSYear=@CurrentActive_Year  -- Change #3:
                 WHERE ISNULL([R].[status], 0) = 2
                       AND ISNULL(r.Data_Status, 0) IN(3, 4)
                      AND ISNULL(e.Status, 0) IN(3, 4)
                 ORDER BY ExamsID;
             OPEN Cursor_MigrateExam;
             FETCH NEXT FROM Cursor_MigrateExam INTO @ImportID, @examsid, @Transaction_ID, @PartnerId, @Transaction_DateTime, @Prev_Transction_ID, @Appid, @Import_examID, @Import_Facility_ID, @Import_Physician_Group_TIN, @Import_Exam_Unique_ID, @Import_Exam_DateTime, @Import_Physician_NPI, @Import_First_Name, @Import_Last_Name, @Import_Patient_ID, @Import_Patient_Age, @Import_Patient_Gender, @Import_Patient_Medicare_Beneficiary, @Import_Patient_Medicare_Advantage, @Import_isEncrypt;
--@IsAcceptableDateRange

             WHILE @@FETCH_STATUS = 0
                 BEGIN

	--SET @Import_Patient_Medicare_Beneficiary=		CASE UPPER(LTRIM(RTRIM(ISNULL(@Import_Patient_Medicare_Beneficiary,'')))) WHEN '' THEN '-1' WHEN 'Y' THEN '1' WHEN 'N' THEN '0' WHEN 'NA' THEN '-1' END;
	--SET @Import_Patient_Medicare_Beneficiary=	      CASE UPPER(LTRIM(RTRIM(ISNULL(@Import_Patient_Medicare_Advantage,'')))) WHEN '' THEN '-1' WHEN 'Y' THEN '1' WHEN 'N' THEN '0' WHEN 'NA' THEN '-1' END;
--print 'here2'
/*
1 for every different @Transction_ID and @Prev_Transction_ID set file transaction status to cancelledwithnewtransaction if exists
2)for every different @import_Exams_ID: create a new exam table entry and note its trans_examid and migrate.


*/

--print('spMigrateImportData_6_6_19 validation-3-1 '+CONVERT( VARCHAR(24), GETDATE(), 113));
--Change#4
/* 
			    IF @Transaction_ID <> @prosPrev_Transaction_ID 
                    BEGIN 
	
	
                        IF @prosPrev_Transaction_ID <> @Prev_Transction_ID 
                            BEGIN
                                IF @Prev_Transction_ID <> '' 
                                    BEGIN
		                             SET @Prev_Transction_ID = @Prev_Transction_ID
                                    END
                                SET @prosPrev_Transaction_ID = @Prev_Transction_ID
                            END   
                            
                        SET @Prev_Transction_ID = @Transaction_ID
                        -- Here delete any "NEW" @Transaction_ID duplicates submissions due to technical reasons
					--	print 'Its going to execute spDeleteNewTransImportData' + convert(varchar(5),@ImportID)+ ','+ @Transaction_ID + ','+ @PartnerId + ','+ @Appid + ','+ @Import_Facility_ID;
 --print 'call spDeleteNewTransImportData'
 --Change#4
 /*   ---------------------------------------------------
						EXEC dbo.spDeleteNewTransImportData @ImportID,
                            @Transaction_ID, @Appid, @PartnerId,
                            @Import_Facility_ID
                            

							*/
						SET @prosPrev_Transaction_ID = @Transaction_ID
	
                    END

					*/

--print('spMigrateImportData_6_6_19 validation-3-2 '+CONVERT( VARCHAR(24), GETDATE(), 113));
  -- 1) Genereate Exam id here
  -- 2) pass exam id to stored proc to push data for measure data and its extensions etc...
                     DECLARE @intSubmissionYear INT;
             --   SELECT  @intSubmissionYear = YEAR(GETDATE()) ;
                     SELECT @intSubmissionYear = YEAR(ISNULL(Import_Exam_DateTime, GETDATE()))
                     FROM tbl_Import_Exam
                     WHERE Import_examID = @Import_ExamID;
		
		    
  --print('spMigrateImportData_6_6_19 validation-3-3 '+CONVERT( VARCHAR(24), GETDATE(), 113));		  
               
		-----CURSER STARS FOR UPDATE/INSERT-----------------change #1



                     DECLARE @Cur_Import_Exam_MeasureID INT, @Cur_Import_Physician_NPI VARCHAR(20), @Cur_Import_Physician_Group_TIN VARCHAR(20), @Cur_Import_Patient_ID VARCHAR(256), @Cur_Import_Exam_DateTime AS DATETIME, @Import_Measure_num VARCHAR(50), @Import_CPT_Code VARCHAR(50), @Criteria VARCHAR(50),
--@CMSYear int,

                     @Exam_ID INT, @Exam_MeasureData_ID INT, @intMeasureNumID INT, @intNumerator_code_value INT, @Cur_Import_Numerator_Code VARCHAR(50), @Cur_Import_Diagnosis_code VARCHAR(50), @intblExamMeasureId INT, @Cur_looingCOUNT INT= 0, @ISRecordUpdate INT;
 -- Change #4
                     DECLARE @CPT_CODE_CRITERIA VARCHAR(30);
                     DECLARE @NUM_CODE_CRITERIA VARCHAR(30);
				 DECLARE @CURExam_Unique_ID VARCHAR(500);
                     DECLARE CUR_Record_Exist_or_Not CURSOR
                     FOR SELECT  
--top 2
                         DISTINCT
                                E.Import_Physician_NPI,
                                E.Import_Physician_Group_TIN,
                                E.Import_Patient_ID,
                                E.Import_Exam_DateTime,
                                M.Import_Measure_num,
                                M.Import_CPT_Code,
                                M.Import_Numerator_code,
                                M.Import_Diagnosis_code,
                                M.Import_Exam_MeasureID,
						  E.Import_Exam_Unique_ID
                         FROM tbl_Import_Exam e
                              INNER JOIN tbl_Import_Exam_Measure_Data M ON E.Import_examID = M.Import_ExamID
 -- order by E.Import_examID desc
 
                         WHERE E.Import_examID = @Import_examID
                               AND M.[Status] = 3;
                     OPEN CUR_Record_Exist_or_Not;
                     FETCH NEXT FROM CUR_Record_Exist_or_Not INTO @Cur_Import_Physician_NPI, @Cur_Import_Physician_Group_TIN, @Cur_Import_Patient_ID, @Cur_Import_Exam_DateTime, @Import_Measure_num, @Import_CPT_Code, @Cur_Import_Numerator_Code, @Cur_Import_Diagnosis_code, @Cur_Import_Exam_MeasureID,@CURExam_Unique_ID;
                     WHILE @@FETCH_STATUS = 0
                         BEGIN
  --print('spMigrateImportData_6_6_19 validation-3-4 '+CONVERT( VARCHAR(24), GETDATE(), 113));	
                             SET @Exam_ID = 0;
                             SET @Exam_MeasureData_ID = 0;
                             SET @ISRecordUpdate = 0;
                             SET @Criteria = 'NA';
                             SET @intNumerator_code_value = 0;
                             SET @intblExamMeasureId = 0;
                             SET @intMeasureNumID = 0;
                             SET @CPT_CODE_CRITERIA = '';
                             SET @NUM_CODE_CRITERIA = 'NA';
  --1)find  record is existed or not based on Import_ExamID related data Import_ExamID
 
   --SELECT  
   --             @CMSYear = YEAR(ISNULL(@Cur_Import_Exam_DateTime,GETDATE()))

                             --SELECT @IsAcceptableDateRange = IsAcceptableDateRange
                             --FROM tbl_Lookup_Measure
                             --WHERE Measure_num = @Import_Measure_num
                             --      AND CMSYear = @CurrentActive_Year;
  --print('spMigrateImportData_6_6_19 validation-3-5 '+CONVERT( VARCHAR(24), GETDATE(), 113));	
                             --IF(@IsAcceptableDateRange = 1)
                             --    BEGIN
                             --        SET @intSubmissionYear = @CurrentActive_Year;
		                                                                               
                             --    END;
                             SELECT @NUM_CODE_CRITERIA = Criteria
                             FROM tbl_lookup_Numerator_Code
                             WHERE CMSYear = @intSubmissionYear
                                   AND Measure_Num = @Import_Measure_num
                                   AND upper( Numerator_Code) = upper( ISNULL(@Cur_Import_Numerator_Code, '')); --jira948
  --print('spMigrateImportData_6_6_19 validation-3-6 '+CONVERT( VARCHAR(24), GETDATE(), 113));	
   --  PRINT('414  --'+CONVERT(VARCHAR(20),ISNULL(@intSubmissionYear,'emptyyear')))
	  --PRINT('415  --'+CONVERT(VARCHAR(20),ISNULL(@Import_Measure_num,'@Import_Measure_num')))

   -- PRINT('417  --'+CONVERT(VARCHAR(20),ISNULL(@Cur_Import_Numerator_Code,'@Cur_Import_Numerator_Code')))
	  --     PRINT('418  --'+CONVERT(VARCHAR(20),ISNULL(@Criteria,'empty')))

	 -- SET @Criteria =CASE When (@Criteria is null or @Criteria ='') then 'NA' else @Criteria end;

	                  /* below code moved to function fnMIPSExamDataKeyParameters
                             SELECT TOP 1 @Exam_ID = e.Exam_Id,
                                          @Exam_MeasureData_ID = md.Exam_Measure_Id
                             FROM tbl_Exam e WITH (nolock)
                                  INNER JOIN tbl_Exam_Measure_Data md WITH (nolock) ON md.Exam_Id = e.Exam_Id
                                                                                       AND md.CMS_Submission_Year = e.CMS_Submission_Year
                                                                                       AND e.CMS_Submission_Year = @intSubmissionYear
                                  INNER JOIN tbl_Lookup_Measure m WITH (nolock) ON m.Measure_ID = md.Measure_ID
                                                                                   AND m.CMSYear = md.CMS_Submission_Year
                                                                                   AND m.CMSYear = @intSubmissionYear
                             WHERE e.CMS_Submission_Year = @intSubmissionYear
                                   AND e.Exam_Date = @Cur_Import_Exam_DateTime
                                   AND e.Exam_TIN = @Cur_Import_Physician_Group_TIN
                                   AND e.Physician_NPI = @Cur_Import_Physician_NPI
                                   AND ((e.Patient_ID = @Cur_Import_Patient_ID))
						   AND ISNULL(e.Exam_Unique_ID,'')=ISNULL(@CURExam_Unique_ID,'')--Change5#
                                   AND (md.Denominator_proc_code = @Import_CPT_Code)
                                   AND (m.Measure_num = @Import_Measure_num)
                                   AND (isnull(md.Criteria, 'NA') = CASE
                                                                        WHEN(@Criteria = ''
                                                                             OR isnull(@Criteria, 'NA') = 'NA')
                                                                        THEN isnull(md.Criteria, 'NA')
                                                                        ELSE @Criteria
                                                                    END)
                                   AND md.Denominator_Diag_code = CASE
                                                                      WHEN(m.Is_DiagCodeAsKey = 1)
                                                                      THEN @Cur_Import_Diagnosis_code
                                                                      ELSE md.Denominator_Diag_code
                                                                  END; --Change#3
					 */
					 SELECT @Exam_ID=Exam_Id,@Exam_MeasureData_ID=Exam_Measure_Id from [dbo].[fnMIPSExamDataKeyParameters] (
				   @Cur_Import_Physician_NPI
				  ,@Cur_Import_Physician_Group_TIN
				  ,@Cur_Import_Patient_ID
				  ,@Cur_Import_Patient_ID
				  ,@Import_Measure_num
				  ,@Import_CPT_Code				  
				  ,@Cur_Import_Exam_DateTime
				  ,@intSubmissionYear
				  ,@CURExam_Unique_ID
				  ,@Criteria
				  ,@Cur_Import_Diagnosis_code
				  ,@Cur_Import_Numerator_Code)--Change#7
    print('ExamId line No:431 '+CONVERT( VARCHAR(24), @Exam_ID));	     
	   --print('spMigrateImportData_6_6_19 validation-3-7 '+CONVERT( VARCHAR(24), GETDATE(), 113));	      

	      --  PRINT('410  --'+CONVERT(VARCHAR(200),ISNULL(@intSubmissionYear,00)))
		   
	      --  PRINT('411  --'+CONVERT(VARCHAR(200),ISNULL(@Cur_Import_Exam_DateTime,00)))
		   
	      --  PRINT('412  --'+CONVERT(VARCHAR(200),ISNULL(@Cur_Import_Physician_Group_TIN,00)))
		     --  PRINT('413  --'+CONVERT(VARCHAR(200),ISNULL(@Cur_Import_Physician_NPI,0000)))
		     --  PRINT('414  --'+CONVERT(VARCHAR(200),ISNULL(@Cur_Import_Patient_ID,0000)))
		     --  PRINT('415  --'+CONVERT(VARCHAR(200),ISNULL(@Import_CPT_Code,0000)))


			    --PRINT('416  --'+CONVERT(VARCHAR(200),ISNULL(@Import_Measure_num,0000)))
		     --  PRINT('417  --'+CONVERT(VARCHAR(200),ISNULL(@Cur_Import_Diagnosis_code,0000)))
			    --PRINT('418  --'+CONVERT(VARCHAR(200),ISNULL(@Criteria,0000)))

	      --  PRINT('419  --'+CONVERT(VARCHAR(20),ISNULL(@Exam_ID,00)))
		     --  PRINT('420  --'+CONVERT(VARCHAR(20),ISNULL(@Exam_MeasureData_ID,0000)))

                             SELECT @intNumerator_code_value = Numerator_response_Value,
                                    @Criteria = ISNULL(Criteria, 'NA')
                             FROM tbl_lookup_Numerator_Code
                             WHERE upper(Numerator_Code) = upper(@Cur_Import_Numerator_Code) --jira#948
                                   AND Measure_Num = @Import_Measure_num
                                   AND CMSYear = @intSubmissionYear;

 --print('spMigrateImportData_6_6_19 validation-3-8 '+CONVERT( VARCHAR(24), GETDATE(), 113));	
----- *** tbl_exam AND tbl_Exam_Measure_Data_Extension  Update Code Starts  *** --
                             IF((@Exam_ID > 0)
                                AND (@Exam_MeasureData_ID > 0))-- Already Record Exist 
                                 BEGIN

--PRINT('Write a code for UPDATE')

	  -- 1.update tbl_exam

                                     UPDATE [dbo].[tbl_Exam]
                                       SET 
   --[Physician_NPI] = <Physician_NPI, varchar(50),>
      --,[Exam_TIN] = <Exam_TIN, varchar(10),>
      --,[Patient_ID] = <Patient_ID, varchar(500),>
                                           [Patient_Age] = @Import_Patient_Age,
                                           [Patient_Gender] = @Import_Patient_Gender,
                                           [Patient_Medicare_Beneficiary] = @Import_Patient_Medicare_Beneficiary,
                                           [Patient_Medicare_Advantage] = @Import_Patient_Medicare_Advantage
                                           ,
   --   ,[Exam_Date] = <Exam_Date, datetime,>
    --  ,[Created_Date] = <Created_Date, datetime,>
     -- ,[Created_By] = <Created_By, varchar(50),> 
                                           [Last_Modified_Date] = GETDATE(),
                                           [Last_Modified_By] = 'ImportWorkFlow',
                                           [Facility_ID] = @Import_Facility_ID,
                                           [Exam_Unique_ID] = @Import_Exam_Unique_ID,
                                           [PartnerID] = @PartnerId,
                                           [AppID] = @Appid,
                                           [Transaction_ID] = @Transaction_ID,
                                           [DataSource_Id] = 1
                                           , -- 1 is Vendor Imports as in dbo.tbl_Lookup_Data_Source, 
                                           [CMS_Submission_Year] = @intSubmissionYear,
                                           [IsEncrypt] = @Import_isEncrypt,
                                           [File_ID] = 0
                                     WHERE Exam_Id = @Exam_ID;

 ---2. update tbl_exam_measure Table

                                     UPDATE [dbo].[tbl_Exam_Measure_Data]
                                       SET 
   --[Exam_Id] = <Exam_Id, int,>
     -- ,[Measure_ID] = <Measure_ID, int,>
     -- ,[Denominator] = <Denominator, smallint,>
      --,[Denominator_proc_code] = <Denominator_proc_code, varchar(50),>
                                           [Denominator_Diag_code] = @Cur_Import_Diagnosis_code,
                                           [Numerator_response_value] = @intNumerator_code_value
                                           ,
      --,[Status] = <Status, int,>
      --,[CMS_Submission_Status] = <CMS_Submission_Status, varchar(50),>
     -- ,[Created_Date] = <Created_Date, datetime,>
      --,[Created_By] = <Created_By, varchar(50),> 
                                           [Last_Mod_Date] = GETDATE(),
                                           [Last_Mod_By] = 'ImportWorkFlow'
                                           , 
     -- ,[CMS_Submission_Date] = <CMS_Submission_Date, datetime,> 
                                           [CMS_Submission_Year] = @intSubmissionYear
                                           ,
      --,[Aggregation_Id] = <Aggregation_Id, int,> 
                                           [Criteria] = ISNULL(@NUM_CODE_CRITERIA, 'NA')
                                           ,
    --, Criteria= CASE WHEN ((@CPT_CODE_CRITERIA IS NULL) OR @CPT_CODE_CRITERIA='' OR @CPT_CODE_CRITERIA='NA' ) THEN @NUM_CODE_CRITERIA
				--		        ELSE @CPT_CODE_CRITERIA END 
                                           [Numerator_Code] = upper(@Cur_Import_Numerator_Code)
	  --,CPTCode_Criteria=@CPT_CODE_CRITERIA
                                     WHERE Exam_Measure_Id = @Exam_MeasureData_ID
                                           AND Exam_Id = @Exam_ID;
 


 -----3. UPDATE tbl_Exam_Measure_Data_Extension
                                     SET @intblExamMeasureId = @Exam_MeasureData_ID;
 -- For Find wheather record insert or updated
                                     SET @ISRecordUpdate = 1;
                                 END
-----***  tbl_exam AND tbl_Exam_Measure_Data_Extension  Update Code Ended ***-------




----- *** tbl_exam AND tbl_Exam_Measure_Data_Extension  Insert Code Starts *** --;
                                 ELSE -- Record not Exist 

                                 BEGIN
--PRINT('Write a code for INSERT for tbl_exam measure data')

       --1.insert into  tbl_Exam
                                     INSERT INTO tbl_Exam
([Physician_NPI],
 [Exam_TIN],
 [Patient_ID],
 [Patient_Age],
 [Patient_Gender],
 [Patient_Medicare_Beneficiary],
 [Patient_Medicare_Advantage],
 [Exam_Date],
 [Created_Date],
 [Created_By],
 [Last_Modified_Date],
 [Last_Modified_By],
 [Facility_ID],
 [Exam_Unique_ID],
 [PartnerID],
 [AppID],
 [Transaction_ID],
 [DataSource_Id],
 [cms_submission_year],
 [IsEncrypt]
)
                                            SELECT @Import_Physician_NPI,
                                                   @Import_Physician_Group_TIN,
                                                   @Import_Patient_ID,
                                                   @Import_Patient_Age,
                                                   @Import_Patient_Gender,
                                                   @Import_Patient_Medicare_Beneficiary,
                                                   @Import_Patient_Medicare_Advantage,
                                                   @Import_Exam_DateTime,
                                                   @Transaction_DateTime,
                                                   'ImportWorkFlow',
                                                   GETDATE(),
                                                   'ImportWorkFlow',
                                                   @Import_Facility_ID,
                                                   @Import_Exam_Unique_ID,
                                                   @PartnerId,
                                                   @Appid,
                                                   @Transaction_ID,
                                                   1, -- 1 is Vendor Imports as in dbo.tbl_Lookup_Data_Source,
                                                   @intSubmissionYear,
                                                   @Import_isEncrypt;
                                     SET @tblExam_ExamID = @@IDENTITY;
                                     PRINT('Write a code for INSERT for tbl_exam');
                                     PRINT('483  --'+CONVERT(VARCHAR(20), @tblExam_ExamID));


  --2.insert into  tbl_Exam_Measure_Data
                                     SELECT @intMeasureNumID = Measure_ID
                                     FROM tbl_Lookup_Measure
                                     WHERE Measure_num = @Import_Measure_num
                                           AND CMSYear = @intSubmissionYear;
                                     INSERT INTO tbl_Exam_Measure_Data
([Exam_Id],
 [Measure_ID],
 [Denominator_proc_code],
 [Denominator_Diag_code],
 [Numerator_response_value],
 [Status],
 Created_Date,
 Created_By,
 Last_Mod_Date,
 Last_Mod_By,
 CMS_Submission_Year,
 Criteria,
 Numerator_Code                    --change# 3
					 --,CPTCode_Criteria
)
                                            SELECT @tblExam_ExamID,
                                                   @intMeasureNumID,
                                                   @Import_CPT_Code,
                                                   @Cur_Import_Diagnosis_code,
                                                   @intNumerator_code_value,
                                                   2,
                                                   @transaction_datetime,
                                                   'ImportWorkFlow',
                                                   GETDATE(),
                                                   'ImportWorkFlow',
                                                   @intSubmissionYear,
						 -- ISNULL(@Criteria,'NA'),
                                                   CASE
                                                       WHEN @NUM_CODE_CRITERIA = ''
                                                            OR @NUM_CODE_CRITERIA IS NULL
                                                       THEN 'NA'
                                                       ELSE @NUM_CODE_CRITERIA
                                                   END
                                                   ,             --change# 3
                                                   CASE
                                                       WHEN @Cur_Import_Numerator_Code = ''
                                                       THEN NULL
                                                       ELSE upper(@Cur_Import_Numerator_Code) --jira948
                                                   END;             --change# 3
						  --,@CPT_CODE_CRITERIA
                                     SET @intblExamMeasureId = @@IDENTITY;



		    -- For Find wheather record insert or updated
                                     SET @ISRecordUpdate = 0;
	 

			   -- PRINT('Write a code for INSERT for tbl_exam')
			      -- PRINT('600  --'+CONVERT(VARCHAR(20),@tblExam_ExamID))
				     -- PRINT('601  --'+CONVERT(VARCHAR(20),@intblExamMeasureId))
                                 END;
  --print('spMigrateImportData_6_6_19 validation-3-9 '+CONVERT( VARCHAR(24), GETDATE(), 113));	
     ----- *** tbl_exam AND tbl_Exam_Measure_Data_Extension  Insert Code Ends  *** --




	----- *** tbl_Exam_Measure_Data_Extension  Insert/Update Code Starts ***--


	-- now use @Import_Exam_MeasureID,@intblExamMeasureId transfer exam extension data.
                             EXEC spMigrateExamMeasureDataExtension
                                  @intblExamMeasureId,
                                  @Cur_Import_Exam_MeasureID;
	
	 --print('spMigrateImportData_6_6_19 validation-3-10 '+CONVERT( VARCHAR(24), GETDATE(), 113));	
	----- *** tbl_Exam_Measure_Data_Extension  Insert/Update Code Ends ***--



	-- Now update tbl_Import_Exam_Measure_Data to 
                             UPDATE tbl_Import_Exam_Measure_Data
                               SET
                                   [Status] = 6,
                                   [Exam_Record_Status] = CASE
                                                              WHEN @ISRecordUpdate = 1
                                                              THEN 'Update'
                                                              WHEN @ISRecordUpdate = 0
                                                              THEN 'Insert'
                                                          END
	--where Import_ExamID = @Import_ExamID
                             WHERE Import_Exam_MeasureID = @Cur_Import_Exam_MeasureID;
	

		 --print('spMigrateImportData_6_6_19 validation-3-11 '+CONVERT( VARCHAR(24), GETDATE(), 113));	

                     FETCH NEXT FROM CUR_Record_Exist_or_Not INTO @Cur_Import_Physician_NPI, @Cur_Import_Physician_Group_TIN, @Cur_Import_Patient_ID, @Cur_Import_Exam_DateTime, @Import_Measure_num, @Import_CPT_Code, @Cur_Import_Numerator_Code, @Cur_Import_Diagnosis_code, @Cur_Import_Exam_MeasureID,@CURExam_Unique_ID;
                         END;
                     CLOSE CUR_Record_Exist_or_Not;
                     DEALLOCATE CUR_Record_Exist_or_Not;

		-----------------------END CURSER STARS FOR UPDATE/INSERT

	 --print('spMigrateImportData_6_6_19 validation-3-12 '+CONVERT( VARCHAR(24), GETDATE(), 113));	
		---work place for insert the insert the mulitple dulicpates recordid.
		---input is tblExam_ExamId
		---input paramter is tblExam_ExamId.
                     PRINT 'call spMigrated_Exam_split_Duplicate_measures';
                     EXEC dbo.spMigrated_Exam_split_Duplicate_measures
                          @tblExam_ExamID,
                          @Import_examID;
                     PRINT 'update tbl_import_exam';

 --print('spMigrateImportData_6_6_19 validation-3-13 '+CONVERT( VARCHAR(24), GETDATE(), 113));			
                     UPDATE E
                       SET
                           Import_Status = CASE e.Import_Status
                                               WHEN 3
                                               THEN 11
                                               WHEN 4
                                               THEN 10
                                               ELSE Import_status
                                           END
                     FROM tbl_Import_Exams e
                     WHERE e.ExamsID = @examsid;
                     PRINT CONVERT(VARCHAR(20), @examsid);
	 --print('spMigrateImportData_6_6_19 validation-3-14 '+CONVERT( VARCHAR(24), GETDATE(), 113));	
                     FETCH NEXT FROM Cursor_MigrateExam INTO @ImportID, @examsid, @Transaction_ID, @PartnerId, @Transaction_DateTime, @Prev_Transction_ID, @Appid, @Import_examID, @Import_Facility_ID, @Import_Physician_Group_TIN, @Import_Exam_Unique_ID, @Import_Exam_DateTime, @Import_Physician_NPI, @Import_First_Name, @Import_Last_Name, @Import_Patient_ID, @Import_Patient_Age, @Import_Patient_Gender, @Import_Patient_Medicare_Beneficiary, @Import_Patient_Medicare_Advantage, @Import_isEncrypt;
                 END;
             CLOSE Cursor_MigrateExam;
             DEALLOCATE Cursor_MigrateExam;
 --print('spMigrateImportData_6_6_19 validation-4' +CONVERT( VARCHAR(24), GETDATE(), 113));

             PRINT 'update tbl_import_raw';
             WITH ImportsCTE
                  AS (
                  SELECT ImportID
                  FROM #Imports)
                  UPDATE R
                    SET
                        [Status] = CASE data_status
                                       WHEN 3
                                       THEN 11
                                       WHEN 4
                                       THEN 10
                                       ELSE [Status]
                                   END,
                        data_status = CASE data_status
                                          WHEN 3
                                          THEN 11
                                          WHEN 4
                                          THEN 10
                                          ELSE data_status
                                      END
                  FROM tbl_Import_Raw R
                       INNER JOIN ImportsCTE I ON R.ImportID = I.ImportID;
--Change#4
				/*
        UPDATE  R
        SET     data_status = CASE data_status
                                WHEN 3 THEN 11
                                WHEN 4 THEN 10
                                ELSE data_status
                              END
        FROM    tbl_Import_Raw R
                INNER JOIN #Imports1 I ON R.ImportID = I.ImportID

				*/

--print('spMigrateImportData_6_6_19 validation-5 ' +CONVERT( VARCHAR(24), GETDATE(), 113));
         END;


