CREATE TABLE [dbo].[tbl_Lookup_Measure_Priority] (
    [Priority_ID]  INT           IDENTITY (1, 1) NOT NULL,
    [Name]         VARCHAR (50)  NULL,
    [Decscription] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_tbl_Lookup_Measure_Priority] PRIMARY KEY CLUSTERED ([Priority_ID] ASC)
);

