CREATE TABLE [dbo].[tbl_Exam_Decrypted_PatientIds_Data] (
    [exam_id]              INT           NULL,
    [patient_id]           VARCHAR (500) NULL,
    [decrypted_patient_id] VARCHAR (500) NULL
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20191216-130522]
    ON [dbo].[tbl_Exam_Decrypted_PatientIds_Data]([exam_id] ASC);

