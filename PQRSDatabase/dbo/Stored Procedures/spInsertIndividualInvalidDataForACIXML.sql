-- =============================================
-- Author:		Raju Gaddam
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spInsertIndividualInvalidDataForACIXML] 
	-- Add the parameters for the stored procedure here
	
	@Tin varchar(9),
	@Npi varchar(11),
	@CmsYear int,
	@measureId varchar(50)
AS
BEGIN

if exists (select top 1 record_id from tbl_Individual_Invalid_Data_For_ACIXML 
where CMS_Submission_Year=@CmsYear
and TIN=@Tin
and MeasureId=@measureId
and NPI=@Npi)
begin
---remove data based tin ,year and mesureId
		delete   from tbl_Individual_Invalid_Data_For_ACIXML 
		where CMS_Submission_Year=@CmsYear
		and TIN=@Tin
		and MeasureId=@measureId
		and NPI=@Npi


		--insert data based tin ,year and mesureId
		insert into 
		tbl_Individual_Invalid_Data_For_ACIXML
		(
		TIN
		,NPI
		,CMS_Submission_Year
		,MeasureId
		,createdate
		)
		values(
		@Tin
		,@Npi
		,@CmsYear
		,@measureId
		,GETDATE())
end
else
begin
--insert data based tin ,year and mesureId
		--insert data based tin ,year and mesureId
		insert into 
		tbl_Individual_Invalid_Data_For_ACIXML
		(
		TIN
		,NPI
		,CMS_Submission_Year
		,MeasureId
		,createdate
		)
		values(
		@Tin
		,@Npi
		,@CmsYear
		,@measureId
		,GETDATE())
end
END
