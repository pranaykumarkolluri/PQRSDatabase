

CREATE PROCEDURE [dbo].[spGetRecordsEnteredPageGridDetails]
    -- Add the parameters for the stored procedure here
  @FacilityUserName varchar(50),
  @StartDate datetime =  '',
    @EndDate datetime='',
    @FacilityUserId as int = 0,
  --	@SearchStatus varchar(100)='All',
	@PageNo int=1,
	@PageLimit int=20,
	@ISASC bit=0,
	@SortColumn varchar(50)='Exam_Id',
	@SortDirection varchar(5)='DESC',
	@ExamTin varchar(9),
	@ExamNpi varchar(10),
	@MeasureId int=0,
	@IsFacilityRole bit,
	@CMSYear int,
	@Searchtext varchar(256)='',
	@PatientAge decimal(18,2)=0,
	@CPTCode varchar(100) ='',
	@PatientSex varchar(50) = ''
	--Change#3 
AS
BEGIN              
   

	   

	declare @skiprows int=0;
declare @FacilityNpis table(Npi varchar(10));
Set @StartDate = ISNULL(@StartDate,'');
Set @EndDate = ISNULL(@EndDate,'');
Set @ExamTin = ISNULL(@ExamTin,'');
set @skiprows = CASE WHEN  @PageNo >1 THEN (@PageNo-1) * @PageLimit ELSE 0 END 

declare @FacilityTin varchar(9)='';
declare @Tintbl table (TIN varchar(9))

IF(@Searchtext='')
BEGIN
IF(@IsFacilityRole=1)
BEGIN

  insert into @Tintbl
  EXEC sp_getFacilityTIN  @FacilityUserName


  
;WITH examdata as (
SELECT 
 e.Exam_Id,md.Measure_ID,

						 count(*) over()  as FilesCount
				
				 FROM tbl_Exam e
				        INNER JOIN  
						            @Tintbl tn on e.Exam_TIN=tn.TIN
						INNER JOIN
									 tbl_Lookup_Data_Source d on e.DataSource_Id=d.DataSource_Id					
						INNER JOIN 
									 tbl_Exam_Measure_Data Md on e.Exam_Id=Md.Exam_Id
									                and md.Measure_ID= Case When @MeasureId =0 then md.Measure_ID else @MeasureId end
												    and e.CMS_Submission_Year=@CMSYear
													-- and e.Exam_TIN in (select TIN  from @Tintbl)
						                            and e.Physician_NPI=@ExamNpi												   												
													and e.Exam_Date >= Case When @StartDate='' then e.Exam_Date else @StartDate end
													and e.Exam_Date <= Case When @EndDate='' then e.Exam_Date else  @EndDate end
													and e.Patient_Age = Case When @PatientAge = 0 then e.Patient_Age else @PatientAge end
													and e.Patient_Gender = Case When @PatientSex = '' then e.Patient_Gender else @PatientSex end
													and Md.Denominator_proc_code = Case When @CPTCode='' then Md.Denominator_proc_code end												
						INNER JOIN  tbl_Lookup_Measure m on md.Measure_ID=M.Measure_ID
					
 ORDER BY  
case
        when @SortDirection <> 'ASC' then cast(0 as INT)
        when @sortColumn = 'ExamID' then E.Exam_Id        
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(0 as INT)
        when @sortColumn = 'ExamID' then E.Exam_Id          
        end DESC
		,

		case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'TIN' then E.Exam_TIN         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'TIN' then E.Exam_TIN           
        end DESC
		,

			case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'PatientID' then E.Patient_ID         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'PatientID' then E.Patient_ID           
        end DESC
		,

			case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'MeasureNum' then M.DisplayOrder         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as int)
        when @sortColumn = 'MeasureNum' then M.DisplayOrder          
        end DESC

		,

			case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'PatientGender' then E.Patient_Gender         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'PatientGender' then E.Patient_Gender           
        end DESC


		
		,

		case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'UniqueExamID' then E.Exam_Unique_ID         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'UniqueExamID' then E.Exam_Unique_ID           
        end DESC

		,

		case
        when @SortDirection <> 'ASC' then cast(null as datetime)
        when @sortColumn = 'ExamDate' then E.Exam_Date         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as datetime)
        when @sortColumn = 'ExamDate' then E.Exam_Date           
        end DESC

	


	
			,

		case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'CPTCode' then Md.Denominator_proc_code          
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'CPTCode' then  Md.Denominator_proc_code           
        end DESC

		,
		case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'Created_Date' then E.Created_Date        
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'Created_Date' then   E.Created_Date          
        end DESC


 OFFSET @skiprows  ROWS
 FETCH NEXT @PageLimit ROWS ONLY
 )
 SELECT 


                                      e.Physician_NPI,
									  e.Exam_TIN,
									  e.Exam_Id,
									  md.Measure_ID,
									  ms.Status_Desc,
									  m.Measure_num,
								
									
									
						
									  Case When e.Patient_Gender ='M' then 'Male'
										   when e.Patient_Gender ='F' then 'Female'
										   when e.Patient_Gender='O' then 'Other'
										   when e.Patient_Gender='U' then 'Unknown'
										   end as Patient_Gender,
									
									
									
									  md.Denominator_proc_code,
									  md.Numerator_Code,
									  e.Created_Date,
									  e.Exam_Date,
									  e.Exam_Unique_ID,
									  e.Patient_ID,
									  e.Patient_Age,
									  e.IsEncrypt,
									
									  d.DataSource,
									  e.CMS_Submission_Year,
									 
						              EX.FilesCount
		
		
		
		
				 FROM
				                    examdata ex
						INNER JOIN
				                    tbl_Exam e  on e.Exam_Id=EX.Exam_Id 
				   
						INNER JOIN
									 tbl_Lookup_Data_Source d on e.DataSource_Id=d.DataSource_Id
					

						INNER JOIN 
									 tbl_Exam_Measure_Data Md on Md.Exam_Id=ex.Exam_Id and Md.Measure_ID=ex.Measure_ID
					
						INNER JOIN  tbl_Lookup_Measure m on M.Measure_ID=ex.Measure_ID
						INNER JOIN  tbl_Lookup_Measure_Status Ms on md.Status=Ms.Status_ID 
						LEFT JOIN
									tbl_lookup_Numerator_Code N on N.Measure_ID=ex.Measure_ID
													and N.Numerator_response_Value =Md.Numerator_response_value
													and isnull(n.Criteria,'NA') = case when md.Criteria is null or md.Criteria ='' then 'NA' else md.Criteria end


