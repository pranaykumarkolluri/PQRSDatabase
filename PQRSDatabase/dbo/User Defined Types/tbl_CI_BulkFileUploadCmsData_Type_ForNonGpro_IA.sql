CREATE TYPE [dbo].[tbl_CI_BulkFileUploadCmsData_Type_ForNonGpro_IA] AS TABLE (
    [Reporting_Year]        INT           NULL,
    [TIN]                   VARCHAR (9)   NULL,
    [NPI]                   VARCHAR (10)  NULL,
    [Improvement_Activitiy] VARCHAR (100) NULL,
    [First_Encounter_Date]  DATE          NULL,
    [Last_Encounter_Date]   DATE          NULL);

