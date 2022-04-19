CREATE TABLE [dbo].[tbl_Lookup_Active_Submission_Year] (
    [Id]                         INT           IDENTITY (1, 1) NOT NULL,
    [Submission_Year]            INT           NOT NULL,
    [IsActive]                   BIT           NOT NULL,
    [Date_activated]             DATETIME      NULL,
    [Date_Inactvated]            DATETIME      NULL,
    [Other_Information]          VARCHAR (MAX) NULL,
    [DisplayYearForReport]       BIT           CONSTRAINT [DF_tbl_Lookup_Active_Submission_Year_DisplayYearForReport] DEFAULT ((0)) NULL,
    [DisplayYearForDataReadOnly] BIT           NULL,
    [On_hold]                    BIT           NULL,
    [IsSubmittoCMS]              BIT           NULL,
    CONSTRAINT [PK_tbl_Lookup_Active_ Submission_Year] PRIMARY KEY CLUSTERED ([Id] ASC)
);

