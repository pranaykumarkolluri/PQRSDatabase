CREATE TYPE [dbo].[tbl_Exam_Decrypted_PatientIds_Type] AS TABLE (
    [exam_id]              INT           NULL,
    [patient_id]           VARCHAR (500) NULL,
    [decrypted_patient_id] VARCHAR (500) NULL);

