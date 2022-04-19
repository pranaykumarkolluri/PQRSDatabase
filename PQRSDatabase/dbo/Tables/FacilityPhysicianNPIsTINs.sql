CREATE TABLE [dbo].[FacilityPhysicianNPIsTINs] (
    [first_name]        VARCHAR (256) NULL,
    [last_name]         VARCHAR (256) NULL,
    [npi]               VARCHAR (10)  NULL,
    [TIN]               VARCHAR (9)   NULL,
    [is_active]         BIT           NULL,
    [deactivation_date] DATETIME      NULL,
    [is_enrolled]       BIT           NULL
);

