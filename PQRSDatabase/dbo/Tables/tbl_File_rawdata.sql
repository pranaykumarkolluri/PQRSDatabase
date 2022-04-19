CREATE TABLE [dbo].[tbl_File_rawdata] (
    [record_id]                    INT             IDENTITY (1, 1) NOT NULL,
    [fileid]                       INT             NULL,
    [Exam_Date_Time]               DATETIME        NULL,
    [Physician_Group_TIN]          VARCHAR (9)     NULL,
    [Physician_NPI]                VARCHAR (50)    NULL,
    [Patient_ID]                   VARCHAR (500)   NULL,
    [Patient_Age]                  DECIMAL (18, 2) NULL,
    [Patient_Gender]               VARCHAR (50)    NULL,
    [Patient_Medicare_Beneficiary] SMALLINT        NULL,
    [Patient_Medicare_Advantage]   SMALLINT        NULL,
    [Measure_Number]               VARCHAR (50)    NULL,
    [CPT_Code]                     VARCHAR (50)    NULL,
    [Denominator_Diagnosis_Code]   VARCHAR (50)    NULL,
    [Numerator_Response_value]     VARCHAR (50)    NULL,
    [Measure_Extension_Num]        VARCHAR (50)    NULL,
    [Extension_Response_Value]     VARCHAR (50)    NULL,
    [Exam_Unique_ID]               VARCHAR (50)    NULL,
    [created_date]                 DATETIME        NULL,
    [createdby]                    VARCHAR (50)    NULL,
    [Record_Status]                VARCHAR (50)    NULL,
    PRIMARY KEY CLUSTERED ([record_id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ind_fileraw]
    ON [dbo].[tbl_File_rawdata]([Physician_Group_TIN] ASC, [Physician_NPI] ASC, [Patient_ID] ASC, [fileid] ASC, [Measure_Number] ASC, [CPT_Code] ASC, [Exam_Date_Time] ASC, [record_id] ASC, [Numerator_Response_value] ASC);

