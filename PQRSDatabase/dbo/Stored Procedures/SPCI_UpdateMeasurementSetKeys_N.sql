-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_UpdateMeasurementSetKeys_N]
	-- Add the parameters for the stored procedure here
	 @Tin varchar(9) ,
	 @Npi varchar(10),
	 @CmsYear int,
	 @ResponseId int,
	@tbl_CI_Source_UniqueKeys_Type tbl_CI_Source_UniqueKeys_Type READONLY
AS
BEGIN


---Step#1 Update IsMSetIdActive=0 based on Tin ,Npi,CmsYear

update tbl_CI_Source_UniqueKeys 
set IsMSetIdActive =0 
where Tin=@Tin and  isnull(Npi,'')=isnull(@Npi,'') and CmsYear =@CmsYear 

--Step#2  Insert new data to tbl_CI_Source_UniqueKeys from @tbl_CI_Source_UniqueKeys_Type based on  Tin ,Npi,CmsYear
insert into tbl_CI_Source_UniqueKeys 
(Tin,
Npi,
CmsYear,
MeasurementSet_Unquekey_id,
Response_Id,
Submission_Uniquekey_Id,
Category_Id,
IsMSetIdActive
)
select 
@Tin
,@Npi
,@CmsYear
,
MeasurementSet_Unquekey_id,
@ResponseId,
Submission_Uniquekey_Id,
Category_Id,
1
from 
@tbl_CI_Source_UniqueKeys_Type
END
