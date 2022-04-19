CREATE TABLE [dbo].[TBL_SELECT_NON_GPRO_MEASURES_BACKEND] (
    [ID]                   INT          NULL,
    [TIN]                  VARCHAR (9)  NULL,
    [NPI]                  VARCHAR (10) NULL,
    [Measure_num]          VARCHAR (50) NULL,
    [Total_exam_count]     INT          NULL,
    [IsProcessDone]        BIT          DEFAULT ((0)) NULL,
    [IsProcessDone_IA]     BIT          DEFAULT ((0)) NULL,
    [HundredPercentSubmit] BIT          NULL
);

