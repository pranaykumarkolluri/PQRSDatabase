CREATE TYPE [dbo].[tbl_CI_BulkFileUploadCmsData_Type_ForGpro] AS TABLE (
    [TIN]                                    VARCHAR (100) NULL,
    [Measure_Name]                           VARCHAR (100) NULL,
    [Total_numberof_Exams_mygroup_performed] VARCHAR (100) NULL,
    [Number_of_Exams_Submitted_OLD]          VARCHAR (100) NULL,
    [Number_of_Exams_Submitted_NEW]          VARCHAR (100) NULL,
    [Submitted_Hundred_Percent_OLD]          VARCHAR (100) NULL,
    [Submitted_Hundred_Percent_NEW]          VARCHAR (100) NULL,
    [Selected_for_CMS_submission_OLD]        VARCHAR (100) NULL,
    [Selected_for_CMS_submission_NEW]        VARCHAR (100) NULL,
    [EndtoEndReporting_OLD]                  VARCHAR (100) NULL,
    [EndtoEndReporting_NEW]                  VARCHAR (100) NULL,
    [Performance_rate]                       VARCHAR (100) NULL,
    [Completeness]                           VARCHAR (100) NULL,
    [Decile]                                 VARCHAR (MAX) NULL);

