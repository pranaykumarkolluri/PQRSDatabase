



CREATE PROCEDURE [dbo].[SP_Validate_PreProcessed_Data]



AS



BEGIN 

      

       DECLARE @cmsyear int

       DECLARE @isActive bit

       DECLARE @DataID int

       DECLARE @ExamDatTime varchar(50)

	   DECLARE @ErrorMessage varchar(max)

	   DECLARE @Physician_NPI varchar(50)

	   DECLARE @Physician_Group_Tin varchar(10)

	   DECLARE @Patient_ID varchar(500)

	   DECLARE @Patient_Age decimal(18,2)

	   DECLARE @Patient_Gender varchar(50)

	   DECLARE @CPT_Code varchar(50)

	   DECLARE @Denominator_diagnosis_code varchar(50)

	   DECLARE @Numerator_response_value varchar(50)

	   DECLARE @Measure_extension_num varchar(50)

	   DECLARE @Patient_medicare_beneficiary varchar(10)

	   DECLARE @Patient_medicare_advantage varchar(10)

	   DECLARE @Extension_response_value varchar(50)

	   DECLARE @Exam_unique_ID varchar(500)

	   DECLARE @Measure_number varchar(50)



	    DECLARE @ACRinAdminID int = 1;

        DECLARE @PhysicianUserID int = 2;

        DECLARE @FacilityAdminID int = 3;

        DECLARE @FacilityUserID int = 4;

        DECLARE @RegistryAdminID int = 5;

		Declare @PhysicinaTins as Table(NPI Varchar(10),
TIN Varchar(9))
INSERT into @PhysicinaTins
select DISTINCT  NPI,TIN from NRDR..[PHYSICIAN_TIN_VW]

       DECLARE Cur_ProcessData CURSOR FOR 

	           SELECT 

			          DataID,

			          Exam_date_time,

					  Measure_number,

			          [Error_message],

					  Physician_NPI,

					  Physician_group_tin,

					  Patient_ID,

					  Patient_age,

					  Patient_gender,

					  CPT_code,

					  Denominator_diagnosis_code,

					  Numerator_response_value,

					  Measure_extension_num,

					  Patient_medicare_beneficiary,

					  Patient_medicare_advantage,

					  Extension_response_value,

					  Exam_unique_ID

					   

			   FROM tbl_PQRS_FileUpload_PreProcess_Data WITH(NOLOCK)

        OPEN Cur_ProcessData

		FETCH NEXT FROM Cur_ProcessData 

		INTO @DataID,@ExamDatTime,@Measure_number,@ErrorMessage,

		     @Physician_NPI,@Physician_Group_Tin,@Patient_ID,

			 @Patient_Age,@Patient_Gender,@CPT_Code,@Denominator_diagnosis_code,

			 @Numerator_response_value,@Measure_extension_num,

			 @Patient_medicare_beneficiary,@Patient_medicare_advantage,

			 @Extension_response_value,@Exam_unique_ID



		WHILE @@FETCH_STATUS = 0



		BEGIN

		   

		  SET @ErrorMessage = '';

		    

		  IF((ISNULL(LTRIM(RTRIM(@ExamDatTime)),'')<>'') OR (LEN(@ExamDatTime) > 0))

		    

			BEGIN

			  Begin try



			     set @isActive = 0

				 SELECT @isActive = IsActive from tbl_Lookup_Active_Submission_Year 

				 WHERE Submission_Year = (SELECT YEAR(@ExamDatTime) AS [year])

			  

			     set @cmsyear = (SELECT YEAR(@ExamDatTime) AS [year])

			  --select @isActive

			  --select '@cmsyear[' + CONVERT(varchar(10),@cmsyear) + ']'

			  if(@isActive = 1)

			    

			     

			      Begin

				     

					 declare @dt1 datetime



						SELECT @dt1 = CAST(CAST(@ExamDatTime AS DATETIME2) AS DATETIME)



						declare @dt2 datetime 

						select @dt2 = GETDATE()



						 if(@dt1 >= @dt2)



						  BEGIN

						   

						    SET @ErrorMessage = @ErrorMessage + 'Please Enter Correct Exam_Date_Time.'

							UPDATE tbl_PQRS_FileUpload_PreProcess_Data 

							SET [Error_message] = @ErrorMessage

							WHERE DataID = @DataID

						  END



						  else



						     print 'success'				  



			-- <change#2>

			-- Physian NPI starts from here.



	

				   IF((ISNULL(LTRIM(RTRIM(@Physician_NPI)),'')<>''))

				     BEGIN



					    declare @validNPITIN int 

						set @Physician_NPI = LTRIM(rtrim(@Physician_NPI))

						set @Physician_Group_Tin = ltrim(rtrim(@Physician_Group_Tin))



						if(len(@Physician_NPI) > 0)

						  begin

						        -- SELECT 'Physian npi and tin'

							     select @validNPITIN = count(*) from tbl_Users u 

								 join PhysicinaTins p on 

								 u.NPI = p.NPI

								 where u.NPI = @Physician_NPI

								 and p.TIN = @Physician_Group_Tin



								 if(@validNPITIN = 0)

								   begin

								      SET @ErrorMessage = @ErrorMessage + 'Invalid NPI Number [' + @Physician_NPI + '].'

									  UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

									  WHERE DataID = @DataID

								   end

						  end

					    else

						   begin

						      SET @ErrorMessage = @ErrorMessage + 'Physician NPI is required.'

                              UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

					          WHERE DataID = @DataID

						   end

					 END

                  ELSE



				      SET @ErrorMessage = @ErrorMessage + 'Physician NPI is required.'

                      UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

					  WHERE DataID = @DataID

				     

			-- </change#2>



			   

			  	-- <change#3>

				 ---Physian group tin column starts.

				  BEGIN TRY

						  --IF((@Physician_Group_Tin is not null) AND (LEN(@Physician_Group_Tin) > 0 ))

						   IF((ISNULL(LTRIM(RTRIM(@Physician_Group_Tin)),'')<>''))

						 BEGIN

						



							if(LEN(@Physician_Group_Tin) > 0 )

							   begin

							      set @Physician_Group_Tin = cast(@Physician_Group_Tin as varchar(10))

								  select @validNPITIN = count(*) from tbl_Users u 

								  --join tbl_Physician_TIN p on 
								    join @PhysicinaTins p on 

								  u.NPI = p.NPI

								  where u.NPI = @Physician_NPI

								  and p.TIN = @Physician_Group_Tin



								  if(@validNPITIN = 0)

								     begin

									    SET @ErrorMessage = @ErrorMessage + 'Invalid Physician Group Tin [' + @Physician_Group_Tin + '] and Physician NPI [' + @Physician_NPI + '] combination.'

						                UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

						                WHERE DataID = @DataID

									 end



							   end

					        else

							  SET @ErrorMessage = @ErrorMessage + 'Physician Group TIN is required.'

						      UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

						      WHERE DataID = @DataID

						 END

					  ELSE



						  SET @ErrorMessage = @ErrorMessage + 'Physician Group TIN is required.'

						  UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

						  WHERE DataID = @DataID

				  END TRY

				  BEGIN CATCH

				         

						  SET @ErrorMessage = @ErrorMessage + 'Physician Group TIN accepts numbers only.'

						  UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

						  WHERE DataID = @DataID



				  END CATCH





				    --_isValidUseridwithNPIandTIN---

					   select @validNPITIN = count(*) from tbl_Users u 

								  --join tbl_Physician_TIN p on 
								   join @PhysicinaTins p on 
								  u.NPI = p.NPI

								  where u.NPI = @Physician_NPI

								  and p.TIN = @Physician_Group_Tin

						 if(@validNPITIN = 0)

						    begin

							   

							   select '@validNPITIN'



							   declare @uploaderNPI varchar(50)

							   declare @roleid int

							   declare @isAttested bit

							   declare @physianNPIExist int



							   set @uploaderNPI = ''

							   set @roleid = 0

							   set @isAttested = 0

							   set @physianNPIExist = 0



							   select @uploaderNPI = NPI from tbl_Users where UserID in (

							   select  distinct(ph.UserID) from tbl_PQRS_FILE_UPLOAD_HISTORY ph join

							   tbl_PQRS_FileUpload_PreProcess_Data pfd on ph.ID = pfd.FileID )



							   select @roleid = r.Role_ID from tbl_Lookup_Roles r join 

							   tbl_UserRoles t on r.Role_ID = t.RoleID

							   where t.UserID  = (select  distinct(ph.UserID) from tbl_PQRS_FILE_UPLOAD_HISTORY ph join

							   tbl_PQRS_FileUpload_PreProcess_Data pfd on ph.ID = pfd.FileID )

							   

							   if(@roleid = @PhysicianUserID and ltrim(rtrim(@uploaderNPI)) <> ltrim(rtrim(@Physician_NPI)))

							    begin

								  SET @ErrorMessage = @ErrorMessage + 'Physician NPI [ ' + @Physician_NPI + ' ] does not match with the submitter [ ' + @uploaderNPI + ' ].'

							      UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

							      WHERE DataID = @DataID

								end

								else if(@roleid = @FacilityAdminID OR @roleid = @FacilityUserID OR @roleid = @RegistryAdminID)

								  begin

								    

								     select @isAttested = Attested from tbl_users where NPI = ltrim(rtrim(@Physician_NPI))

									 if(@isAttested = 1)

									    begin



										    

										  	SELECT @physianNPIExist = count(*) FROM nrdr..tbl_FacilityManaged_NPI_List

									        where PhysicianNPI in (@Physician_NPI)



											if((@physianNPIExist =0 and (ISNULL(LTRIM(RTRIM(@Physician_NPI)),'')<>'')))

											  begin

											      SET @ErrorMessage = @ErrorMessage + 'Physician NPI: [' + @Physician_NPI + '] is not authorized for this Facility Admin.'

							                      UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

							                      WHERE DataID = @DataID

											  end



										end

									  else 

									    begin

										     SET @ErrorMessage = @ErrorMessage + 'Physician NPI [ ' + @Physician_NPI + ' ] is not yet attested.'

							                 UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

							                 WHERE DataID = @DataID

									    end

							

								  end

							end

					 

				-- </change#3>



				--<change#4>

				 --PatientId column starts from here.

				       

					   BEGIN TRY



					      

						    IF((ISNULL(LTRIM(RTRIM(@Patient_ID)),'')<>''))

						      BEGIN



							     SET @Patient_ID = UPPER(@Patient_ID)

							     --SELECT 'Patientid'

								 if(len(@Patient_ID) > 0)

								     set @Patient_ID = upper(@Patient_ID)

								 if(len(@Patient_ID) = 0)

								     SET @ErrorMessage = @ErrorMessage + 'Patient ID is required.'

							         UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

							         WHERE DataID = @DataID

					   

						      END

						  ELSE



							  SET @ErrorMessage = @ErrorMessage + 'Patient ID Can not be null.'

							  UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

							  WHERE DataID = @DataID

					   END TRY



					   BEGIN CATCH



					   END CATCH    

				--</change#4>



				--<change#5>

				--PatientAge column starts from here.

				   

				     BEGIN TRY

					    

						 --IF((@Patient_Age IS NOT NULL) AND (LEN(@Patient_Age) > 0))

						  IF((ISNULL(LTRIM(RTRIM(@Patient_Age)),'')<>''))

						      BEGIN

							      --select 'patientage entered ' + convert(varchar(20),@Patient_Age)	

							     if(len(@Patient_Age) > 0)

								    begin

					                    IF((ISNULL(LTRIM(RTRIM(@Measure_number)),'')<>'') OR (len(@Measure_number) > 0))

										   BEGIN

										     

											 declare @nbYear decimal(18,2)

											 declare @m int

											 declare @yd decimal(18,2)

						 					 declare @ageRestrictionFrom decimal(18,2)

	                                         declare @ageRestrictionTo decimal(18,2)

											 set @ageRestrictionFrom = 0

											 set @ageRestrictionTo = 0

											if(LEN(@Measure_number) > 0)

											   BEGIN

												   

												   set @ageRestrictionFrom = 0

												   set @ageRestrictionTo = 0

															    

													select @ageRestrictionFrom= Age_Restriction_From,

													       @ageRestrictionTo = Age_Restriction_To

													       from tbl_Lookup_Measure 

													        where Measure_num = @Measure_number 

															and CMSYear = ltrim(rtrim(@cmsyear))

							                       

												     select @ageRestrictionFrom, @ageRestrictionTo

													  

													if ((@Patient_Age = null) or (@Patient_Age > @ageRestrictionTo))  

                                                           begin

														       SET @ErrorMessage = @ErrorMessage + 'This exam does not meet the age requirement.'	

													           UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

													           WHERE DataID = @DataID

														   end

                                                   else if (@Patient_Age >= @ageRestrictionFrom and @Patient_Age <= @ageRestrictionTo)

							                            begin

                                                        select 'round'

														end

												   else

												     

													   begin

													    select 'age else'

													    --select @ageRestrictionFrom, @ageRestrictionTo	

													    select @nbYear = round(@Patient_Age,2,1)

													

													    set @yd = (select round(@Patient_Age,2,1) - (select convert(int,@Patient_Age)))

													

													    select @m = ceiling(@yd * 12) 

														select @m

													    SET @ErrorMessage = @ErrorMessage + 'You have entered '+ convert(varchar(50),@nbYear) + 'years and' + convert(varchar(50), @m) + 'months.Age must be between ' + convert(varchar(50), @ageRestrictionFrom) + ' and ' +  convert(varchar(50), 
@ageRestrictionTo) + '. ' 

													    update tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

													    WHERE DataID = @DataID

													  end

														

													  

									

									 

												END

												ELSE

												

													 SET @ErrorMessage = @ErrorMessage + 'MeasureNumber can not be null.'	

													 UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

													 WHERE DataID = @DataID

											

										         

										END

										ELSE

						   

										 SET @ErrorMessage = @ErrorMessage + 'MeasureNumber can not be null.'

										  UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

										  WHERE DataID = @DataID	

									end

								 else

								    SET @ErrorMessage = @ErrorMessage + 'Patient Age is required.'

							        UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

							        WHERE DataID = @DataID

							     

					   

						      END

						  ELSE



							  SET @ErrorMessage = @ErrorMessage + 'Patient Age is required.'

							  UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

							  WHERE DataID = @DataID

					 END TRY

					 BEGIN CATCH

					     

						 SET @ErrorMessage = @ErrorMessage + 'Age should be in Numbers Only..'

							  UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

							  WHERE DataID = @DataID



					 END CATCH



				--</change#5>



				--<change#6>

				--PatientGender column starts from here.

				     BEGIN TRY

					    

						-- IF((@Patient_Gender IS NOT NULL) AND (LEN(@Patient_Gender) > 0))

						  IF((ISNULL(LTRIM(RTRIM(@Patient_Gender)),'')<>''))

						      BEGIN



							      SELECT 'Patient_Gender'

						    

								 SET @Patient_Gender = UPPER(@Patient_Gender)

							     if(len(@Patient_Gender) > 0)

								  begin

									 IF ((@Patient_Gender = 'M') OR (@Patient_Gender = 'F') OR (@Patient_Gender = 'U') OR (@Patient_Gender = 'O'))

										BEGIN



										 SELECT 'M'

									   

										END



									  ELSE

								     

										 BEGIN

									   

										   SET @ErrorMessage = @ErrorMessage + 'Invalid Gender.'

										 END

									END

									else

									   SET @ErrorMessage = @ErrorMessage + 'Gender Cannot be Empty or Null.'

							           UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

							           WHERE DataID = @DataID

					   

						      END

						  ELSE



							  SET @ErrorMessage = @ErrorMessage + 'Gender Cannot be Empty or Null.'

							  UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

							  WHERE DataID = @DataID

					 END TRY

					 BEGIN CATCH

					     

						

					 END CATCH



				--</change#6>



				--<change#7>

				--CPTCode column starts from here.

				     BEGIN TRY

					    

						 --IF((@CPT_Code IS NOT NULL) AND (LEN(@CPT_Code) > 0))

						 IF((ISNULL(LTRIM(RTRIM(@CPT_Code)),'')<>''))

						      BEGIN

							     

					              declare @cptcodeCount int

							    

							      SELECT 'CPT_Code'

								 

								  SET  @CPT_Code = UPPER(@CPT_Code)

							      if(len(@CPT_Code) > 0)

								     begin

									    select @cptcodeCount = count(*) where @CPT_Code in (select Proc_code from tbl_lookup_Denominator_Proc_Code

										where Measure_num = @Measure_number and CMSYear = @cmsyear)



										if(@cptcodeCount > 0)

										   select @cptcodeCount

										else

										   

										   

										   SET @ErrorMessage = @ErrorMessage + 'Invalid CPT Code.'

										   UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

										   WHERE DataID = @DataID

										   

								       end

                                    else

									   

										   SET @ErrorMessage = @ErrorMessage + 'CPT Code is required.'

										   UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

										   WHERE DataID = @DataID



						      END

						  ELSE



							  SET @ErrorMessage = @ErrorMessage + 'CPT Code is required.'

							  UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

							  WHERE DataID = @DataID

					 END TRY

					 BEGIN CATCH

					     

						

					 END CATCH

				--</change#7>



				--<change#8>

				-- Denominator_diagnosis_code column starts from here.

					BEGIN TRY

					    

						

						   if((select count(*) from tbl_Lookup_Denominator_Diag_Code

							  where Measure_num = @Measure_number 

							  and CMSYear = @cmsyear) > 0)

						      BEGIN

							      

								  declare @Denominator_diagnosis_codeCount int

							      SELECT '@Denominator_diagnosis_codeCount'

								  if(len(@Denominator_diagnosis_code) > 0)

								    begin

									   

									    select @Denominator_diagnosis_codeCount = count(*) where @Denominator_diagnosis_code in (select  Code from tbl_Lookup_Denominator_Diag_Code

										where Measure_num = @Measure_number and CMSYear = @cmsyear)

										if(@Denominator_diagnosis_codeCount > 0)

										   select @Denominator_diagnosis_codeCount

										else

										   

										   

										   SET @ErrorMessage = @ErrorMessage + 'Invalid Denominator Diagnosis Code.'

										   UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

										   WHERE DataID = @DataID



									end

							    

						      END

						  else if((ISNULL(LTRIM(RTRIM(@Denominator_diagnosis_code)),'')<>''))

						    

							  begin

							     if(len(@Denominator_diagnosis_code) > 0)

								  begin

								     SET @ErrorMessage = @ErrorMessage + 'Denominator Diagnosis Code is not available for this measure number.'

							         UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

							         WHERE DataID = @DataID

								  end

							     

							  end



							 

					 END TRY

					 BEGIN CATCH

					     

						

					 END CATCH

				    

				--</change#8>



				--<change#9>

				--@Numerator_response_value

				     BEGIN TRY

					    

						 --IF((@Numerator_response_value IS NOT NULL) AND (LEN(@Numerator_response_value) > 0))

						 IF((ISNULL(LTRIM(RTRIM(@Numerator_response_value)),'')<>''))

						      BEGIN



							      declare @Numerator_response_valueCount int

								  declare @Numerator_response_ValueIntegerCount int

							      SELECT 'Numerator_response_value'

								  if(len(@Numerator_response_value) > 0)

								    begin

									    set @Numerator_response_value = upper(@Numerator_response_value)

									    select @Numerator_response_valueCount = count(*) where @Numerator_response_value

										in (select Numerator_Code from tbl_lookup_Numerator_Code

										where Measure_num = @Measure_number and CMSYear = @cmsyear)



										if(@Numerator_response_valueCount > 0)

										   select @Numerator_response_valueCount

										else

										   SET @ErrorMessage = @ErrorMessage + 'Not a valid Numerator Response Value.'

							               UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

							               WHERE DataID = @DataID

									   

									    --numerator response index vlaue

										 select @Numerator_response_ValueIntegerCount = Numerator_response_Value

										 from tbl_lookup_Numerator_Code where Measure_Num = @Measure_number

										 and CMSYear = @cmsyear and Numerator_Code = @Numerator_response_value



										  if(@Numerator_response_ValueIntegerCount > 0)

										    select '@Numerator_response_ValueIntegerCount'

										  else

										    SET @ErrorMessage = @ErrorMessage + 'No mapping found between Measure number: [' + @Measure_number + ' ] and numerator response code: [' + @Numerator_response_value + ' ].' 

							                UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

							                WHERE DataID = @DataID

									end

								  else

								     SET @ErrorMessage = @ErrorMessage + 'Numerator Response Value is required.'

							         UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

							         WHERE DataID = @DataID

							    

						      END

						  ELSE



							  SET @ErrorMessage = @ErrorMessage + 'Numerator Response Value is required.'

							  UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

							  WHERE DataID = @DataID

					 END TRY

					 BEGIN CATCH

					     

						

					 END CATCH

				 

				--</change#9>



				--<change10>

				--@Measure_extension_num starts from here.

				     BEGIN TRY

					    

						 --IF((@Measure_extension_num IS NOT NULL) AND (LEN(@Measure_extension_num) > 0))

						  if((select count(*) from tbl_Lookup_Measure_Extension

							  where Measure_num = @Measure_number 

							  and CMSYear = @cmsyear) > 0)

						      BEGIN

							      

								  declare @measureExtensionNumberCount int

							     

								  set @Measure_extension_num = ltrim(rtrim(@Measure_extension_num))

								  if(len(@Measure_extension_num) > 0)

								     begin

									     select @measureExtensionNumberCount = count(*) from tbl_Lookup_Measure_Extension 

										 where @Measure_extension_num in 

										 (select Other_Question_Num from tbl_Lookup_Measure_Extension

										 where Measure_num = @Measure_number and CMSYear = @cmsyear)



										 -- SELECT 'if Measure_extension_num'

										 -- select @measureExtensionNumberCount



										 if(@measureExtensionNumberCount > 0)

										    select '@measureExtensionNumberCount'

										  else

										    SET @ErrorMessage = @ErrorMessage + 'Invalid Measure Extension Number.'

						                    UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

						                    WHERE DataID = @DataID

									 end

								  					    

						      END



							 ELSE IF((ISNULL(LTRIM(RTRIM(@Measure_extension_num)),'')<>''))

							   begin

							       -- SELECT 'else Measure_extension_num'

							      set @Measure_extension_num = ltrim(rtrim(@Measure_extension_num))

								  if(len(@Measure_extension_num) > 0)

								    begin

									      SET @ErrorMessage = @ErrorMessage + 'There is no Measure Extension Number available for this Measure Number.'

						                  UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

						                  WHERE DataID = @DataID

									end

							   end

							  

							    

						 

					 END TRY

					 BEGIN CATCH

					     

						   SET @ErrorMessage = @ErrorMessage + 'Measure Extension Number should be in numbers only.'

						   UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

						   WHERE DataID = @DataID

						

					 END CATCH

				--</change10>



				--<change11>

				--@Patient_medicare_beneficiary AND  @Patient_medicare_advantage column starts from here.

				     BEGIN TRY

					    

						 IF((len(@Patient_medicare_beneficiary) = 0) OR (LEN(@Patient_medicare_beneficiary) > 0))

						      BEGIN



							      SELECT 'Patient_medicare_beneficiary'

								     set @Patient_medicare_beneficiary = ltrim(rtrim(@Patient_medicare_beneficiary))

								  		  if(LEN(@Patient_medicare_beneficiary) > 0)

										    begin

											    SET @Patient_medicare_beneficiary = UPPER(@Patient_medicare_beneficiary)	

											end

								 

								   IF ((@Patient_medicare_beneficiary = 'Y') OR (@Patient_medicare_beneficiary = 'N') OR (@Patient_medicare_beneficiary = 'NA') OR (ISNULL(LTRIM(RTRIM(@ExamDatTime)),'') = ''))

								      BEGIN

									      

																		  

										  IF((LEN(@Patient_medicare_advantage) > 0 OR (LEN(@Patient_medicare_advantage) = 0)))



												 Begin



												   SET @Patient_medicare_advantage = LTRIM(RTRIM(@Patient_medicare_advantage))

												   if(len(@Patient_medicare_advantage) > 0)

												     begin

													     SET @Patient_medicare_advantage = UPPER(@Patient_medicare_advantage)

													 end

												 end

										  IF((ISNULL( LTRIM(RTRIM(@Patient_medicare_advantage)),'')='') OR

											  (@Patient_medicare_advantage = 'Y') OR (@Patient_medicare_advantage = 'N') OR (@Patient_medicare_advantage = 'NA')

												)

												  Begin

												      select 'Patient Medicare Advantage'

												  end

										   ELSE



											     Begin

												   SET @ErrorMessage = @ErrorMessage + 'Invalid Patient Medicare Advantage.'

												   UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

												   WHERE DataID = @DataID

												 end

										  



									  END

								ELSE 



								    BEGIN

									    SET @ErrorMessage = @ErrorMessage + 'Invalid Patient Medicare Beneficiary.'

										UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

										WHERE DataID = @DataID   

									END

								  		    

						      END

						 

					 END TRY

					 BEGIN CATCH

					     

						   SET @ErrorMessage = @ErrorMessage + 'Patient Medicare Beneficiary Cannot be null.'

						   UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

						   WHERE DataID = @DataID

						

					 END CATCH

				 

				--</change11>

				--<change12>

				--@Extension_response_value column starts from here.

				  BEGIN TRY

				    

					if((select count(mev.Measure_Ext_Response_Code_Value) from tbl_Lookup_Measure_Extension me

                     join tbl_Lookup_Measure_Extension_values mev on me.Measure_Ext_Id = mev.Measure_Ext_Id

                     where me.Measure_num = @Measure_number and me.CMSYear = @cmsyear) > 0 )

					    

					            IF((ISNULL(LTRIM(RTRIM(@Extension_response_value)),'')<>''))

								   BEGIN

								  

									  set @Extension_response_value = ltrim(rtrim(@Extension_response_value))

									

									  if(len(@Extension_response_value) > 0)

									    begin

										    declare @extensionCodeValues int

											declare @Values int

											declare @ext_Response_Code_Val varchar(50)

											declare @itemvalue int 





									        declare  cur_extension cursor

											for select Item from SplitString(@Extension_response_value,',')

											

											open cur_extension

											

											Fetch next from cur_extension into @extensionCodeValues

											

											while @@FETCH_STATUS = 0

											  begin



												 select @Values = count(*)  where @extensionCodeValues in

												 (

												 select mev.Measure_Ext_Response_Code_Value from tbl_Lookup_Measure_Extension me

												 join tbl_Lookup_Measure_Extension_values mev on me.Measure_Ext_Id = mev.Measure_Ext_Id

												 where me.Measure_num = @Measure_number and me.CMSYear = @cmsyear)



												



											     if(@Values > 0)

												   begin

												      select '@ext_Response_Code_Val'

												      --set @ext_Response_Code_Val = cast(@extensionCodeValues as varchar(10)) + ',' + cast(@extensionCodeValues as varchar(10)) 

											         --select @ext_Response_Code_Val

												   end

												 else

												   begin

												    

												    SET @ErrorMessage = @ErrorMessage + 'Invalid Extension Response Code (' + @Extension_response_value + ' ) submitted for measurenumber ( '+@Measure_number + ' ) in the year (' + convert(varchar(10),@cmsyear) + ' )'

								                    UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

								                    WHERE DataID = @DataID



												   end



											  fetch next from cur_extension into @extensionCodeValues

											  end

											  close cur_extension

											  deallocate cur_extension







										end

								  					    

								   END

				      else IF((ISNULL(LTRIM(RTRIM(@Extension_response_value)),'')<>''))

					     begin

						      SELECT 'Extension_response_value else'

						     set @Extension_response_value = ltrim(rtrim(@Extension_response_value))

							 if(len(@Extension_response_value) > 0)

							    begin

								   SET @ErrorMessage = @ErrorMessage + 'No Extension Response Value for this Measure Number.'

								   UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

								   WHERE DataID = @DataID

								end

						 end



				  END TRY

				  BEGIN CATCH

				    

					SET @ErrorMessage = @ErrorMessage + 'Extension Response Value must be a Number.'

				    UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

					WHERE DataID = @DataID



				  END CATCH

				 

				--</change12>



				--<change13>

				--@Exam_unique_ID Column starts from here.

				     IF((ISNULL(LTRIM(RTRIM(@Exam_unique_ID)),'')<>''))

					    BEGIN

						  

						  

						   set @Exam_unique_ID = ltrim(rtrim(@Exam_unique_ID))

						   IF(LEN(@Exam_unique_ID) = 0)

						     begin

							   SET @ErrorMessage = @ErrorMessage + 'Exam_Unique_ID cannot be null.'

							   UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

					           WHERE DataID = @DataID

							 end

						     

						END

					 ELSE IF(ISNULL(LTRIM(RTRIM(@Exam_unique_ID)),'') = '')

					

					    BEGIN

						  

						    SET @ErrorMessage = @ErrorMessage + 'Exam_Unique_ID cannot be null.'

						    UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

					        WHERE DataID = @DataID

						END

				--</change13>



				--<change14>

				--@Measure_number logic starts from here.

				

				     IF((ISNULL(LTRIM(RTRIM(@Measure_number)),'')<>'') OR (len(@Measure_number) > 0))

					    BEGIN

						 	Declare @measureid int		

							set @measureid = 0	   

						    if(LEN(@Measure_number) > 0)

							   BEGIN

								  --SET @Measure_number = UPPER(@Measure_number)

								    

						            select @measureid= Measure_ID 

                                    from tbl_Lookup_Measure 

                                     where Measure_num = @Measure_number and CMSYear = ltrim(rtrim(@cmsyear))

							          

									  select @measureid

								    IF(@measureid > 0)

									  begin

									 	  -- select @measureid

									      select 'measurnumber' + @Measure_number

										   

									  end

									else

									

									    

									     SET @ErrorMessage = @ErrorMessage +'[ ' +@Measure_number  + ' ] is an Invalid MeasureNumber for the year' + '[ '+ Convert(varchar(10),@cmsyear)+' ]' 

										 UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

										 WHERE DataID = @DataID	

									     

									

									 

							   END

						       ELSE

							     begin

									 SET @ErrorMessage = @ErrorMessage + 'MeasureNumber can not be null.'	

									 UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

									 WHERE DataID = @DataID

									 --select '@ErrorMessage' + @ErrorMessage

								 end

						END

				ELSE

						   

				 SET @ErrorMessage = @ErrorMessage + 'MeasureNumber can not be null.'

				  UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

				  WHERE DataID = @DataID	

				   --select '@ErrorMessage1'+ @ErrorMessage		

					

				

				--</change14>

			 end

          		else

				   

				    begin

					  SET @ErrorMessage = @ErrorMessage + 'Exam Date is not active for CMS submission.'

					  UPDATE tbl_PQRS_FileUpload_PreProcess_Data 

					  SET [Error_message] = @ErrorMessage

					  WHERE DataID = @DataID

					end



			    end try

				begin catch

				     SET @ErrorMessage = @ErrorMessage + 'Invalid Exam Date Time. Exam_Date_Time Should be in MM/dd/yyyy HH:mm:ss Format..'

					  UPDATE tbl_PQRS_FileUpload_PreProcess_Data 

					  SET [Error_message] = @ErrorMessage

					  WHERE DataID = @DataID

				end catch

			END



			ELSE



				 BEGIN



					  SET @ErrorMessage = @ErrorMessage + 'Exam Date is required.'

					  UPDATE tbl_PQRS_FileUpload_PreProcess_Data SET [Error_message] = @ErrorMessage

					  WHERE DataID = @DataID

			  

				 END

					

          FETCH NEXT FROM Cur_ProcessData 

		  INTO @DataID,@ExamDatTime,@Measure_number,@ErrorMessage,@Physician_NPI,

		       @Physician_Group_Tin,@Patient_ID,@Patient_Age,@Patient_Gender,@CPT_Code,

			   @Denominator_diagnosis_code,@Numerator_response_value,@Measure_extension_num,

			   @Patient_medicare_beneficiary,@Patient_medicare_advantage,

			   @Extension_response_value,@Exam_unique_ID

		END

		CLOSE Cur_ProcessData

		DEALLOCATE Cur_ProcessData

       

END



