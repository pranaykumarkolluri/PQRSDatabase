


-- =============================================
-- Author:  	RAJU G
-- Create date: 27 march,2019
-- Description: Fileupload data  Insert/Update SP.
-- Change #1: JIRA-694 
--Change #1 Date: 5/may/2019
--Change #2 Hari 3/06/2019
--Change #2 updating processed records count in certain interval
--Change#3 : JIRA#1103
-- =============================================
CREATE PROCEDURE [dbo].[SPInsertUpdateExamsData]
-- Add the parameters for the stored procedure here
@FileId int,
@UploadUserId int,
@PartnerID [varchar](50) ,
@DataSource_Id int,
@Created_By varchar(50),
@Status int,
@ReqId int,
@tbl_Exam_Data_Type tbl_Exam_Data_Type READONLY
AS
BEGIN
  DECLARE 

          @Examdate varchar(50),
          @Measure_num varchar(50),
		  @Exam_Unique_Id varchar(500),
          @Exam_TIN varchar(9),
          @Physician_NPI varchar(50),
          @Patient_ID varchar(500),   
          @Patient_Age varchar(20),
          @Patient_Gender varchar(50),
          @Patient_Medicare_Beneficiary varchar(50),
          @Patient_Medicare_Advantage varchar(50),   
          @CMS_Submission_Year varchar(50),
          @DecryptPatient_Id varchar(500),
          @Procedure_Code varchar(50),     
          @Criteria varchar(20),
          @warningFound bit,
          @_addedRecordsWithWarning int,
          @_addedRecords int,
          @_updatedRecordsWithWarning int,
          @_updatedRecords int,
          @MeasureID int,
          @Exam_Measure_Id int,
          @Exam_Measure_Ext_Id int,
          @measure_Id int,
		  @Denominator_proc_code varchar(50) ,
		  @measure_ext_number varchar(500),
		  @warning varchar(2000),
		  @exclusion varchar(2000),
	@Denominator_Diag_code varchar(50) ,
	@Numerator_response_value varchar(50) ,
	@Numerator_Code varchar(100) ,
	@Other_Question_num varchar(50) ,
	@Response_Value varchar(50),
	@_rejectedRecords int,
	@ProcessedCount int,	
	@IsEncrypt varchar(10) ;
	
  DECLARE @reposevalue varchar(500) = '';
  DECLARE @other_ques_num int;
  DECLARE @_meas_Ext_Id int = 0;

  DECLARE @recordExists bit,
          @Exam_Id int;

  SET @_addedRecordsWithWarning = 0;
  SET @_addedRecords = 0;
  SET @_updatedRecordsWithWarning = 0;
  SET @_updatedRecords = 0;
  SET @_rejectedRecords = 0;
  SET @ProcessedCount=0;
   
 
  DECLARE Cur_tbl_Exam_Type CURSOR FOR

  SELECT
       [Measure_num]
      ,[Examdate]
      ,[Exam_Unique_ID]
      ,[Exam_TIN]
      ,[Physician_NPI]
      ,[Patient_ID]
      ,[Patient_Age]
      ,[Patient_Gender]
      ,[Patient_Medicare_Beneficiary]
      ,[Patient_Medicare_Advantage]
      ,[CMS_Submission_Year]
      ,[DecryptPatient_Id]
      ,[Procedure_Code]
      ,[Criteria]
      ,[warningFound]
      ,[Denominator_proc_code]
      ,[Denominator_Diag_code]
      ,[Numerator_response_value]
      ,[Numerator_Code]
      ,[Other_Question_num]
      ,[Response_Value]
	  ,IsEncrypt
	  ,Measure_Extension_Number
	  ,Warning
	  ,Exclusion
  FROM @tbl_Exam_Data_Type
  OPEN Cur_tbl_Exam_Type

  FETCH NEXT FROM Cur_tbl_Exam_Type INTO  @Measure_num,@Examdate,@Exam_Unique_Id , @Exam_TIN, @Physician_NPI, @Patient_ID,  @Patient_Age, @Patient_Gender,
  @Patient_Medicare_Beneficiary, @Patient_Medicare_Advantage,  @CMS_Submission_Year,@DecryptPatient_Id, @Procedure_Code,@Criteria, @warningFound, @Denominator_proc_code  ,
  @Denominator_Diag_code ,@Numerator_response_value  ,@Numerator_Code ,@Other_Question_num ,
  @Response_Value,@IsEncrypt,@measure_ext_number,@warning, @exclusion 

  WHILE @@FETCH_STATUS = 0
  BEGIN
  BEGIN TRY
    set @ProcessedCount=@ProcessedCount+1;
	

	  --Change 2
	  IF(@ProcessedCount=1 or (@ProcessedCount%50=0))
	  BEGIN
	     Update tbl_ApiRequstedFilesList  set ProcessedRecords=@ProcessedCount, CountUpdateOn= GETDATE() where FileId=@FileId and ReqId=@ReqId
	  END
	  --Change 2

    SET @recordExists = 0
    -- 
    -- NEED CHECK RECORD EXISTS OR NOT
    SET @Exam_Id = 0;
    --STEP #1: Get examid
	/*  below code moved to function fnMIPSExamDataKeyParameters
    SELECT TOP 1
      @Exam_Id = e.Exam_Id
    FROM tbl_Exam e WITH (NOLOCK)
    INNER JOIN tbl_Exam_Measure_Data md WITH (NOLOCK)
      ON md.Exam_Id = e.Exam_Id
      AND md.CMS_Submission_Year = e.CMS_Submission_Year
    INNER JOIN tbl_Lookup_Measure m WITH (NOLOCK)
      ON m.Measure_ID = md.Measure_ID
      AND m.CMSYear = md.CMS_Submission_Year
      AND m.CMSYear = TRY_PARSE(@CMS_Submission_Year AS int)
    WHERE e.CMS_Submission_Year = TRY_PARSE(@CMS_Submission_Year AS int)
    AND e.Exam_Date = TRY_PARSE(@Examdate AS datetime)
    AND e.Exam_TIN = @Exam_TIN
    AND e.Physician_NPI = @Physician_NPI
    AND ((e.Patient_ID = @Patient_Id)
    OR (e.Patient_ID = @DecryptPatient_Id))
    AND (md.Denominator_proc_code = @Procedure_Code)
    AND (m.Measure_num = @Measure_num)
    --AND (ISNULL(md.Criteria, 'NA') = ISNULL(@Criteria, 'NA'))
     and(isnull(md.Criteria,'NA')=case WHEN (@Criteria='' OR isnull(@Criteria,'NA')='NA') THEN isnull(md.Criteria,'NA')
	                                       ELSE @Criteria END )
	AND md.Denominator_Diag_code =CASE WHEN M.Is_DiagCodeAsKey=1 THEN @Denominator_Diag_code ELSE  md.Denominator_Diag_code END

    AND ((e.IsEncrypt = 1)
    OR (e.IsEncrypt = 0))
	*/
	SELECT @Exam_Id=Exam_Id from [dbo].[fnMIPSExamDataKeyParameters] (
				   @Physician_NPI
				  ,@Exam_TIN
				  ,@Patient_Id
				  ,@DecryptPatient_Id
				  ,@Measure_num
				  ,@Procedure_Code				  
				  ,TRY_PARSE(@Examdate AS datetime)
				  ,TRY_PARSE(@CMS_Submission_Year AS int)
				  ,@Exam_Unique_Id
				  ,@Criteria
				  ,@Denominator_Diag_code
				  ,@Numerator_Code)--Change#3

    IF (@Exam_Id > 0)

    BEGIN
 


      UPDATE tbl_Exam
      SET Patient_Age = LTRIM(RTRIM(TRY_PARSE(@Patient_Age AS decimal(18, 2)))),
          PartnerID = LTRIM(RTRIM(@PartnerId)),
          Patient_Gender = LTRIM(RTRIM(@Patient_Gender)),
          Patient_ID = LTRIM(RTRIM(@Patient_Id)),
          IsEncrypt = CAST(( CASE WHEN UPPER(@IsEncrypt) = 'TRUE' THEN 1 ELSE 0 END) as bit),
          Patient_Medicare_Advantage = LTRIM(RTRIM(TRY_PARSE(@Patient_Medicare_Advantage AS smallint))),
          Patient_Medicare_Beneficiary = LTRIM(RTRIM(TRY_PARSE(@Patient_Medicare_Beneficiary AS smallint))),
          Exam_Date = LTRIM(RTRIM(TRY_PARSE(@Examdate AS datetime))),
          Last_Modified_Date = GETDATE(),
          Last_Modified_By = @Created_By,
          CMS_Submission_Year = LTRIM(RTRIM(TRY_PARSE(@CMS_Submission_Year AS int))),
          Exam_Unique_ID = LTRIM(RTRIM(@Exam_Unique_ID)),
          DataSource_Id = @DataSource_Id,
          File_ID = @FileId
      WHERE Exam_Id = @Exam_id

      IF (@warningFound = 1)
      BEGIN

        SET @_updatedRecordsWithWarning =  + @_updatedRecordsWithWarning + 1;

      END
      ELSE
      BEGIN
        SET @_updatedRecords = @_updatedRecords  + 1;

      END
	
      --STEP#3 Update/Insert Exam measure data.
      SELECT
        @measure_Id = Measure_ID
      FROM tbl_Lookup_Measure m WITH (NOLOCK)
      WHERE m.CMSYear = TRY_PARSE(@CMS_Submission_Year AS int)
      AND m.Measure_num = @Measure_Num

      IF (@measure_Id > 0)
      BEGIN
   
        SELECT
          @Exam_Measure_Id = Exam_Measure_Id
        FROM tbl_Exam_Measure_Data WITH (NOLOCK)
        WHERE Exam_Id = @Exam_id
        AND Measure_ID = @measure_Id
        AND CMS_Submission_Year = TRY_PARSE(@CMS_Submission_Year AS int)
        AND ISNULL(Criteria, 'NA') = ISNULL(@Criteria, 'NA')--Change #1:
        AND Denominator_proc_code = @Denominator_proc_code
        IF (@Exam_Measure_Id > 0)
        BEGIN

          UPDATE em
          SET em.Denominator_proc_code = @Denominator_proc_code,
              em.Denominator_Diag_code = @Denominator_Diag_code,
              em.Last_Mod_Date = GETDATE(),
              em.Last_Mod_By = @Created_By,
              em.Numerator_response_value =  isnull(TRY_PARSE(@Numerator_response_value AS smallint), 0),
              em.[Status] = @Status,
              em.CMS_Submission_Year = TRY_PARSE(@CMS_Submission_Year AS int),
              em.Criteria = @Criteria,
              em.Numerator_Code = @Numerator_Code
          FROM tbl_Exam_Measure_Data em              --Change #2
          WHERE em.exam_measure_id = @Exam_Measure_Id
       

        END
        ELSE
        BEGIN

          INSERT INTO tbl_Exam_Measure_Data (Exam_Id,
          Measure_ID,
          [Denominator_proc_code]
          , [Denominator_Diag_code]
          , [Numerator_response_value]
          , [Status]
          , [Created_Date]
          , [Created_By]
          , [CMS_Submission_Year]
          ,Criteria
          ,Numerator_Code
          )
           Values(
              @Exam_Id,
              @measure_Id,
              @Denominator_proc_code,
              @Denominator_Diag_code,
              isnull(TRY_PARSE(@Numerator_response_value AS smallint), 0),
              @Status,
              GETDATE(),
              @Created_By,
              TRY_PARSE(@CMS_Submission_Year AS int),
               @Criteria,
               @Numerator_Code
			  )
  
          SET @exam_measure_id = SCOPE_IDENTITY()
        END
        --STEP #4: Update Measure Data Extension 
        --start measure extension


        SELECT
          @other_ques_num = Me.Other_Question_Num,
          @_meas_Ext_Id = ME.Measure_Ext_Id
        FROM tbl_Lookup_Measure_Extension ME
		where ME.Measure_num=@Measure_num and CMSYear= TRY_PARSE(@CMS_Submission_Year AS int)
        
        IF (@exam_measure_id > 0
          AND LEN(@Response_Value) > 0)
        BEGIN

          IF NOT EXISTS (SELECT
              1
            FROM tbl_Exam_Measure_Data_Extension A WITH (NOLOCK)
            WHERE A.Other_Question_num = @other_ques_num
            AND A.Measure_Ext_Id = @_meas_Ext_Id and A.Exam_Measure_Data_ID=@exam_measure_id)
          BEGIN
       
            INSERT INTO [dbo].[tbl_Exam_Measure_Data_Extension] ([Exam_Measure_Data_ID]
            , [Measure_Ext_Id]
            , [Other_Question_num]
            , [Response_Value]
            , [Created_by]
            , [Created_Date]
            --,[Last_Modified_Date]
            --,[Last_Modified_By]
            )
              SELECT
                @Exam_Measure_Id,
                ISNULL(@_meas_Ext_Id, 0),
                @other_ques_num,
                CASE
                  WHEN @Response_Value IS NOT NULL AND
                    LEN(@Response_Value) > 0 THEN SUBSTRING(@Response_Value, 1, (LEN(@Response_Value) - 1))
                  ELSE @Response_Value
                END AS Response_Value,
                @Created_By,
                GETDATE()

          END
          ELSE
          BEGIN

      
            UPDATE A
            SET A.Response_Value = (CASE
                  WHEN @Response_Value IS NOT NULL AND
                    LEN(@Response_Value) > 0 THEN SUBSTRING(@Response_Value, 1, (LEN(@Response_Value) - 1))
                  ELSE @Response_Value
                END),
                A.Last_Modified_By = @Created_By,
                A.Last_Modified_Date =GETDATE()
            FROM tbl_Exam_Measure_Data_Extension A WITH (NOLOCK)
            WHERE A.Other_Question_num = @other_ques_num
            AND A.Measure_Ext_Id = @_meas_Ext_Id
			and a.Exam_Measure_Data_ID=@exam_measure_id
          END
        END

      --end measure extension
      END
    END
    ELSE
    BEGIN
  
      PRINT ('Record Not Exist need to be insert exam data');
      --STEP #5 -- Insert tbl_Exam Data.

      INSERT INTO [dbo].[tbl_Exam] ([Physician_NPI]
      , [Exam_TIN]
      , [Patient_ID]
      , [Patient_Age]
      , [Patient_Gender]
      , [Patient_Medicare_Beneficiary]
      , [Patient_Medicare_Advantage]
      , [Exam_Date]
      , [Created_Date]
      , [Created_By]
      , [Exam_Unique_ID]
      , [PartnerID]

      , [DataSource_Id]
      , [CMS_Submission_Year]
      , [IsEncrypt]
      , [File_ID])
        VALUES (@Physician_NPI	--<Physician_NPI, varchar(50),>
        , @Exam_TIN		--<Exam_TIN, varchar(10),>
        , @Patient_ID		--<Patient_ID, varchar(500),>
        , TRY_PARSE(@Patient_Age AS decimal(18, 2))	--<Patient_Age, decimal(18,2),>
        , @Patient_Gender --<Patient_Gender, varchar(50),>
        , TRY_PARSE(@Patient_Medicare_Beneficiary AS smallint) --<Patient_Medicare_Beneficiary, smallint,>
        , TRY_PARSE(@Patient_Medicare_Advantage AS smallint)--<Patient_Medicare_Advantage, smallint,>
        , TRY_PARSE(@Examdate AS datetime)	--<Exam_Date, datetime,>
        , GETDATE() --<Created_Date, datetime,>
        , @Created_By		--<Created_By, varchar(50),>
        , @Exam_Unique_ID--<Exam_Unique_ID, varchar(500),>
        , @PartnerID---<PartnerID, varchar(50),>
        , @DataSource_Id--<DataSource_Id, int,>
        , TRY_PARSE(@CMS_Submission_Year AS int)--<CMS_Submission_Year, int,>
        ,CAST(( CASE WHEN UPPER(@IsEncrypt) = 'TRUE' THEN 1 ELSE 0 END) as bit)--<IsEncrypt, bit,>
        , @FileId
        )
      SET @Exam_Id = SCOPE_IDENTITY();
    
      IF (@Exam_Id > 0)
      BEGIN

        IF (@warningFound = 1)
        BEGIN


          SET @_addedRecordsWithWarning = @_addedRecordsWithWarning  + 1;

        END
        ELSE
        BEGIN
          SET @_addedRecords = @_addedRecords + 1;
    END

	 


        --STEP #5 	--Insert Exam MeasureData

        SELECT TOP 1
          @MeasureID = Measure_ID
        FROM tbl_Lookup_Measure
        WHERE CMSYear = TRY_PARSE(@CMS_Submission_Year AS int)
        AND Measure_num = @Measure_num

    

        INSERT INTO [dbo].[tbl_Exam_Measure_Data] ([Exam_Id]
        , [Measure_ID]
        , [Denominator_proc_code]
        , [Denominator_Diag_code]
        , [Numerator_response_value]
        , [Status]
        --  --,[CMS_Submission_Status]
        , [Created_Date]
        , [Created_By]

        , [CMS_Submission_Year]

        , [Criteria]
        , [Numerator_Code])
       VALUES(
            @Exam_Id,
            @MeasureID,
            @Denominator_proc_code,
            @Denominator_Diag_code,
            ISNULL(TRY_PARSE(@Numerator_response_value AS smallint),0),
            @Status,
            GETDATE(),
            @Created_By,
            TRY_PARSE(ISNULL(@CMS_Submission_Year, '') AS int),
            @Criteria,
            @Numerator_Code
			)
          
        SET @Exam_Measure_Id = SCOPE_IDENTITY();

        IF (@Exam_Measure_Id > 0)
        BEGIN
  

          --start measure extension



        SELECT
        @other_ques_num = Me.Other_Question_Num,
        @_meas_Ext_Id = ME.Measure_Ext_Id
        FROM tbl_Lookup_Measure_Extension ME
		where ME.Measure_num=@Measure_num and CMSYear= TRY_PARSE(@CMS_Submission_Year AS int)



          IF (@exam_measure_id > 0
            AND LEN(@Response_Value) > 0)
          BEGIN

            IF NOT EXISTS (SELECT
                1
              FROM tbl_Exam_Measure_Data_Extension A WITH (NOLOCK)
              WHERE A.Other_Question_num = @other_ques_num
              AND A.Measure_Ext_Id = @_meas_Ext_Id  and A.Exam_Measure_Data_ID=@exam_measure_id)
            BEGIN
 
              INSERT INTO [dbo].[tbl_Exam_Measure_Data_Extension] ([Exam_Measure_Data_ID]
              , [Measure_Ext_Id]
              , [Other_Question_num]
              , [Response_Value]
              , [Created_by]
              , [Created_Date]
              --,[Last_Modified_Date]
              --,[Last_Modified_By]
              )
                SELECT
                  @Exam_Measure_Id,
                  ISNULL(@_meas_Ext_Id, 0),
                  @other_ques_num,
                  CASE
                    WHEN @Response_Value IS NOT NULL AND
                      LEN(@Response_Value) > 0 THEN SUBSTRING(@Response_Value, 1, (LEN(@Response_Value) - 1))
                    ELSE @Response_Value
                  END AS Response_Value,
                  @Created_By,
                 GETDATE()

            END
            ELSE
            BEGIN

              UPDATE A
              SET A.Response_Value = (CASE
                    WHEN @Response_Value IS NOT NULL AND
                      LEN(@Response_Value) > 0 THEN SUBSTRING(@Response_Value, 1, (LEN(@Response_Value) - 1))
                    ELSE @Response_Value
                  END),
                  A.Last_Modified_By = @Created_By,
                  A.Last_Modified_Date = GETDATE()
              FROM tbl_Exam_Measure_Data_Extension A WITH (NOLOCK)
              WHERE A.Other_Question_num = @other_ques_num
              AND A.Measure_Ext_Id = @_meas_Ext_Id
			  AND A.Exam_Measure_Data_ID=@Exam_Measure_Id
            END
          END

        --end measure extension
        --end measure extension																 
        END
        ELSE
        BEGIN
   
   print('')

        END
      END

    END
  END TRY
  BEGIN CATCH

		INSERT INTO [dbo].[tbl_Data_Error]
           (
		   [Exam_Date]
           ,[Exam_TIN]
           ,[Physician_NPI]
           ,[Patient_ID]
           ,[Patient_Age]
           ,[Patient_Gender]
           ,[Patient_Medicare_Beneficiary]
           ,[Patient_Medicare_Advantage]
           ,[Measure_Num]
           ,[Denominator_Proc_code]
           ,[Denominator_Diag_code]
           ,[Numerator_Response_Value]
           ,[Measure_Extension_Number]
           ,[Extension_Response_value]
           ,[Exam_Unique_ID]
           ,[Error_Msg]
           ,[DataSource_Id]
           ,[CMS_Submission_Year]
           ,[File_ID]
          -- ,[Transaction_ID]
           ,[Created_Date]
           ,[Created_By]
           ,[Warning]
           ,[Exclusion]
		   )
     VALUES
           (
		    @Examdate 
           ,@Exam_TIN
           ,@Physician_NPI
           ,@Patient_ID
           ,@Patient_Age
           ,@Patient_Gender
           ,@Patient_Medicare_Beneficiary
           ,@Patient_Medicare_Advantage
           ,@Measure_num
           ,@Denominator_proc_code
           ,@Denominator_Diag_code
           ,@Numerator_response_value
           ,@measure_ext_number
           ,@Response_Value
           ,@Exam_Unique_Id
           ,CAST(ERROR_MESSAGE() AS varchar(max))
           ,cast(@DataSource_Id as int)
           ,cast(@CMS_Submission_Year as int)
           ,cast(@FileId as int)
           --,<Transaction_ID, varchar(50),>
           ,GETDATE()
           ,@Created_By
           ,@warning
           ,@exclusion
		   )
		   SET @_rejectedRecords=@_rejectedRecords+1;

	

  END CATCH

    FETCH NEXT FROM Cur_tbl_Exam_Type INTO  @Measure_num,@Examdate,@Exam_Unique_Id , @Exam_TIN, @Physician_NPI, @Patient_ID,  @Patient_Age, @Patient_Gender,
  @Patient_Medicare_Beneficiary, @Patient_Medicare_Advantage,  @CMS_Submission_Year,@DecryptPatient_Id, @Procedure_Code,@Criteria, @warningFound, @Denominator_proc_code  ,@Denominator_Diag_code ,@Numerator_response_value  ,@Numerator_Code ,@Other_Question_num ,
  @Response_Value,@IsEncrypt,@measure_ext_number,@warning, @exclusion 

  END
  CLOSE Cur_tbl_Exam_Type;
  DEALLOCATE Cur_tbl_Exam_Type;
  Update tbl_ApiRequstedFilesList  set ProcessedRecords=@ProcessedCount, CountUpdateOn= GETDATE() where FileId=@FileId and ReqId=@ReqId  --Change #2
  SELECT
    @_addedRecords AS _addedRecords,
    @_addedRecordsWithWarning AS _addedRecordsWithWarning,
    @_updatedRecords AS _updatedRecords,
    @_updatedRecordsWithWarning AS _updatedRecordsWithWarning
END


