-- =============================================
-- Author:		Raju Gaddam
-- Create date:  
-- Description:IsActive Status Set 0 based on entityType and Isactive =1
-- =============================================
CREATE PROCEDURE SPCI_SubsDataSyncStatusUpdate
	@EntityType varchar(15),
	@TotalCount int,
	@Username varchar(50)
AS
BEGIN

BEGIN TRY
BEGIN Transaction

declare @id uniqueidentifier
set @id =NEWID();

update tbl_CI_SubmissionRequestData set isActive=0 where EntityType=@EntityType and IsActive=1

insert into tbl_CI_SubmissionRequestData
(EntityType,totalItems,
CreatedBy,
Submissions_Req_Id,
CreatedDate,isActive)
values(
@EntityType,
@TotalCount,
@Username,
@id,
GETDATE(),1)

Commit Transaction
END TRY

BEGIN CATCH
Rollback Transaction
set @id =null
END CATCH
select @id 
END

