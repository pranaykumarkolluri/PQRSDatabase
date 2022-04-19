
CREATE PROCEDURE [dbo].[sp_getNPIsOfTin] 
	-- Add the parameters for the stored procedure here
	@TIN varchar(20) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @TINSofNPI table (
NPI varchar(50),
FirstName varchar(50),
LastName varchar(50),
TIN varchar(10),
is_GPRO  bit,
IS_ENROLLED bit
)


--Getting All TIN and NPIs from [PHYSICIAN_TIN_VW]
Declare @PhysicinaTins as Table(NPI Varchar(10),
TIN Varchar(9),
IS_ENROLLED bit
)

INSERT into @PhysicinaTins
select   NPI,TIN,CONVERT(bit, Max (Convert(int,IS_ENROLLED))) as IS_ENROLLED from NRDR..[PHYSICIAN_TIN_VW] where TIN=@tin
group by NPI,TIN
 

insert into @TINSofNPI
	SELECT distinct U.NPI,U.FirstName,u.LastName,T.TIN,G.is_GPRO,T.IS_ENROLLED FROM  
tbl_Users U
--left join tbl_Physician_TIN T   on  U.UserID = T.UserID
left join @PhysicinaTins T   on  U.NPI = T.NPI
left join [dbo].[tbl_TIN_GPRO] G on
    G.TIN =T.TIN
    where T.TIN=ltrim(rtrim(@TIN))
	and U.NPI is not null
   
  set nocount off
   select distinct  * from @TINSofNPI


   return @@rowcount
END


