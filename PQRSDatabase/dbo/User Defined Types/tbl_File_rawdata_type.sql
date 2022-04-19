CREATE TYPE [dbo].[tbl_File_rawdata_type] AS TABLE (
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
    [Exam_Unique_ID]               VARCHAR (50)    NULL);

