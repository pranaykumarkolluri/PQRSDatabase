
-- =============================================
-- Author:		Raju g
-- Create date: dec,16 2019
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPExamData_Decrypted_PatientIds]
	-- Add the parameters for the stored procedure here

@tbl_Exam_Decrypted_PatientIds_Type tbl_Exam_Decrypted_PatientIds_Type readonly
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	

	delete from tbl_Exam_Decrypted_PatientIds_Data where exam_id 
	in (select exam_id from  @tbl_Exam_Decrypted_PatientIds_Type)

	INSERT INTO [dbo].[tbl_Exam_Decrypted_PatientIds_Data]
           ([exam_id]
           ,[patient_id]
           ,[decrypted_patient_id])
		   select exam_id,patient_id,decrypted_patient_id from  
		   @tbl_Exam_Decrypted_PatientIds_Type		 

END
