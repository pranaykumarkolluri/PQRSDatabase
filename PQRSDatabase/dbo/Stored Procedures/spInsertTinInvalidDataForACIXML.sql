-- =============================================
-- Author:		Raju Gaddam
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spInsertTinInvalidDataForACIXML] 
	-- Add the parameters for the stored procedure here
	@Tin varchar(9),
	@CmsYear int,
	@measureId varchar(50)
AS
BEGIN

if exists (select top 1 record_id from tbl_Tin_Invalid_Data_For_ACIXML 
where CMS_Submission_Year=@CmsYear
and TIN=@Tin
and MeasureId=@measureId)
begin
---remove data based tin ,year and mesureId
delete   from tbl_Tin_Invalid_Data_For_ACIXML 
where CMS_Submission_Year=@CmsYear
and TIN=@Tin
and MeasureId=@measureId



		--insert data based tin ,year and mesureId
		insert into 
		tbl_Tin_Invalid_Data_For_ACIXML
		(
		TIN
		,CMS_Submission_Year
		,MeasureId
		,createdate
		)
		values(
		@Tin
		,@CmsYear
		,@measureId
		,GETDATE())
end
else
begin
--insert data based tin ,year and mesureId
		--insert data based tin ,year and mesureId
		insert into 
		tbl_Tin_Invalid_Data_For_ACIXML
		(
		TIN
		,CMS_Submission_Year
		,MeasureId
		,createdate
		)
		values(
		@Tin
		,@CmsYear
		,@measureId
		,GETDATE())
end
END
