-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPRecordEnteredPageGridDetails]
	-- Add the parameters for the stored procedure here
@CMSYear int,
@npi varchar(10) ,
@PageNo int=1,
	@PageLimit int=20,
	@ISASC bit=0,
	@SortColumn varchar(50)='Exam_Id',
	@SortDirection varchar(5)='ASC'
	
AS
BEGIN


declare @skiprows int=0;
set @skiprows = CASE WHEN  @PageNo >1 THEN (@PageNo-1) * @PageLimit ELSE 0 END;
--SET @SortDirection= CASE WHEN  @SortDirection='DSC' THEN 'DESC' ELSE 'ASC' END;

/*
;with examdata as (

  select Exam_Id from tbl_Exam where Physician_NPI=@npi and CMS_Submission_Year=@CMSYear 

   ORDER BY  
case
        when @SortDirection <> 'ASC' then cast(null as int)
        when @sortColumn = @SortColumn then Exam_Id        --Change#4:
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as int)
        when @sortColumn = @SortColumn then Exam_Id        --Change#4:
        end DESC
 OFFSET @skiprows  ROWS
 FETCH NEXT @PageLimit ROWS ONLY
)	
*/	
/*
	declare @RecordsCount int=0;
			select	@RecordsCount=count(*)   
					
												 from tbl_Exam ex inner join
												tbl_Exam_Measure_Data exmes on --ex.Exam_Id in(select Exam_Id from examdata)
												ex.Exam_Id=exmes.Exam_Id 
												and ex.Exam_Id is not null  
												INNER join tbl_lookup_Numerator_Code N on N.Measure_ID=exmes.Measure_ID and exmes.Numerator_response_value=N.Numerator_response_Value
												inner join tbl_Lookup_Measure Mes on exmes.Measure_ID=Mes.Measure_ID 
												left join tbl_Lookup_Data_Source d on ex.DataSource_Id=d.DataSource_Id 
												left join tbl_Lookup_Measure_Status M on exmes.Status=m.Status_ID 
	
						*/			
					select 
					
					ex.Physician_NPI as NPI,
					ex.Exam_TIN as TIN,
					ex.Exam_Id as ExamID,
					exmes.Measure_ID as MeasureID,
					Mes.Measure_num as MeasureNum,
					exmes.Denominator_proc_code as CPTCode,
					N.Numerator_Code as NumeratorCode,
					ex.Created_Date as Created_Date,
				    ex.Exam_Date as ExamDate,
					ex.Exam_Unique_ID as  UniqueExamID,
					ex.Patient_Gender as  PatientGender ,
					ex.Patient_ID as PatientID,
					ex.IsEncrypt as isEncrypt,
					ex.Patient_Age as PatientAge,
					m.Status_Desc as StatusDesc,
					d.DataSource,
					ex.CMS_Submission_Year as cmsYear ,
					count(*) over()  as RecordsCount
					
												 from tbl_Exam ex inner join
												tbl_Exam_Measure_Data exmes on --ex.Exam_Id in(select Exam_Id from examdata)
												
												 --and 
												 ex.Exam_Id=exmes.Exam_Id 
												and ex.Exam_Id is not null  

												join tbl_lookup_Numerator_Code N on N.Measure_ID=exmes.Measure_ID and exmes.Numerator_response_value=N.Numerator_response_Value
												inner join tbl_Lookup_Measure Mes on exmes.Measure_ID=Mes.Measure_ID 
												left join tbl_Lookup_Data_Source d on ex.DataSource_Id=d.DataSource_Id 
												left join tbl_Lookup_Measure_Status M on exmes.Status=m.Status_ID 
										
							ORDER BY  
								  case
										when @SortDirection <> 'ASC' then cast(null as int)
										when @sortColumn = @SortColumn then ex.Exam_Id        --Change#4:
										end ASC,
										case
										when @SortDirection <> 'DSC' then cast(null as int)
										when @sortColumn = @SortColumn then ex.Exam_Id        --Change#4:
										end DESC,


								  case
										when @SortDirection <> 'ASC' then cast(null as varchar)
										when @sortColumn = 'TIN' then ex.Exam_TIN        --Change#4:
										end ASC,
										case
										when @SortDirection <> 'DSC' then cast(null as varchar)
										when @sortColumn = 'TIN' then ex.Exam_TIN        --Change#4:
										end DESC
										,
									case
										when @SortDirection <> 'ASC' then cast(null as varchar)
										when @sortColumn = 'MeasureNum' then Mes.Measure_num        --Change#4:
										end ASC,
										case
										when @SortDirection <> 'DSC' then cast(null as varchar)
										when @sortColumn = 'MeasureNum' then Mes.Measure_num        --Change#4:
										end DESC
								
								--UniqueExamID
											,
									case
										when @SortDirection <> 'ASC' then cast(null as varchar)
										when @sortColumn = 'UniqueExamID' then ex.Exam_Unique_ID        --Change#4:
										end ASC,
										case
										when @SortDirection <> 'DSC' then cast(null as varchar)
										when @sortColumn = 'UniqueExamID' then ex.Exam_Unique_ID         --Change#4:
										end DESC
								 --

								 			,
									case
										when @SortDirection <> 'ASC' then cast(null as varchar)
										when @sortColumn = 'ExamDate' then ex.Exam_Date        --Change#4:
										end ASC,
										case
										when @SortDirection <> 'DSC' then cast(null as varchar)
										when @sortColumn = 'ExamDate' then ex.Exam_Date         --Change#4:
										end DESC
									

										,
									case
										when @SortDirection <> 'ASC' then cast(null as varchar)
										when @sortColumn = 'CPTCode' then exmes.Denominator_proc_code        --Change#4:
										end ASC,
										case
										when @SortDirection <> 'DSC' then cast(null as varchar)
										when @sortColumn = 'CPTCode' then exmes.Denominator_proc_code          --Change#4:
										end DESC
										,
									case
										when @SortDirection <> 'ASC' then cast(null as varchar)
										when @sortColumn = 'NumeratorCode' then N.Numerator_Code       --Change#4:
										end ASC,
										case
										when @SortDirection <> 'DSC' then cast(null as varchar)
										when @sortColumn = 'NumeratorCode' then N.Numerator_Code          --Change#4:
										end DESC
										,
									case
										when @SortDirection <> 'ASC' then cast(null as varchar)
										when @sortColumn = 'Created_Date' then ex.Created_Date       --Change#4:
										end ASC,
										case
										when @SortDirection <> 'DSC' then cast(null as varchar)
										when @sortColumn = 'Created_Date' then ex.Created_Date          --Change#4:
										end DESC

											,
									case
										when @SortDirection <> 'ASC' then cast(null as varchar)
										when @sortColumn = 'cmsYear' then ex.CMS_Submission_Year       --Change#4:
										end ASC,
										case
										when @SortDirection <> 'DSC' then cast(null as varchar)
										when @sortColumn = 'cmsYear' then ex.CMS_Submission_Year          --Change#4:
										end DESC
						       				,
									case
										when @SortDirection <> 'ASC' then cast(null as varchar)
										when @sortColumn = 'PatientGender' then ex.Patient_Gender       --Change#4:
										end ASC,
										case
										when @SortDirection <> 'DSC' then cast(null as varchar)
										when @sortColumn = 'PatientGender' then ex.Patient_Gender          --Change#4:
										end DESC
						


								 OFFSET @skiprows  ROWS
								 FETCH NEXT @PageLimit ROWS ONLY	 												--left join tbl_Lookup_Measure_Status
END
