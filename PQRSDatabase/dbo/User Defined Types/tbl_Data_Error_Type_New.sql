CREATE TYPE [dbo].[tbl_Data_Error_Type_New] AS TABLE (
    [Exam_Date_Time]             VARCHAR (500)  NULL,
    [Physician Group Tin]        VARCHAR (500)  NULL,
    [Physician NPI]              VARCHAR (500)  NULL,
    [Patient ID]                 VARCHAR (500)  NULL,
    [Patient Age]                VARCHAR (500)  NULL,
    [Patient Gender]             VARCHAR (500)  NULL,
    [Measure Number]             VARCHAR (500)  NULL,
    [CPT_Code]                   VARCHAR (500)  NULL,
    [Denominator Diagnosis Code] VARCHAR (500)  NULL,
    [Numerator Response Value]   VARCHAR (500)  NULL,
    [Exam_Unique_ID]             VARCHAR (500)  NULL,
    [Error]                      VARCHAR (2000) NULL,
    [Warning]                    VARCHAR (2000) NULL,
    [Exclusion]                  VARCHAR (2000) NULL,
    [FileRow_Num]                INT            NULL);

