-- =============================================
-- Author:		Sumanth
-- Create date: <17-jan-2018>
-- Description:	<Used to delete Upload Attestion Files >
-- =============================================
CREATE PROCEDURE SPAttestationDelete_UploadFiles 
	@Fileid int
AS
BEGIN
	delete from tbl_AttestationFiles where FileId=@Fileid
END
