








-- =============================================
-- Author:		PRashanth kumar Garlapally
-- Create date: 17-jul-2014
-- Description:	Used to validate Import Exam and its subset measures,measure Extension data and genereate errors.
-- Change #1:	Sai Rama muthiReddy/PRashant
-- Change Dte:	17-dec-14
-- Change Desc:	Make Medicare Beneficiary & Medicare Advantage optional but can have 'NA' or 'Y' or 'N'.
-- Change #2:  King Lo
-- Change Date: 16-jan-18
-- Change Desc: Call NRDR directly to validate NPI instead of using table variable
-- Change #3:  Hari J
-- Change Date: 13-APRIL-18
-- Change Desc: Call NRDR directly to validate NPI and TIN  instead of using sp_validateTIN
-- Change #4:  Hari J
-- Change Date: 22-May-18
-- Change Desc: Missing NPIs inserting with the help of SPCheck_NPI_Exists
-- Change #5:  Hari J
-- Change Date: 7-July-18
-- Change Desc: For JIRA#566

-- =============================================
CREATE PROCEDURE [dbo].[spValidateImportExam_Nrdr13x] 
	-- Add the parameters for the stored procedure here
    @ExamsID INT = 0 ,
    @TransactionID VARCHAR(100) = '' ,
    @ParentNode VARCHAR(MAX) = ''  ,
    @FacilityID VARCHAR (50) = ''
AS 
    BEGIN
        SET DATEFORMAT MDY ;

        DECLARE @Import_examID INT ,
            @Import_Physician_Group_TIN VARCHAR(50) ,
            @Import_Exam_Unique_ID VARCHAR(50) ,
            @Import_Exam_DateTime VARCHAR(50) ,
            @Import_Physician_NPI VARCHAR(50) ,
            @Import_First_Name VARCHAR(50) ,
            @Import_Last_Name VARCHAR(50) ,
            @Import_Patient_ID VARCHAR(50) ,
            @Import_Patient_Age VARCHAR(50) ,
            @Import_Patient_Gender VARCHAR(50) ,
            @Import_Patient_Medicare_Beneficiary VARCHAR(50) ,
            @Import_Patient_Medicare_Advantage VARCHAR(50) ,
            @Import_Num_of_Measures_Included VARCHAR(50)		
        DECLARE @message VARCHAR(MAX) ;
        DECLARE @messageJSON VARCHAR(MAX) ;
        DECLARE @iParentNode VARCHAR(MAX) ;
        DECLARE @intMeasuresCount INT ;
        DECLARE @blnMeasureDataExists BIT ;
        DECLARE @intCorrectMeasureCount INT ;
        DECLARE @intInCorrectMeasureCount INT ;
--
        DECLARE @intSuccessMeasureCount INT
        DECLARE @intPartialSuccessMeasureCount INT
        DECLARE @intValidationFailedMeasureCount INT

        DECLARE @strDuplicateMeasuresinExam VARCHAR(500)	

	  -- Change #5: 
        DECLARE @No_of_Errors INT
	   DECLARE @intCorrect_Measure_DataWith_WarningCount int
		
		DECLARE @x as varchar(50)

        DECLARE Cursor_Imp_Exam CURSOR FOR 
        SELECT Import_examID,Import_Physician_Group_TIN,Import_Exam_Unique_ID,	Import_Exam_DateTime,	Import_Physician_NPI,	Import_First_Name,	Import_Last_Name,	Import_Patient_ID,	Import_Patient_Age,	Import_Patient_Gender,	Import_Patient_Medicare_Beneficiary,	Import_Patient_Medicare_Advantage,	Import_Num_of_Measures_Included	
        FROM tbl_Import_Exam WITH(NOLOCK) WHERE Import_ExamsID  = @ExamsID

        OPEN Cursor_Imp_Exam

        FETCH NEXT FROM Cursor_Imp_Exam 