END
ELSE
BEGIN

;WITH examdata as (
SELECT 
 e.Exam_Id,md.Measure_ID,

						 count(*) over()  as FilesCount
				
				 FROM tbl_Exam e
						INNER JOIN
									 tbl_Lookup_Data_Source d on e.DataSource_Id=d.DataSource_Id					
						INNER JOIN 
									 tbl_Exam_Measure_Data Md on e.Exam_Id=Md.Exam_Id
									                and md.Measure_ID= Case When @MeasureId =0 then md.Measure_ID else @MeasureId end
												    and e.CMS_Submission_Year=@CMSYear
													 and e.Exam_TIN= Case  
																		  when @ExamTin !='' then @ExamTin
																		  else e.Exam_TIN
																		  end
						                            and e.Physician_NPI=@ExamNpi												   												
													and e.Exam_Date >= Case When @StartDate='' then e.Exam_Date else @StartDate end
													and e.Exam_Date <= Case When @EndDate='' then e.Exam_Date else  @EndDate end
													and e.Patient_Age = Case When @PatientAge = 0 then e.Patient_Age else @PatientAge end
													and e.Patient_Gender = Case When @PatientSex = '' then e.Patient_Gender else @PatientSex end
													and Md.Denominator_proc_code = Case When @CPTCode='' then Md.Denominator_proc_code else @CPTCode end											
						INNER JOIN  tbl_Lookup_Measure m on md.Measure_ID=M.Measure_ID
					
 ORDER BY  
case
        when @SortDirection <> 'ASC' then cast(0 as INT)
        when @sortColumn = 'ExamID' then E.Exam_Id        
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(0 as INT)
        when @sortColumn = 'ExamID' then E.Exam_Id          
        end DESC
		,

		case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'TIN' then E.Exam_TIN         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'TIN' then E.Exam_TIN           
        end DESC
		,

			case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'PatientID' then E.Patient_ID         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'PatientID' then E.Patient_ID           
        end DESC
		,

			case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'MeasureNum' then M.DisplayOrder         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as int)
        when @sortColumn = 'MeasureNum' then M.DisplayOrder          
        end DESC

		,

			case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'PatientGender' then E.Patient_Gender         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'PatientGender' then E.Patient_Gender           
        end DESC


		
		,

		case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'UniqueExamID' then E.Exam_Unique_ID         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'UniqueExamID' then E.Exam_Unique_ID           
        end DESC

		,

		case
        when @SortDirection <> 'ASC' then cast(null as datetime)
        when @sortColumn = 'ExamDate' then E.Exam_Date         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as datetime)
        when @sortColumn = 'ExamDate' then E.Exam_Date           
        end DESC

	


	
			,

		case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'CPTCode' then Md.Denominator_proc_code          
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'CPTCode' then  Md.Denominator_proc_code           
        end DESC

		,
		case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'Created_Date' then E.Created_Date        
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'Created_Date' then   E.Created_Date          
        end DESC


 OFFSET @skiprows  ROWS
 FETCH NEXT @PageLimit ROWS ONLY
 )
 SELECT distinct


                                      e.Physician_NPI,
									  e.Exam_TIN,
									  e.Exam_Id,
									  md.Measure_ID,
									  ms.Status_Desc,
									  m.Measure_num,
								
									
									
						
									  Case When e.Patient_Gender ='M' then 'Male'
										   when e.Patient_Gender ='F' then 'Female'
										   when e.Patient_Gender='O' then 'Other'
										   when e.Patient_Gender='U' then 'Unknown'
										   end as Patient_Gender,
									
									
									
									  md.Denominator_proc_code,
									  md.Numerator_Code,
									  e.Created_Date,
									  e.Exam_Date,
									  e.Exam_Unique_ID,
									  e.Patient_ID,
									  e.Patient_Age,
									  e.IsEncrypt,
									
									  d.DataSource,
									  e.CMS_Submission_Year,
									 
						              EX.FilesCount
		
		
		
		
				 FROM
				                    examdata ex
						INNER JOIN
				                    tbl_Exam e  on e.Exam_Id=EX.Exam_Id 
				   
						INNER JOIN
									 tbl_Lookup_Data_Source d on e.DataSource_Id=d.DataSource_Id
					

						INNER JOIN 
									 tbl_Exam_Measure_Data Md on Md.Exam_Id=ex.Exam_Id and Md.Measure_ID=ex.Measure_ID
					
						INNER JOIN  tbl_Lookup_Measure m on M.Measure_ID=ex.Measure_ID
						INNER JOIN  tbl_Lookup_Measure_Status Ms on md.Status=Ms.Status_ID 
						LEFT JOIN
									tbl_lookup_Numerator_Code N on N.Measure_ID=ex.Measure_ID
													and N.Numerator_response_Value =Md.Numerator_response_value
													and isnull(n.Criteria,'NA') = case when md.Criteria is null or md.Criteria ='' then 'NA' else md.Criteria end
