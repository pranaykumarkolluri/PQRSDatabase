-- =============================================
-- Author:		Hari J
-- Create date: 12/07/18
-- Description:	Get procedure codes for manual data entry
--Change#1: Raju 
--Change#1 JIRA:812
-- =============================================
CREATE PROCEDURE [dbo].[SpGet_DenomProc_Code_ForManualDataEntry] 
	-- Add the parameters for the stored procedure here
	@Measure_ID int,
	@Gender_Restriction varchar(5),
	@Age int=0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @CmsYear int=0;
	declare @MeasureNum varchar(50);
	select @CmsYear=CMSYear , @MeasureNum=Measure_num from tbl_Lookup_Measure where Measure_ID=@Measure_ID

	
	if(@CmsYear>2020 and @MeasureNum <>'438')
	begin

	       
  
		select DISTINCT Proc_code from tbl_lookup_Denominator_Proc_Code where
		-- CMSYear=2018 and
		  Measure_ID=@Measure_ID
		and Proc_code not in (select Proc_code from tbl_lookup_Denominator_Proc_Code where
		-- CMSYear=2018 and 
		  Measure_ID=@Measure_ID and Denominator_Exclusion=1  )
	end
	else if(@CmsYear>2020 and @MeasureNum='438'and @Age >=21 and @Age<40)
	begin
	   select DISTINCT Proc_code from tbl_lookup_Denominator_Proc_Code where
		-- CMSYear=2018 and
		  Measure_ID=@Measure_ID
		and Proc_code not in (select Proc_code from tbl_lookup_Denominator_Proc_Code where
		-- CMSYear=2018 and 
		  Measure_ID=@Measure_ID and Denominator_Exclusion=1  )
		  and( Proc_Criteria='CRITERIA1' or Proc_Criteria='CRITERIA2')

	end
	else if(@CmsYear>2020 and @MeasureNum='438'and @Age >=21 and @Age<=75)
	begin
select DISTINCT Proc_code from tbl_lookup_Denominator_Proc_Code where
		-- CMSYear=2018 and
		  Measure_ID=@Measure_ID
		and Proc_code not in (select Proc_code from tbl_lookup_Denominator_Proc_Code where
		-- CMSYear=2018 and 
		  Measure_ID=@Measure_ID and Denominator_Exclusion=1  )
		--  and( Proc_Criteria='CRITERIA3')


	end
	else if(@CmsYear>2020 and @MeasureNum='438')
	begin

	     select DISTINCT Proc_code from tbl_lookup_Denominator_Proc_Code where
		-- CMSYear=2018 and
		  Measure_ID=0
	end



  

END



