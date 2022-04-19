
CREATE PROCEDURE [dbo].[sp_getTIN_GPRO] 

	-- Add the parameters for the stored procedure here

	@TIN varchar(20) = ''

AS

BEGIN

set nocount on;
-- if not exists, then insert into table
declare @Tindata table (TIN varchar(9), IS_GPRO bit);
if not exists( select top 1 TIN from tbl_TIN_GPRO where TIN = @TIN)

Begin

delete from @Tindata

	insert into @Tindata
	exec nrdr..[sp_getTIN_GPRO] @TIN = @TIN

	insert into tbl_TIN_GPRO (TIN,is_GPRO,createdate) 
	select TIN,IS_GPRO,GETDATE() as createdate  from @Tindata 

	--delete from tbl_TIN_GPRO where TIN = @TIN 

End
else
begin
delete from tbl_TIN_GPRO where TIN =@TIN;
delete from @Tindata

	insert into @Tindata
	exec nrdr..[sp_getTIN_GPRO] @TIN = @TIN

	insert into tbl_TIN_GPRO (TIN,is_GPRO,createdate) 
	select TIN,IS_GPRO,GETDATE() as createdate  from @Tindata 
end
	

	--select * from tbl_TIN_GPRO where TIN = @TIN;

END