END

END


ELSE
BEGIN

IF(@IsFacilityRole=1)
BEGIN

  insert into @Tintbl
  EXEC sp_getFacilityTIN  @FacilityUserName


  
;WITH examdata as (
SELECT 
 e.Exam_Id,md.Measure_ID,

						 count(*) over()  as FilesCount
				
				 FROM tbl_Exam e
				        INNER JOIN  
						            @Tintbl tn on e.Exam_TIN=tn.TIN
						INNER JOIN
									 tbl_Lookup_Data_Source d on e.DataSource_Id=d.DataSource_Id					
						INNER JOIN 
									 tbl_Exam_Measure_Data Md on e.Exam_Id=Md.Exam_Id
									                and md.Measure_ID= Case When @MeasureId =0 then md.Measure_ID else @MeasureId end
												    and e.CMS_Submission_Year=@CMSYear
													-- and e.Exam_TIN in (select TIN  from @Tintbl)
						                            and e.Physician_NPI=@ExamNpi												   												
													and e.Exam_Date >= Case When @StartDate='' then e.Exam_Date else @StartDate end
													and e.Exam_Date <= Case When @EndDate='' then e.Exam_Date else  @EndDate end
													and e.Patient_Age = Case When @PatientAge = 0 then e.Patient_Age else @PatientAge end
													and e.Patient_Gender = Case When @PatientSex = '' then e.Patient_Gender else @PatientSex end
													and Md.Denominator_proc_code = Case When @CPTCode='' then Md.Denominator_proc_code else @CPTCode end											
						INNER JOIN  tbl_Lookup_Measure m on (md.Measure_ID=M.Measure_ID)
						                                  
						
					where 
														(
														 E.Exam_TIN LIKE '%'+@Searchtext+'%'
														 OR
														 E.Exam_Unique_ID  LIKE '%'+@Searchtext+'%'
														 OR 
														 --E.Created_Date LIKE @Searchtext+'%' 
														 --OR 
														 --E.Exam_Date LIKE  @Searchtext+'%'
														 --OR 
														 MD.Numerator_Code LIKE  '%'+@Searchtext+'%'
														 OR 
														 MD.Denominator_proc_code LIKE '%'+@Searchtext+'%'
														 OR 
														 M.Measure_num LIKE '%'+@Searchtext+'%'
														)
					
 ORDER BY  
case
        when @SortDirection <> 'ASC' then cast(0 as INT)
        when @sortColumn = 'ExamID' then E.Exam_Id        
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(0 as INT)
        when @sortColumn = 'ExamID' then E.Exam_Id          
        end DESC
		,

		case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'TIN' then E.Exam_TIN         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'TIN' then E.Exam_TIN           
        end DESC
		,

			case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'PatientID' then E.Patient_ID         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'PatientID' then E.Patient_ID           
        end DESC
		,

			case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'MeasureNum' then M.DisplayOrder         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as int)
        when @sortColumn = 'MeasureNum' then M.DisplayOrder          
        end DESC

		,

			case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'PatientGender' then E.Patient_Gender         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'PatientGender' then E.Patient_Gender           
        end DESC


		
		,

		case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'UniqueExamID' then E.Exam_Unique_ID         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'UniqueExamID' then E.Exam_Unique_ID           
        end DESC

		,

		case
        when @SortDirection <> 'ASC' then cast(null as datetime)
        when @sortColumn = 'ExamDate' then E.Exam_Date         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as datetime)
        when @sortColumn = 'ExamDate' then E.Exam_Date           
        end DESC

	


	
			,

		case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'CPTCode' then Md.Denominator_proc_code          
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'CPTCode' then  Md.Denominator_proc_code           
        end DESC

		,
		case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'Created_Date' then E.Created_Date        
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'Created_Date' then   E.Created_Date          
        end DESC


 OFFSET @skiprows  ROWS
 FETCH NEXT @PageLimit ROWS ONLY
 )
 SELECT 


                                      e.Physician_NPI,
									  e.Exam_TIN,
									  e.Exam_Id,
									  md.Measure_ID,
									  ms.Status_Desc,
									  m.Measure_num,
								
									
									
						
									  Case When e.Patient_Gender ='M' then 'Male'
										   when e.Patient_Gender ='F' then 'Female'
										   when e.Patient_Gender='O' then 'Other'
										   when e.Patient_Gender='U' then 'Unknown'
										   end as Patient_Gender,
									
									
									
									  md.Denominator_proc_code,
									  md.Numerator_Code,
									  e.Created_Date,
									  e.Exam_Date,
									  e.Exam_Unique_ID,
									  e.Patient_ID,
									  e.Patient_Age,
									  e.IsEncrypt,
									
									  d.DataSource,
									  e.CMS_Submission_Year,
									 
						              EX.FilesCount
		
		
		
		
				 FROM
				                    examdata ex
						INNER JOIN
				                    tbl_Exam e  on e.Exam_Id=EX.Exam_Id 
				   
						INNER JOIN
									 tbl_Lookup_Data_Source d on e.DataSource_Id=d.DataSource_Id
					

						INNER JOIN 
									 tbl_Exam_Measure_Data Md on Md.Exam_Id=ex.Exam_Id and Md.Measure_ID=ex.Measure_ID
					
						INNER JOIN  tbl_Lookup_Measure m on M.Measure_ID=ex.Measure_ID
						INNER JOIN  tbl_Lookup_Measure_Status Ms on md.Status=Ms.Status_ID 
						LEFT JOIN
									tbl_lookup_Numerator_Code N on N.Measure_ID=ex.Measure_ID
													and N.Numerator_response_Value =Md.Numerator_response_value

