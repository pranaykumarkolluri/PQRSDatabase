-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SPTemp
@tbl_CI_Tins_Type tbl_CI_Tins_Type Readonly
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here

--Step #1
select Tin as Tin1 ,Tin as Tin2 from @tbl_CI_Tins_Type  -- join with type 

--Step#2

-- return resultset 
END
