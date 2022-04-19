CREATE TABLE [dbo].[tbl_GPRO_TIN_Selected_Measures_90days] (
    [TIN_Sel_Measure_ID]      INT          IDENTITY (1, 1) NOT NULL,
    [Measure_num]             VARCHAR (50) NOT NULL,
    [Submission_year]         INT          NOT NULL,
    [TIN]                     VARCHAR (50) NOT NULL,
    [SelectedForSubmission]   BIT          NULL,
    [TotalCasesReviewed]      INT          NULL,
    [HundredPercentSubmit]    BIT          NULL,
    [DateLastSelected]        DATETIME     NULL,
    [DateLastUnSelected]      DATETIME     NULL,
    [LastModifiedBy]          VARCHAR (50) NULL,
    [Is_Active]               BIT          CONSTRAINT [default_tbl_GPRO_TIN_Selected_Measures_is90days_Is_Active] DEFAULT ((1)) NULL,
    [Is_90Days]               BIT          CONSTRAINT [default_tbl_GPRO_TIN_Selected_Measures_90days_Is_90Days] DEFAULT ((1)) NULL,
    [UpDatedFrom]             VARCHAR (50) NULL,
    [isEndToEndReported]      BIT          NULL,
    [TotalCasesReviewed_C2]   INT          NULL,
    [HundredPercentSubmit_C2] BIT          NULL,
    CONSTRAINT [PK_tbl_GPRO_TIN_Selected_Measures_is90days] PRIMARY KEY CLUSTERED ([Measure_num] ASC, [Submission_year] ASC, [TIN] ASC)
);

