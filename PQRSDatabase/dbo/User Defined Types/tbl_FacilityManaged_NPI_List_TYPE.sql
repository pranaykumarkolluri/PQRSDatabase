CREATE TYPE [dbo].[tbl_FacilityManaged_NPI_List_TYPE] AS TABLE (
    [UserId]             VARCHAR (100) NULL,
    [PhysicianNPI]       VARCHAR (10)  NULL,
    [FacilityID]         VARCHAR (50)  NULL,
    [Created_Date]       DATETIME      NULL,
    [Created_by]         VARCHAR (10)  NULL,
    [Last_Modified_date] DATETIME      NULL,
    [Last_Modified_by]   VARCHAR (10)  NULL);

