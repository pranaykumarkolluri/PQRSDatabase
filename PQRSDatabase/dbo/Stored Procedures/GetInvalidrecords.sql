create procedure GetInvalidrecords
@FileId int
As
begin
select CmsDataId,
       FileId,
       TIN,
       Npi,
       Measure_Name,
       CmsYear,
       NoofExamsSubmitted,
       Total_no_of_exams_old,
       Total_no_of_exams_new,
       HundredPercentSubmit_old,
       HundredPercentSubmit_new,
       SelectedForCms_old,
       SelectedForCms_new,
       Performac_Rate,
       Decile,
       ErrorMessage 
  from tbl_CI_BulkFileUploadCmsData where FileId = @FileId 
                                          and IsValidata = 0  
                                          and ErrorMessage IS NOT NULL
end