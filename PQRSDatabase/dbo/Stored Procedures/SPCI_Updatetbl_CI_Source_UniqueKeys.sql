-- =============================================
-- Author:		<Raju>
-- Create date: 30-11-2018
-- Description:	update tbl_CI_Source_UniqueKeys   based on Tin Npi category
-- =============================================
CREATE PROCEDURE SPCI_Updatetbl_CI_Source_UniqueKeys
    @Tin varchar(9),
	@Npi varchar(10),
	@CmsYear int,
	@Category_Id int
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	update tbl_CI_Source_UniqueKeys set IsMSetIdActive=0
	where Tin=@Tin and
	isnull(Npi,'')= isnull(@Npi,'') and
	Category_Id=@Category_Id and
	CmsYear=@CmsYear and
	IsMSetIdActive=1

    -- Insert statements for procedure here
END
