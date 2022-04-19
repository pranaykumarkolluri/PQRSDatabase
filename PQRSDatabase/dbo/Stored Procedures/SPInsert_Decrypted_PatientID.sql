-- =============================================
-- Author:		Hari J
-- Create date: Dec 12th,2018
-- Description:	used to bulk insert of npi related decrypted patient ids
--Change #1 By: Raju G 
--Change #1:decrypted patient ids
-- =============================================
CREATE PROCEDURE [dbo].[SPInsert_Decrypted_PatientID]
	-- Add the parameters for the stored procedure here
	@tbl_PatientIds_decryption_Npis_Type tbl_PatientIds_decryption_Npis_Type readonly
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	--UPDATE E
	--SET E.Decrypt_Patient_ID=P.Decrypt_Patient_ID
	--from arch_tbl_exam_2017 E inner join @tbl_PatientIds_decryption_Npis_Type P
	--ON E.Exam_Id =P.Exam_Id

	--change #1
	UPDATE E
	SET E.decrpyted_patient_id=P.Decrypt_Patient_ID
	from tmp_tbl_exam E inner join @tbl_PatientIds_decryption_Npis_Type P
	ON E.Exam_Id =P.Exam_Id

	RETURN @@ROWCOUNT
END
