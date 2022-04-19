CREATE TABLE [dbo].[tbl_UserRoles] (
    [MappingID] INT IDENTITY (1, 1) NOT NULL,
    [UserID]    INT NOT NULL,
    [RoleID]    INT NOT NULL,
    CONSTRAINT [PK_tbl_UserRoles_1] PRIMARY KEY CLUSTERED ([MappingID] ASC),
    CONSTRAINT [FK_tbl_UserRoles_tbl_Lookup_Roles] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[tbl_Lookup_Roles] ([Role_ID]),
    CONSTRAINT [FK_tbl_UserRoles_tbl_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[tbl_Users] ([UserID])
);