INTO  @Import_examID,
	
	@Import_Physician_Group_TIN	,	
	@Import_Exam_Unique_ID	,	
	@Import_Exam_DateTime	,	
	@Import_Physician_NPI	,	
	@Import_First_Name	,	
	@Import_Last_Name	,	
	@Import_Patient_ID	,	
	@Import_Patient_Age	,	
	@Import_Patient_Gender ,		
	@Import_Patient_Medicare_Beneficiary ,		
	@Import_Patient_Medicare_Advantage ,		 
	@Import_Num_of_Measures_Included 

        WHILE @@FETCH_STATUS = 0 
            BEGIN
                SET @message = '' ;
                SET @No_of_Errors = 0 ;
	-- set @iParentNode = @ParentNode  + '\Facility Id:' + ISNULL(@Import_Facility_ID,'<missing>')  + '\Unique Exam Id:' + ISNULL(@Import_Exam_Unique_ID,'<missing>') 
                SET @iParentNode = '' ;
   
     
                IF ( @Import_Exam_Unique_ID IS NULL )
                    OR ( ISNULL(@Import_Exam_Unique_ID, '') = '' ) 
                    BEGIN
                        SET @message = @message
                            + 'P3001:Missing Exam_Unique_ID' + CHAR(10) ;
                        SET @No_of_Errors = @No_of_Errors + 1 ;
                    END
    
                IF ( ISNULL(@Import_Exam_Unique_ID, '') <> '' ) 
                    BEGIN
                        SELECT  @message = @message
                                + 'P3004: Exam_Unique_ID must be unique. Exam_Unique_ID ['
                                + ISNULL(@Import_Exam_Unique_ID, '')
