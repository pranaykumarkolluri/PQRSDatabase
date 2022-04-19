CREATE TABLE [dbo].[Tbl_Hitrust_Exceptions] (
    [ExceptionId]      INT           IDENTITY (1, 1) NOT NULL,
    [ExceptionType]    VARCHAR (256) NULL,
    [ExceptionMessage] VARCHAR (MAX) NULL,
    [CreatedBy]        INT           NULL,
    [CreatedDate]      DATETIME      NULL,
    CONSTRAINT [PK_tbl_Hitrust_Exceptions] PRIMARY KEY CLUSTERED ([ExceptionId] ASC)
);

