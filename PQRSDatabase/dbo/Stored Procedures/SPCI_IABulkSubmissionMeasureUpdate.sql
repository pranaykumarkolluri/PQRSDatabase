

-- =============================================
-- Author:		<PAVAN>
-- Create date: <01-12-2021>
-- Description: used to insert IA bulk Excel data for CMS Submission
-- =============================================
CREATE PROCEDURE [dbo].[SPCI_IABulkSubmissionMeasureUpdate]
	-- Add the parameters for the stored procedure here
	@Cmsyear int,
	@useId int,
	@isACRStaff bit
AS
BEGIN
	SET NOCOUNT ON;

	Declare @UserTINNPIDetails table(TIN varchar(9), NPI varchar(10), PaymentStatus bit NULL, AttestationStatus bit NULL, OptinStatus bit NULL)
	Declare @CurrentFileId int
	Declare @ErrorMessage varchar(100)
	Declare @IsGpro bit

		Declare FileID_Cursor CURSOR FOR (select distinct H.FileId from tbl_CI_BulkFileUpload_History H  where H.Status = 24 )
			OPEN FileID_Cursor
				FETCH NEXT FROM FileID_Cursor INTO @CurrentFileId
				WHILE @@FETCH_STATUS = 0
				BEGIN
				select @CurrentFileId
					select @IsGpro = IsGpro from tbl_CI_BulkFileUpload_History where FileId = @CurrentFileId
					Exec SPCI_BulkUpload_PREValidation_For_IA @IsGpro,@CurrentFileId
					FETCH NEXT FROM FileID_Cursor INTO @CurrentFileId
				END
			CLOSE FileID_Cursor;
		DEALLOCATE FileID_Cursor;

END


