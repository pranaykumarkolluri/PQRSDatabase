



-- =============================================
-- Author:		Hari 
-- Create date: 22 march 2019
-- Description:	Used to get comma seperated values --1=Homepage,2=IA Result,3=PI result
-- =============================================
 CREATE FUNCTION [dbo].[fnGetBlockMeasures]
(
   
@Tin VARCHAR(9),
@CategoryId int,
@CmsYear int
)
RETURNS @BlockMeasures Table(Mesures varchar(max),CmsYear int) -- or whatever length you need
AS
BEGIN
declare @Measure varchar(max)


select @Measure = COALESCE(@Measure + ',', '')+Bm.Measure   from tbl_lookup_block_submission B
                                                         Inner Join tbl_lookup_MeasureBlockList  Bm
														  on B.BlockId=Bm.BlockId and B.TIN=@Tin
														 and B.CMSYear=@CmsYear
														 and B.CategoryId=@CategoryId
														 and Bm.Measure is not null and Bm.Measure != ''

  

insert into @BlockMeasures
select @Measure,@CmsYear


RETURN 

END