END
ELSE
BEGIN

;WITH examdata as (
SELECT 
 e.Exam_Id,md.Measure_ID,

						 count(*) over()  as FilesCount
				
				 FROM tbl_Exam e
						INNER JOIN
									 tbl_Lookup_Data_Source d on e.DataSource_Id=d.DataSource_Id					
						INNER JOIN 
									 tbl_Exam_Measure_Data Md on e.Exam_Id=Md.Exam_Id
									                and md.Measure_ID= Case When @MeasureId =0 then md.Measure_ID else @MeasureId end
												    and e.CMS_Submission_Year=@CMSYear
													 and e.Exam_TIN= Case  
																		  when @ExamTin !='' then @ExamTin
																		  else e.Exam_TIN
																		  end
						                            and e.Physician_NPI=@ExamNpi												   												
													and e.Exam_Date >= Case When @StartDate='' then e.Exam_Date else @StartDate end
													and e.Exam_Date <= Case When @EndDate='' then e.Exam_Date else  @EndDate end
													and e.Patient_Age = Case When @PatientAge = 0 then e.Patient_Age else @PatientAge end
													and e.Patient_Gender = Case When @PatientSex = '' then e.Patient_Gender else @PatientSex end
													and Md.Denominator_proc_code = Case When @CPTCode='' then Md.Denominator_proc_code else @CPTCode end											
													
						INNER JOIN  tbl_Lookup_Measure m on (md.Measure_ID=M.Measure_ID)
						
						
					where 
														
														(
														 E.Exam_TIN LIKE '%'+@Searchtext+'%'
														 OR
														 E.Exam_Unique_ID  LIKE '%'+@Searchtext+'%'
														 OR 
														 --E.Created_Date LIKE @Searchtext+'%' 
														 --OR 
														 --E.Exam_Date LIKE  @Searchtext+'%'
														 --OR 
														 MD.Numerator_Code LIKE  '%'+@Searchtext+'%'
														 OR 
														 MD.Denominator_proc_code LIKE '%'+@Searchtext+'%'
														 OR 
														 M.Measure_num LIKE '%'+@Searchtext+'%'
														)
 ORDER BY  
case
        when @SortDirection <> 'ASC' then cast(0 as INT)
        when @sortColumn = 'ExamID' then E.Exam_Id        
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(0 as INT)
        when @sortColumn = 'ExamID' then E.Exam_Id          
        end DESC
		,

		case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'TIN' then E.Exam_TIN         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'TIN' then E.Exam_TIN           
        end DESC
		,

			case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'PatientID' then E.Patient_ID         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'PatientID' then E.Patient_ID           
        end DESC
		,

			case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'MeasureNum' then M.DisplayOrder         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as int)
        when @sortColumn = 'MeasureNum' then M.DisplayOrder          
        end DESC

		,

			case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'PatientGender' then E.Patient_Gender         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'PatientGender' then E.Patient_Gender           
        end DESC


		
		,

		case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'UniqueExamID' then E.Exam_Unique_ID         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'UniqueExamID' then E.Exam_Unique_ID           
        end DESC

		,

		case
        when @SortDirection <> 'ASC' then cast(null as datetime)
        when @sortColumn = 'ExamDate' then E.Exam_Date         
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as datetime)
        when @sortColumn = 'ExamDate' then E.Exam_Date           
        end DESC

	


	
			,

		case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'CPTCode' then Md.Denominator_proc_code          
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'CPTCode' then  Md.Denominator_proc_code           
        end DESC

		,
		case
        when @SortDirection <> 'ASC' then cast(null as varchar)
        when @sortColumn = 'Created_Date' then E.Created_Date        
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as varchar)
        when @sortColumn = 'Created_Date' then   E.Created_Date          
        end DESC


 OFFSET @skiprows  ROWS
 FETCH NEXT @PageLimit ROWS ONLY
 )
 SELECT distinct


                                      e.Physician_NPI,
									  e.Exam_TIN,
									  e.Exam_Id,
									  md.Measure_ID,
									  ms.Status_Desc,
									  m.Measure_num,
								
									
									
						
									  Case When e.Patient_Gender ='M' then 'Male'
										   when e.Patient_Gender ='F' then 'Female'
										   when e.Patient_Gender='O' then 'Other'
										   when e.Patient_Gender='U' then 'Unknown'
										   end as Patient_Gender,
									
									
									
									  md.Denominator_proc_code,
									  md.Numerator_Code,
									  e.Created_Date,
									  e.Exam_Date,
									  e.Exam_Unique_ID,
									  e.Patient_ID,
									  e.Patient_Age,
									  e.IsEncrypt,
									
									  d.DataSource,
									  e.CMS_Submission_Year,
									 
						              EX.FilesCount
		
		
		
		
				 FROM
				                    examdata ex
						INNER JOIN
				                    tbl_Exam e  on e.Exam_Id=EX.Exam_Id 
				   
						INNER JOIN
									 tbl_Lookup_Data_Source d on e.DataSource_Id=d.DataSource_Id
					

						INNER JOIN 
									 tbl_Exam_Measure_Data Md on Md.Exam_Id=ex.Exam_Id and Md.Measure_ID=ex.Measure_ID
					
						INNER JOIN  tbl_Lookup_Measure m on M.Measure_ID=ex.Measure_ID
						INNER JOIN  tbl_Lookup_Measure_Status Ms on md.Status=Ms.Status_ID 
						LEFT JOIN
									tbl_lookup_Numerator_Code N on N.Measure_ID=ex.Measure_ID
													and N.Numerator_response_Value =Md.Numerator_response_value
END

END

END