+ '] is submitted multiple times in Transaction ID ['
                                + ISNULL(@TransactionID, '') + '].' + CHAR(10) ,
                                @No_of_Errors = @No_of_Errors + 1
                        FROM    tbl_Import_Exam
                        WHERE   Import_examID = @Import_examID
                                AND ISNULL(Import_Exam_Unique_ID, '') = ISNULL(@Import_Exam_Unique_ID,
                                                              '')
                        GROUP BY Import_examID ,
                                Import_Exam_Unique_ID
                        HAVING  COUNT(Import_Exam_Unique_ID) > 1
                    END
    
    
                IF ( @Import_Exam_DateTime IS NULL )
                    OR ( ISNULL(@Import_Exam_DateTime, '') = '' ) 
                    BEGIN

                        SET @message = @message + 'P3011:Missing Exam_Date'
                            + CHAR(10) ;
                        SET @No_of_Errors = @No_of_Errors + 1 ;
                    END
                ELSE 
                    IF ISDATE(@Import_Exam_DateTime) = 0 
                        BEGIN
				  
                            SET @message = @message + 'P3012:Exam_Date ('
                                + @Import_Exam_DateTime
                                + ')is not a valid date time in format mm/dd/yyyy'
                                + CHAR(10) ;
                            SET @No_of_Errors = @No_of_Errors + 1 ;
                        END
                    ELSE 
                        IF ( ISDATE(@Import_Exam_DateTime) = 1
                             AND ( CONVERT(DATETIME, @Import_Exam_DateTime, 101) > GETDATE() )
                           ) 
                            BEGIN		

                                SET @message = @message + 'P3013:Exam_Date ('
                                    + @Import_Exam_DateTime
                                    + ')is future dated. Tested format mm/dd/yyyy'
                                    + CHAR(10) ;
                                SET @No_of_Errors = @No_of_Errors + 1 ;
                            END
		
	
                IF ( @Import_First_Name IS NULL )
                    OR ( ISNULL(@Import_First_Name, '') = '' ) 
                    BEGIN
                        SET @message = @message
                            + 'P3021:Missing Physician_First_Name' + CHAR(10)
                            + @iParentNode + ']' ;
                        SET @No_of_Errors = @No_of_Errors + 1 ;
                    END
    
                IF ( @Import_Last_Name IS NULL )
                    OR ( ISNULL(@Import_Last_Name, '') = '' ) 
                    BEGIN
                        SET @message = @message
                            + 'P3031:Missing Physician_Last_Name' + CHAR(10) ;
                        SET @No_of_Errors = @No_of_Errors + 1 ;
                    END
    
                IF ( @Import_Physician_NPI IS NULL )
                    OR ( ISNULL(@Import_Physician_NPI, '') = '' ) 
                    BEGIN
                        SET @message = @message
                            + 'P3041:Missing Physician_NPI in submitted data'
                            + CHAR(10) ;
                        SET @No_of_Errors = @No_of_Errors + 1 ;
                    END
                ELSE 
                    IF NOT EXISTS ( SELECT  NPI
                                    FROM    tbl_Users WITH ( NOLOCK )
                                    WHERE   LTRIM(RTRIM(NPI)) = LTRIM(RTRIM(@Import_Physician_NPI)) ) 
                        BEGIN
				    ---TODO:
                               ---check wheather NPI exists or non in tbl_users Hari J on May 4th -2018
                              -- if not exists we will insert npi with the help of "sp_getPhysianProfileForNPI"
                         -- Change #4
					declare @StatusCode int =0;

                       exec dbo.SPCheck_NPI_Exists @Import_Physician_NPI, @StatusCode=@StatusCode OUTPUT
				   IF(@StatusCode<>1)--1=new record inserted in tbl_users table
				   BEGIN
                            SET @message = @message
                                + 'P3042:Entered Physician_NPI('
                                + @Import_Physician_NPI
                                + ') has not registered for PQRS. Physician is required to register in order to participate.'
                                + CHAR(10) 
                   SET @No_of_Errors = @No_of_Errors + 1 ;
			    END
                        END
                    ELSE 
                        IF EXISTS ( SELECT  NPI
                                    FROM    tbl_Users WITH ( NOLOCK )
                                    WHERE   LTRIM(RTRIM(NPI)) = LTRIM(RTRIM(@Import_Physician_NPI))
                                            AND ISNULL(Attested, 0) = 0 ) 
                            BEGIN
                                SET @message = @message
                                    + 'P3043:Entered Physician_NPI('
                                    + @Import_Physician_NPI
                                    + ') has registered for PQRS. However Physician is yet to accept the terms and conditions in order to participate.'
                                    + CHAR(10) 
                                SET @No_of_Errors = @No_of_Errors + 1 ;
                            END
                            
                   ELSE 
					   BEGIN

					   /* King Lo 2018-01-26
								declare @NPIList table (Firstname varchar(25), Lastname varchar(25),Physician_NPI varchar(25))
      							set @x  = ''
								select @x = ISNULL(@FacilityID,'')
								insert @NPIList (Firstname ,Lastname, Physician_NPI)
								exec nrdr..[sp_getPhysicianNPIByFacilityID] @x,@Import_Physician_NPI
								
								if not exists(select top 1 * from @NPIList where Physician_NPI = @Import_Physician_NPI )
						*/
						set @x  = ''
					    select @x = ISNULL(@FacilityID,'')

						--old nrdr10x code
			
						--if not exists(select top 1 nupp.npi from [NRDR]..physician p with (nolock)
      --                        inner join [NRDR]..nrdr_user_physician_profile nupp with (nolock) on (nupp.npi = p.npi)
      --                        inner join [NRDR]..aspnet_Users au with (nolock) on (au.UserId = nupp.UserId)
      --                        where nupp.npi <> '' and  p.facility_id = @x  and p.NPI = case isnull(@Import_Physician_NPI,'') 
      --                        when '' then  p.NPI else @Import_Physician_npi end )
	  if not exists(select top 1 p.npi from [NRDR]..physician p with (nolock)
inner join [NRDR].. nrdr_user_profile nup with (nolock) on (nup.physician_id = p.id)
inner join [NRDR].. aspnet_Users au with (nolock) on (au.UserId = nup.UserId)
where p.npi <> ''
and (p.id in (select physician_id from [NRDR].. physician_to_facility_to_registry where facility_id = @x))
and p.NPI = case isnull(@Import_Physician_NPI,'') when '' then p.NPI else @Import_Physician_npi end )

								Begin
								set @message = @message + 'P3044:PhysicianNPI( '+ @Import_Physician_NPI
                                    + ' ) you have submitted is not under facilityID( '+ ISNULL(@FacilityID,'') + ' )' + + CHAR(10) ;
								set @No_of_Errors = @No_of_Errors +1;
								End


							/*

								if not exists(select top 1 * from #NPIFacilityIDs where NPI <>'' and FacilityID=@x and NPI=@Import_Physician_NPI )
								Begin
								set @message = @message + 'P3044:PhysicianNPI( '+ @Import_Physician_NPI
                                    + ' ) you have submitted is not under facilityID( '+ ISNULL(@FacilityID,'') + ' )' + + CHAR(10) ;
								set @No_of_Errors = @No_of_Errors +1;
								End  */
								
					   END 
    
		--Declare @Count integer;
  --      set @Count=0;
  --      exec @Count= NRDR9X..sp_validateTIN @Import_Physician_NPI,@Import_Physician_Group_TIN 
  /*
                CREATE TABLE #validTin ( x INT )
                DECLARE @Count INTEGER ;
                SET @Count = 1 ;
                INSERT  INTO #validTin
                        ( x
                        )
                        EXEC @Count = nrdr..sp_validateTIN @Import_Physician_NPI,
                            @Import_Physician_Group_TIN
       
                IF EXISTS ( SELECT  1
                            FROM    #validTin
                            WHERE   x = 0 ) 
                    BEGIN	
                        SET @Count = 0 ;
                    END       
                DROP TABLE #validTin
        */
	   --chnaged by HARI j on APRIL/13/2018
	   -- Change #3
	     DECLARE @Count INTEGER ;
                SET @Count = 1 ;
				
	   --old code in nrdr10x.acr.org
  --              IF EXISTS ( SELECT 1 FROM [NRDR]..REGISTRY_TIN RT
		--INNER JOIN [NRDR]..PHYSICIAN P ON (P.FACILITY_ID = RT.FACILITY_ID)
		--INNER JOIN [NRDR]..NRDR_USER_PHYSICIAN_PROFILE NPP ON (NPP.NPI = P.NPI)
		--WHERE (P.NPI = @Import_Physician_NPI) AND (RT.NUMBER = @Import_Physician_Group_TIN) ) 
		--new code in nrdr13x.acr.org
		              IF EXISTS ( SELECT 1 FROM 
					NRDR..PHYSICIAN_TO_FACILITY_TO_REGISTRY f inner join 
 nrdr..REGISTRY_TIN RT on f.FACILITY_ID=RT.FACILITY_ID join 
nrdr..PHYSICIAN p on p.ID=f.PHYSICIAN_ID
		WHERE (P.NPI = @Import_Physician_NPI) AND (RT.NUMBER = @Import_Physician_Group_TIN) ) 
                    BEGIN	
                        SET @Count = 0 ;
                    END   

				 IF (LTRIM(RTRIM(ISNULL(@Import_Physician_Group_TIN,
                                                    '')))) = '' 
                    BEGIN
                        SET @message = @message
                            + 'P3051:Missing Physician_Group_TIN in submitted data.'
                            + CHAR(10) ;
                        SET @No_of_Errors = @No_of_Errors + 1 ;
                    END
                ELSE IF dbo.IsInteger(LTRIM(RTRIM(ISNULL(@Import_Physician_Group_TIN,
                                                    '')))) = 0 
                    BEGIN
                        SET @message = @message
                            + 'P3053:Invalid Physician_Group_TIN [' +
                            LTRIM(RTRIM(ISNULL(@Import_Physician_Group_TIN,'')))
                            +'] must be an integer of 9 digits.'
                            + CHAR(10) ;
                        SET @No_of_Errors = @No_of_Errors + 1 ;
                    END
                ELSE IF LEN(LTRIM(RTRIM(ISNULL(@Import_Physician_Group_TIN, '')))) <> 9 
                        BEGIN
                            SET @message = @message
                                + 'P3052:Enterd Physician_Group_TIN ['
                                + LTRIM(RTRIM(ISNULL(@Import_Physician_Group_TIN,
                                                     '')))
                                + '] must be of 9 digits.' + CHAR(10) ;
                            SET @No_of_Errors = @No_of_Errors + 1 ;
                        END
	
                    ELSE 
                        IF ( @Count = 1 ) 
                            BEGIN
                                SET @message = @message
                                    + 'P3054:Entered Physician_Group_TIN ['
                                    + LTRIM(RTRIM(ISNULL(@Import_Physician_Group_TIN,
                                                         '')))
                                    + '] and Physician_NPI ['
                                    + LTRIM(RTRIM(ISNULL(@Import_Physician_NPI,
                                                         '')))
                                    + '] mapping not found. ' + CHAR(10) ;
                                SET @No_of_Errors = @No_of_Errors + 1 ;
                            END 
    
    
    
                IF ( @Import_Patient_ID IS NULL )
                    OR ( ISNULL(@Import_Patient_ID, '') = '' ) 
                    BEGIN
                        SET @message = @message + 'P3061:Missing Patient_ID'
                            + CHAR(10) ;
                        SET @No_of_Errors = @No_of_Errors + 1 ;
                    END
    
     
   
                IF ( @Import_Patient_Age IS NULL )
                    OR ( ISNULL(@Import_Patient_Age, '') = '' ) 
                    BEGIN
                        SET @message = @message + 'P3071:Missing Patient_Age'
                            + CHAR(10) ;
                        SET @No_of_Errors = @No_of_Errors + 1 ;
                    END
                ELSE 
                    IF dbo.IsInteger(ISNULL(@Import_Patient_Age, '')) = 0 
                        BEGIN
				
   
                            SET @message = @message
                                + 'P3072:Entered Patient_Age ['
                                + LTRIM(RTRIM(ISNULL(@Import_Patient_Age, '')))
                                + '] not a valid 1 to 3 digit integer.'
                                + CHAR(10) ;
                            SET @No_of_Errors = @No_of_Errors + 1 ;
                        END
                    ELSE 
                        IF dbo.IsInteger(ISNULL(@Import_Patient_Age, '')) = 1
                            AND ( (CONVERT(INTEGER, @Import_Patient_Age) < 1
                                  OR ( CONVERT(INTEGER, @Import_Patient_Age) > 130 ))
                                ) 
                            BEGIN
				
                                SET @message = @message
                                    + 'P3073:Entered Patient_Age ['
                                    + LTRIM(RTRIM(ISNULL(@Import_Patient_Age,
                                                         '')))
                                    + '] is out of range. Valid range is 1 to 130.'
                                    + CHAR(10) ;
                                SET @No_of_Errors = @No_of_Errors + 1 ;
                            END
	--else if dbo.IsInteger(ISNULL(@Import_Patient_Age,'')) = 1 
	--	begin
	--		-- Validate Measure numbers to age
	
	--	select 	@message = @message + 'P3503: Patient must be [' + CONVERT(varchar(10),M.Age_Restriction) + '] and older to be eligible for measure [' + I.Import_Measure_num + ']. Submitted patient age value is (' + LTRIM(rtrim(ISNULL(@Import_Patient_Age,''))
--) + ').' + CHAR(10),
	--	@No_of_Errors = @No_of_Errors +1
	--	from tbl_Import_Exam_Measure_Data I inner join 
	--	tbl_Lookup_Measure M on  M.Measure_num =  I.Import_Measure_num
	--	where I.Import_ExamID = @Import_examID and  M.Age_Restriction > convert(integer,LTRIM(rtrim(ISNULL(@Import_Patient_Age,'0'))))
			
	--	End
		
		
    
                IF ( @Import_Patient_Gender IS NULL )
                    OR ( ISNULL(@Import_Patient_Gender, '') = '' ) 
                    BEGIN
				
                        SET @message = @message
                            + 'P3081:Missing Patient_Gender' + CHAR(10) ;
                        SET @No_of_Errors = @No_of_Errors + 1 ;
                    END
                ELSE 
                    IF ( LOWER(ISNULL(@Import_Patient_Gender, '')) <> 'm'
                         AND LOWER(ISNULL(@Import_Patient_Gender, '')) <> 'f'
                         AND LOWER(ISNULL(@Import_Patient_Gender, '')) <> 'u'
                         AND LOWER(ISNULL(@Import_Patient_Gender, '')) <> 'o'
                       ) 
                        BEGIN

                            SET @message = @message
                                + 'P3082:Entered Patient_Gender ['
                                + LTRIM(RTRIM(ISNULL(@Import_Patient_Gender,
                                                     '')))
                                + '] must be "M" or "F" or "U" or "O".'
                                + CHAR(10) ;
                            SET @No_of_Errors = @No_of_Errors + 1 ;
                        END
	
		
    
    -- if (@Import_Patient_ID is null) or (ISNULL(@Import_Patient_ID,'') = '')
    --Begin
    --set @message = @message + 'P3091:Missing @Import_Patient_ID' + CHAR(10) ;
    -- set @No_of_Errors = @No_of_Errors +1;
    --End


      --some of measure numbers have particular Gender validation -starts-2018V


	 
     
    
                IF ( @Import_Patient_Medicare_Beneficiary IS NULL )
                    OR ( ISNULL(@Import_Patient_Medicare_Beneficiary, '') = '' ) 
                    BEGIN
			--set @message = @message + 'P3101:Missing Patient_Medicare_Beneficiary' + CHAR(10) ;
			--set @No_of_Errors = @No_of_Errors +1;
                        SET @Import_Patient_Medicare_Beneficiary = 'NA'
			
                    END
	--Else
                IF ( UPPER(ISNULL(@Import_Patient_Medicare_Beneficiary, '')) <> 'Y'
                     AND UPPER(ISNULL(@Import_Patient_Medicare_Beneficiary, '')) <> 'N'
                     AND UPPER(ISNULL(@Import_Patient_Medicare_Beneficiary, '')) <> 'NA'
                   ) 
                    BEGIN
                        SET @message = @message
                            + 'P3102:Entered Patient_Medicare_Beneficiary ['
                            + LTRIM(RTRIM(ISNULL(@Import_Patient_Medicare_Beneficiary,
                                                 '')))
                            + '] must be "Y" for "Yes" or "N" for "No" or "NA" for "Not Available".'
                            + CHAR(10) ;
                        SET @No_of_Errors = @No_of_Errors + 1 ;
                    END
		 
	
                IF ( @Import_Patient_Medicare_Advantage IS NULL )
                    OR ( ISNULL(@Import_Patient_Medicare_Advantage, '') = '' ) 
                    BEGIN
			--set @message = @message + 'P3111:Missing Patient_Medicare_Advantage' + CHAR(10);
			--set @No_of_Errors = @No_of_Errors +1;
                        SET @Import_Patient_Medicare_Advantage = 'NA'
                    END
   --Else
   
                IF ( UPPER(ISNULL(@Import_Patient_Medicare_Advantage, '')) <> 'Y'
                     AND UPPER(ISNULL(@Import_Patient_Medicare_Advantage, '')) <> 'N'
                     AND UPPER(ISNULL(@Import_Patient_Medicare_Advantage, '')) <> 'NA'
                   ) 
                    BEGIN
                        SET @message = @message
                            + 'P3112:Entered Patient_Medicare_Advantage ['
                            + LTRIM(RTRIM(ISNULL(@Import_Patient_Medicare_Advantage,
                                                 '')))
                            + '] must be "Y" for "Yes" or "N" for "No" or "NA" for "Not Available".'
                            + CHAR(10) ;
                        SET @No_of_Errors = @No_of_Errors + 1 ;
                    END
		
                ELSE 
                    IF ( UPPER(ISNULL(@Import_Patient_Medicare_Beneficiary, '')) = 'N' ) 
                        BEGIN
			
                            IF ( UPPER(ISNULL(@Import_Patient_Medicare_Advantage,
                      '')) <> 'N'
                                 AND UPPER(ISNULL(@Import_Patient_Medicare_Advantage,
                                                  '')) <> 'NA'
                               ) 
                                BEGIN
                                    SET @message = @message
                                        + 'P3113: Invalid Patient_Medicare_Advantage.'
                                        + CHAR(10) ;
                                    SET @No_of_Errors = @No_of_Errors + 1 ;
                                END
                        END	
                    ELSE 
                        IF ( UPPER(ISNULL(@Import_Patient_Medicare_Beneficiary,
                                          '')) = 'NA' ) 
                            BEGIN
			
                                IF ( UPPER(ISNULL(@Import_Patient_Medicare_Advantage,
                                                  '')) <> 'NA' ) 
                                    BEGIN
                                        SET @message = @message
                                            + 'P3114: Invalid Patient_Medicare_Advantage.'
                                            + CHAR(10) ;
                                        SET @No_of_Errors = @No_of_Errors + 1 ;
                                    END
                            END	
    
    
		
    
                IF ( @Import_Num_of_Measures_Included IS NULL )
                    OR ( ISNULL(@Import_Num_of_Measures_Included, '') = '' ) 
                    BEGIN
                        SET @message = @message
                            + 'P3121:Missing Num_of_Measures_Included'
                            + CHAR(10) ;
                        SET @No_of_Errors = @No_of_Errors + 1 ;
                    END
                SET @blnMeasureDataExists = 1 ;
                SET @intMeasuresCount = 0
                IF NOT EXISTS ( SELECT TOP 1
                                        *
                                FROM    tbl_Import_Exam_Measure_Data
                                WHERE   Import_ExamID = @Import_examID ) 
                    BEGIN
                        SET @message = @message + 'P3131:Missing Measure_Data'
                            + CHAR(10) ;
                        SET @No_of_Errors = @No_of_Errors + 1 ;
                        SET @blnMeasureDataExists = 0
                    END
                ELSE 
                    BEGIN
                        SELECT  @intMeasuresCount = COUNT(*)
                        FROM    tbl_Import_Exam_Measure_Data
                        WHERE   Import_ExamID = @Import_examID
		 
                        IF dbo.IsInteger(@Import_Num_of_Measures_Included) = 1 
                            BEGIN
                                IF ( @intMeasuresCount <> CONVERT(INT, @Import_Num_of_Measures_Included) ) 
                                    BEGIN
                                        SET @message = @message
                                            + 'P3123: Data in Num_of_Measures_Included ('
                                            + @Import_Num_of_Measures_Included
                                            + ') does not match with Measures received ('
                                            + CONVERT(VARCHAR(10), @intMeasuresCount)
                                            + ')' + CHAR(10) ;
                                        SET @No_of_Errors = @No_of_Errors + 1 ;
                                    END
                            END
                        ELSE 
                            BEGIN
                                IF ( ISNULL(@Import_Num_of_Measures_Included,
                                            '') <> '' ) 
                                    BEGIN
                                        SET @message = @message
                                            + 'P3122: Data in Num_of_Measures_Included  ('
                                      + @Import_Num_of_Measures_Included
                                            + ') is not an integer. '
                                            + CHAR(10) ;
                                        SET @No_of_Errors = @No_of_Errors + 1 ;
                                    END
                            END
				 
                    END
		
		
                SET @strDuplicateMeasuresinExam = ''
                SELECT  @strDuplicateMeasuresinExam = @strDuplicateMeasuresinExam
                        + CASE @strDuplicateMeasuresinExam
                            WHEN '' THEN ''
                            ELSE ','
                          END + LTRIM(RTRIM(ISNULL(Import_Measure_num, '')))
                FROM    tbl_Import_Exam_Measure_Data
                WHERE   Import_ExamID = @Import_examID
                GROUP BY Import_ExamID ,
                        Import_Measure_num ,
                        Import_CPT_Code ,
                        Import_Diagnosis_code ,
                        Import_Numerator_code
                HAVING  COUNT(*) > 1

                IF ( @strDuplicateMeasuresinExam <> '' ) 
                    BEGIN
                        SET @message = @message
                            + 'P3502: Following Measures ['
                            + @strDuplicateMeasuresinExam
                            + '] have been submitted multiple times for Exam Unique ID ['
                            + ISNULL(@Import_Exam_Unique_ID, '') + ']'
                            + CHAR(10)
                        SET @No_of_Errors = @No_of_Errors + 1
                    END
		
	
		
