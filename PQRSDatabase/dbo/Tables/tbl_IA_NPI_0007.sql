CREATE TABLE [dbo].[tbl_IA_NPI_0007] (
    [Firstname]             VARCHAR (256) NULL,
    [Lastname]              VARCHAR (256) NULL,
    [NPI]                   VARCHAR (10)  NULL,
    [Tin]                   VARCHAR (9)   NULL,
    [SelectedActivites]     VARCHAR (MAX) NULL,
    [isGpro]                BIT           NULL,
    [emailid]               VARCHAR (1)   NOT NULL,
    [isFinalize]            BIT           NULL,
    [finalizeAgreeDate]     VARCHAR (10)  NULL,
    [finalizeDisAgreeDate]  VARCHAR (10)  NULL,
    [isSubmitToCI]          BIT           NULL,
    [LastSubmittedDateTime] VARCHAR (1)   NOT NULL,
    [CMSYear]               INT           NULL,
    [SubmittoCMS]           BIT           NULL
);

