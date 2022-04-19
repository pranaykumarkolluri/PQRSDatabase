-- =============================================
-- Author:		<J Hari>
-- Create date: <20-12-2018>
-- Description:	<Get CMS submission data>
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_SubmissionDetails](
@Type int,
@Tin varchar(9)='',
@Npi varchar(11)='',
@CmsYear int=0,
@HttpStatusCode int=0,
@Status varchar(20)='',
@MethodID int=0,
@PageNo int=1,
	@PageLimit int=10,
	@ISASC bit=0,
	@SortColumn varchar(50)='Response_End_Date',
	@SortDirection varchar(5)='DESC'
)
as
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    set @Tin=ISNULL(@Tin,'');
	set @Npi=ISNULL(@Npi,'');
	set @Status=ISNULL(@Status,'');

	declare @skiprows int=0;
	set @skiprows = CASE WHEN  @PageNo >1 THEN (@PageNo-1) * @PageLimit ELSE 0 END 
	print @PageNo*@PageLimit

IF(@Type=1)
BEGIN
	set @Npi=''
	
SELECT t1.Request_Id, 
--t3.Category_Name,
CASE 
WHEN t2.Method_Id=4 and ISNULL(t1.Category_Id,'')=''  then 'SCORE'
WHEN t2.Method_Id <> 4 then   (select Category_Name from tbl_CI_lookup_Categories t3 where t3.Category_Id=t1.Category_Id ) 
END AS Category_Name,
			t1.Request_Data, t1.Tin,
			t1.Npi,t1.CmsYear,
			t4.MethodName, t2.Response_Data,
			t2.Status_Id,t2.Status_Code,
			t2.NoofMeasures,t2.Response_Start_Date,
			t2.Response_End_Date,t2.Status,
			count(*) over()  as FilesCount
			  FROM tbl_CI_RequestData t1
			  JOIN tbl_CI_ResponseData t2 ON t1.Request_Id = t2.Request_Id 
			 -- JOIN tbl_CI_lookup_Categories t3 ON t1.Category_Id = t3.Category_Id
			  JOIN tbl_CI_lookup_Integration_Type t4 ON t2.Method_Id = t4.Method_Id 

			   
			where t1.Tin=case when @Tin='' then t1.Tin
			                   Else @Tin END

                   AND ISNULL(t1.Npi,'')=''

							   AND t1.CmsYear=case when @CmsYear=0  then t1.CmsYear
			                   Else @CmsYear END

							   AND t2.Status_Code=case when @HttpStatusCode=0  then t2.Status_Code
			                   Else @HttpStatusCode END

							   AND t2.[Status]=case when @Status=''  then t2.[Status]
			                   Else @Status END

							  AND t2.Method_Id=case when @MethodID=0  then t2.Method_Id
			                   Else @MethodID END


							    ORDER BY  
case
        when @SortDirection <> 'ASC' then cast(null as date)
        when @sortColumn = 'Response_End_Date' then t2.Response_End_Date
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as date)
        when @sortColumn = 'Response_End_Date' then t2.Response_End_Date
        end DESC
 OFFSET @skiprows  ROWS
 FETCH NEXT @PageLimit ROWS ONLY

END
ELSE 
BEGIN

SELECT t1.Request_Id,
--t3.Category_Name,
 CASE 
WHEN t2.Method_Id=4 and ISNULL(t1.Category_Id,'')=''  then 'SCORE'
WHEN t2.Method_Id <> 4 then   (select Category_Name from tbl_CI_lookup_Categories t3 where t3.Category_Id=t1.Category_Id ) 
END AS Category_Name,

			t1.Request_Data, t1.Tin,
			t1.Npi,t1.CmsYear,
			t4.MethodName, t2.Response_Data,
			t2.Status_Id,t2.Status_Code,
			t2.NoofMeasures,t2.Response_Start_Date,
			t2.Response_End_Date,t2.Status,
			count(*) over()  as FilesCount
			  FROM tbl_CI_RequestData t1
			  JOIN tbl_CI_ResponseData t2 ON t1.Request_Id = t2.Request_Id 
			 -- JOIN tbl_CI_lookup_Categories t3 ON t1.Category_Id = t3.Category_Id
			  JOIN tbl_CI_lookup_Integration_Type t4 ON t2.Method_Id = t4.Method_Id 



			   
			where t1.Tin=case when @Tin='' then t1.Tin
			                   Else @Tin END

                   AND t1.Npi=case when @Npi='' then t1.Npi
			                   Else @Npi END

							   AND t1.CmsYear=case when @CmsYear=0  then t1.CmsYear
			                   Else @CmsYear END

							   AND t2.Status_Code=case when @HttpStatusCode=0  then t2.Status_Code
			                   Else @HttpStatusCode END

							   AND t2.[Status]=case when @Status=''  then t2.[Status]
			                   Else @Status END

							  AND t2.Method_Id=case when @MethodID=0  then t2.Method_Id
			                   Else @MethodID END
							     AND ISNULL(t1.Npi,'')<>''

								  ORDER BY  
case
        when @SortDirection <> 'ASC' then cast(null as date)
        when @sortColumn = 'Response_End_Date' then t2.Response_End_Date
        end ASC,
		case
        when @SortDirection <> 'DESC' then cast(null as date)
        when @sortColumn = 'Response_End_Date' then t2.Response_End_Date
        end DESC
 OFFSET @skiprows  ROWS
 FETCH NEXT @PageLimit ROWS ONLY


			END

END

