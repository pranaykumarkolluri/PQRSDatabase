CREATE TABLE [dbo].[TBL_AUDIT_SELECT_IA_NON_GPRO_MEASURES_BACKEND] (
    [ID]               INT            IDENTITY (1, 1) NOT NULL,
    [TIN]              VARCHAR (9)    NULL,
    [NPI]              VARCHAR (10)   NULL,
    [Measure_num]      VARCHAR (5000) NULL,
    [Created_datetime] DATETIME       NULL
);

