CREATE TABLE [dbo].[tbl_Physician_Selected_Measures] (
    [Phy_Sel_Measure_ID]      INT          IDENTITY (1, 1) NOT NULL,
    [NPI]                     VARCHAR (50) NOT NULL,
    [Physician_ID]            INT          NOT NULL,
    [Measure_num_ID]          VARCHAR (50) NOT NULL,
    [Submission_year]         INT          NOT NULL,
    [TIN]                     VARCHAR (50) NULL,
    [SelectedForSubmission]   BIT          NULL,
    [TotalCasesReviewed]      INT          NULL,
    [HundredPercentSubmit]    BIT          NULL,
    [DateLastSelected]        DATETIME     NULL,
    [DateLastUnSelected]      DATETIME     NULL,
    [LastModifiedBy]          VARCHAR (50) NULL,
    [Is_Active]               BIT          CONSTRAINT [default_tbl_Physician_Selected_Measures_Is_Active] DEFAULT ((1)) NULL,
    [Is_90Days]               BIT          CONSTRAINT [default_tbl_Physician_Selected_Measures_Is_90Days] DEFAULT ((0)) NULL,
    [UpDatedFrom]             VARCHAR (50) NULL,
    [isEndToEndReported]      BIT          NULL,
    [TotalCasesReviewed_C2]   INT          NULL,
    [HundredPercentSubmit_C2] BIT          NULL,
    CONSTRAINT [PK_tbl_Physician_Selected_Measures] PRIMARY KEY CLUSTERED ([Phy_Sel_Measure_ID] ASC)
);

