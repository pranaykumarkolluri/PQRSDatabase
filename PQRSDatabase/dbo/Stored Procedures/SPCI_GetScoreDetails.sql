-- =============================================
-- Author:		<Sumanth>
-- Create date: <18-jan-2019>
-- Description:	<used to get records based on Tin,Npi>
-- =============================================


CREATE PROCEDURE [dbo].[SPCI_GetScoreDetails] (
	@Tin varchar(9)='',
	@Npi varchar(10)='',
	@CmsYear int,
	@CategoryId int,
	@Type int,
	@PageNo int=1,
	@PageLimit int=10,
	@ISASC bit=0,
	@SortColumn varchar(50)='LastSubmittedDate',
	@SortDirection varchar(5)='DESC'
	)
AS
BEGIN
    set @Tin=ISNULL(@Tin,'');
	set @Npi=ISNULL(@Npi,'');
	declare @CategoryName varchar(50)
	declare @submittedDate datetime;
	select @CategoryName=Category_Name from tbl_CI_lookup_Categories where Category_Id=@CategoryId

		declare @skiprows int=0;
	set @skiprows = CASE WHEN  @PageNo >1 THEN (@PageNo-1) * @PageLimit ELSE 0 END 
	print @PageNo*@PageLimit

	if(@Type=1)
	begin
	
	select k.Tin,k.Npi,@CategoryName as CategoryName,k.CmsYear,(k.CmsSubmissionDate) as LastSubmittedDate,k.Submission_Uniquekey_Id,
	 count(*) over()  as FilesCount
	   from tbl_CI_Source_UniqueKeys k where k.Tin=case when @Tin='' then k.Tin Else @Tin END  
	and k.Category_Id=@CategoryId 
	and ISNULL(k.Npi,'')=''
	and k.CmsYear=@CmsYear 
	and k.IsMSetIdActive=1
	and k.CmsSubmissionDate is not null

	
							    ORDER BY  
case
        when @SortDirection <> 'ASC' then cast(null as date)
        when @sortColumn = 'LastSubmittedDate' then 

			(k.CmsSubmissionDate
		) 
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as date)
        when @sortColumn = 'LastSubmittedDate' then 

			(k.CmsSubmissionDate
		) 

        end DESC
 OFFSET @skiprows  ROWS
 FETCH NEXT @PageLimit ROWS ONLY
	end
	else
	begin
	select k.Tin,k.Npi,@CategoryName as CategoryName,k.CmsYear,(k.CmsSubmissionDate
	 ) as LastSubmittedDate,k.Submission_Uniquekey_Id,
	 count(*) over()  as FilesCount
	  from tbl_CI_Source_UniqueKeys k where k.Tin=case when @Tin='' then k.Tin Else @Tin END   
	and k.Category_Id=@CategoryId 
	and  k.Npi=case when @Npi='' then k.Npi Else @Npi END 
    and ISNULL(k.Npi,'')<>''  
	and k.CmsYear=@CmsYear 
	and k.IsMSetIdActive=1
	and k.CmsSubmissionDate is not null

	
							    ORDER BY  
case
        when @SortDirection <> 'ASC' then cast(null as date)
        when @sortColumn = 'LastSubmittedDate' then 

		(k.CmsSubmissionDate
		) 

        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as date)
        when @sortColumn = 'LastSubmittedDate' then 

		(k.CmsSubmissionDate
		) 

        end DESC
 OFFSET @skiprows  ROWS
 FETCH NEXT @PageLimit ROWS ONLY
	end


END

