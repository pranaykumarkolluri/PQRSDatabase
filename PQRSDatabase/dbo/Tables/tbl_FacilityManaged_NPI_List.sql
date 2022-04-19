CREATE TABLE [dbo].[tbl_FacilityManaged_NPI_List] (
    [UserId]             VARCHAR (100) NOT NULL,
    [PhysicianNPI]       VARCHAR (10)  NOT NULL,
    [FacilityID]         VARCHAR (50)  NOT NULL,
    [Created_Date]       DATETIME      NOT NULL,
    [Created_by]         VARCHAR (10)  NOT NULL,
    [Last_Modified_date] DATETIME      NOT NULL,
    [Last_Modified_by]   VARCHAR (10)  NOT NULL,
    CONSTRAINT [PK_tbl_FacilityManaged_NPI_List] PRIMARY KEY CLUSTERED ([UserId] ASC, [PhysicianNPI] ASC, [FacilityID] ASC)
);

