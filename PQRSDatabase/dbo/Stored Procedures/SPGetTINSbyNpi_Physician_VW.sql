CREATE PROCEDURE [dbo].[SPGetTINSbyNpi_Physician_VW]
	-- Add the parameters for the stored procedure here
	@NPI varchar(10)=''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select distinct (Tin),IS_ACTIVE,IS_ENROLLED from NRDR..PHYSICIAN_TIN_VW where NPI  =  CASE @NPI when '' THEN NPI

	ELSE @NPI END
	 
END

--selec