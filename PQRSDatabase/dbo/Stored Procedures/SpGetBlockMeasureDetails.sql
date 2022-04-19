-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpGetBlockMeasureDetails]
	-- Add the parameters for the stored procedure here
  @Tin varchar(9),
  @CmsYear int,
  @CategoryId int

AS
BEGIN

    IF (@CategoryId=1)
	BEGIN
	  ;WITH BLOCKMEASURES AS
	  (
	  SELECT L.Measure,B.CMSYear FROM tbl_lookup_block_submission B
											INNER JOIN 
                    tbl_lookup_MeasureBlockList L ON B.BlockId=L.BlockId AND B.CategoryId=@CategoryId and B.TIN=@Tin and B.CMSYear=@CmsYear
	  )
	   SELECT M.Measure_num AS Measure, Case when B.Measure is not null or B.Measure !='' then CONVERT(bit,1) else CONVERT(bit,0) end as isblocked,M.DisplayOrder as DisplayOrder
	   
							FROM tbl_Lookup_Measure M LEFT JOIN 
										  BLOCKMEASURES B ON M.CMSYear=B.CMSYear
															 --AND M.CMSYear=B.CMSYear
															 AND M.Measure_num=b.Measure

															 Where M.CMSYear=@CmsYear

															 order  by M.DisplayOrder asc
															
	         
	    
	END
	ELSE IF(@CategoryId=2)
	BEGIN
		  ;WITH BLOCKMEASURES AS
	  (
	  SELECT L.Measure,B.CMSYear FROM tbl_lookup_block_submission B
											INNER JOIN 
                    tbl_lookup_MeasureBlockList L ON B.BlockId=L.BlockId AND B.CategoryId=@CategoryId and B.TIN=@Tin and B.CMSYear=@CmsYear
	  )
	   SELECT M.ActivityID  AS Measure, Case when B.Measure is not null or B.Measure !='' then CONVERT(bit,1) else CONVERT(bit,0) end as isblocked,  CONVERT(int, M.ID) as DisplayOrder
	   
							FROM Tbl_IA_Data M LEFT JOIN 
										  BLOCKMEASURES B ON 
															M.ActivityID=b.Measure
															
													where M.CMSYear=@CmsYear
	    

	END
	ELSE IF(@CategoryId=3)
	BEGIN
	  ;WITH BLOCKMEASURES AS
	  (
	  SELECT L.Measure,B.CMSYear FROM tbl_lookup_block_submission B
											INNER JOIN 
                    tbl_lookup_MeasureBlockList L ON B.BlockId=L.BlockId AND B.CategoryId=@CategoryId and B.TIN=@Tin and B.CMSYear=@CmsYear
	  )
	   SELECT M.MeasureId AS Measure, Case when B.Measure is not null or B.Measure !='' then CONVERT(bit,1) else CONVERT(bit,0) end as isblocked, CONVERT(int, M.ACI_Mes_Id) as DisplayOrder
	   
							FROM tbl_Lookup_ACI_Data M LEFT JOIN 
										  BLOCKMEASURES B ON
															
															  M.MeasureId=b.Measure
															
	         	              where M.CMSYear=@CmsYear
	    

	END
END


