CREATE TABLE [dbo].[tbl_Lookup_Measure_Status] (
    [Status_ID]   INT           NOT NULL,
    [Status_Desc] NVARCHAR (20) NOT NULL,
    CONSTRAINT [PK_tbl_Status] PRIMARY KEY CLUSTERED ([Status_ID] ASC)
);