-- end of peer level validations		
		
		
                SET @intCorrectMeasureCount = 0 ;
                SET @intInCorrectMeasureCount = 0 ;
                SET @intSuccessMeasureCount = 0 ;
                SET @intPartialSuccessMeasureCount = 0 ;
                SET @intValidationFailedMeasureCount = 0 ;
			 SET @intCorrect_Measure_DataWith_WarningCount=0;
		
                IF ( @blnMeasureDataExists > 0 ) 
                    BEGIN
				
                        EXEC dbo.spValidateImportExamMeasureData @Import_examID,
                            @iParentNode
				--select @intCorrectMeasureCount = COUNT(*) from tbl_Import_Exam_Measure_Data where Import_ExamID = @Import_examID and ( Error_Codes_Desc  is null)
				--select @intInCorrectMeasureCount = COUNT(*) from tbl_Import_Exam_Measure_Data where Import_ExamID = @Import_examID and (Error_Codes_Desc is not null)
                        SELECT  @intCorrectMeasureCount = CASE
                                                              WHEN ( ( Error_Codes_Desc IS NULL ) AND ( Warning_Codes_Desc IS NULL ) -- Change #5:
                                                              AND ( ( [Status] = 3 )
                                                              OR ( [Status] = 4 )
                                                              )
                                                              )
                                                              THEN ( @intCorrectMeasureCount
                                                              + 1 )
                                                              ELSE @intCorrectMeasureCount
                                                          END ,
				 @intCorrect_Measure_DataWith_WarningCount = CASE  -- Change #5:
                                                              WHEN ( ( Warning_Codes_Desc IS NOT NULL )
                                                              AND ( ( [Status] = 3 )
                                                              OR ( [Status] = 4 )
                                                              )
                                                              )
                                                              THEN ( @intCorrect_Measure_DataWith_WarningCount
                                                              + 1 )
                                                              ELSE @intCorrect_Measure_DataWith_WarningCount
                                                          END ,
                                @intInCorrectMeasureCount = CASE
                                                              WHEN ( ( Error_Codes_Desc IS NOT NULL )
                                                              OR ( ( [Status] <> 3 )
                                                              AND ( [Status] <> 4 )
                                                              )
                                                              )
                                                              THEN ( @intInCorrectMeasureCount
                                                              + 1 )
        ELSE @intInCorrectMeasureCount
                                                            END ,
                                @intSuccessMeasureCount = CASE [Status]
                                                            WHEN 3
                                                            THEN ( @intSuccessMeasureCount
                                                              + 1 )
                                                            ELSE @intSuccessMeasureCount
                                                          END ,
                                @intPartialSuccessMeasureCount = CASE [Status]
                                                              WHEN 4
                                                              THEN ( @intPartialSuccessMeasureCount
                                                              + 1 )
                                                              ELSE @intPartialSuccessMeasureCount
                                                              END ,
                                @intValidationFailedMeasureCount = CASE [Status]
                                                              WHEN 5
                                                              THEN ( @intValidationFailedMeasureCount
                                                              + 1 )
                                                              ELSE @intValidationFailedMeasureCount
                                                              END
                        FROM    tbl_Import_Exam_Measure_Data
                        WHERE   Import_ExamID = @Import_examID 

                    END 
		
		
   
    
    
                IF ( ISNULL(@message, '') <> '' ) 
                    BEGIN
    
    -- Here Only possbile status for mandatory failures is  5: Validation Failed
    --set @message = 'Errors In Import exam id ' + CONVERT(varchar(10),@ExamsID)+ CHAR(10) +  @message;
    --set @message = 'Errors In Import exam : ' + @iParentNode + ']'+ CHAR(10) +  @message;
                        SET @messageJSON = @message ;
                        SET @message = 'Errors In Import exam : '
                            + @iParentNode + CHAR(10) + @message ;
    
                        UPDATE  tbl_Import_Exam
                        SET     Error_Codes_Desc = @message ,
                                Error_Codes_JSON = @messageJSON ,
                                Correct_Measure_DataCount = @intCorrectMeasureCount ,
                                Incorrect_Measure_DataCount = @intInCorrectMeasureCount ,
                                [Status] = 5 ,
                                No_of_Errors = @No_of_Errors,
						  Correct_Measure_DataWith_WarningCount=@intCorrect_Measure_DataWith_WarningCount
                        WHERE   Import_examID = @Import_examID
                        PRINT '-------- Exam Report --------' ;
                        PRINT @message ;
                        PRINT '-------- End Report --------' ;
		 
                    END
                ELSE 
                    BEGIN
    -- Here there are 3 possiblities
    -- if @intCorrectMeasureCount  == 0 then 5(validatation failed)
    -- elseif @intCorrectMeasureCount  > 0  and @intInCorrectMeasureCount > 0 then 4 (partiallySuccessful)
    -- else @intCorrectMeasureCount > 0 then 3 successful?
                        UPDATE  tbl_Import_Exam
                        SET     Error_Codes_Desc = NULL ,
                                Error_Codes_JSON = NULL ,
                                Correct_Measure_DataCount = @intCorrectMeasureCount ,
                                Incorrect_Measure_DataCount = @intInCorrectMeasureCount ,
                                [Status] = CASE WHEN (( @intCorrectMeasureCount = 0 ) AND(@intCorrect_Measure_DataWith_WarningCount=0))
                                                     OR ( ( @intCorrectMeasureCount+@intCorrect_Measure_DataWith_WarningCount
                                                            + @intInCorrectMeasureCount
       - @intValidationFailedMeasureCount ) < 1 )
                                                THEN 5
                                                WHEN ( ((@intCorrectMeasureCount > 0) or (@intCorrect_Measure_DataWith_WarningCount>0))
                                                       AND ( @intInCorrectMeasureCount > 0 )
                                                       OR ( @intPartialSuccessMeasureCount > 0 )
                                                     ) THEN 4
                                                WHEN ( ((@intCorrectMeasureCount > 0) or (@intCorrect_Measure_DataWith_WarningCount>0))
                                                       AND ( @intPartialSuccessMeasureCount > 0 )
                                                     ) THEN 4
                                                WHEN ( ((@intCorrectMeasureCount > 0) or (@intCorrect_Measure_DataWith_WarningCount>0))
                                                       AND ( @intPartialSuccessMeasureCount = 0 )
                                                     ) THEN 3
                                           END ,
                                No_of_Errors = @No_of_Errors,
						  						  Correct_Measure_DataWith_WarningCount=@intCorrect_Measure_DataWith_WarningCount

                        WHERE   Import_examID = @Import_examID
                    END
   
    
    
    
                FETCH NEXT FROM Cursor_Imp_Exam 
    INTO  @Import_examID,	
	@Import_Physician_Group_TIN	,	
	@Import_Exam_Unique_ID	,	
	@Import_Exam_DateTime	,	
	@Import_Physician_NPI	,	
	@Import_First_Name	,	
	@Import_Last_Name	,	
	@Import_Patient_ID	,	
	@Import_Patient_Age	,	
	@Import_Patient_Gender ,		
	@Import_Patient_Medicare_Beneficiary ,		
	@Import_Patient_Medicare_Advantage ,		 
	@Import_Num_of_Measures_Included 
            END 
        CLOSE Cursor_Imp_Exam ;
        DEALLOCATE Cursor_Imp_Exam ;
	
    END









