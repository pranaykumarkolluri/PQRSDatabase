-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SpSaveBlockListData
	@UserId int,
	@MeasureBlackList_Type MeasureBlackList_Type readonly
AS
BEGIN

DECLARE @NewMeasureList table(
								[TIN] [varchar](9) NULL,
								[CMSYear] [int] NULL,
								[CategoryId] [int] NULL,
								[Measure] [varchar](50) NULL
							  )

	delete from tbl_lookup_MeasureBlockList where BlockId in
	(
	Select B.BlockId from tbl_lookup_block_submission B 
					inner join @MeasureBlackList_Type T ON B.CMSYear =T.CMSYear
														   AND B.CategoryId=T.CategoryId
														   AND B.TIN =T.TIN
    )
		Update B set B.Last_Modified_datetime=GETDATE() ,B.changedby=@UserId from tbl_lookup_block_submission B 
					inner join @MeasureBlackList_Type T ON B.CMSYear =T.CMSYear
														   AND B.CategoryId=T.CategoryId
														   AND B.TIN =T.TIN 
    insert into tbl_lookup_MeasureBlockList(BlockId,Measure)
	Select B.BlockId,T.Measure from tbl_lookup_block_submission B 
					inner join @MeasureBlackList_Type T ON B.CMSYear =T.CMSYear
														   AND B.CategoryId=T.CategoryId
														   AND B.TIN =T.TIN
INSERT INTO @NewMeasureList(Measure,CMSYear,CategoryId,TIN)
	Select T.Measure,T.CMSYear,T.CategoryId,t.TIN from @MeasureBlackList_Type T
	where not exists(select 1 from tbl_lookup_block_submission B 
															where  T.CMSYear=B.CMSYear 
															     AND T.CategoryId=B.CategoryId
																 AND T.TIN=B.TIN
															)
					
  	INSERT INTO [dbo].[tbl_lookup_block_submission]
           ([CMSYear]
           ,[TIN]
           ,[Measure_Num]
           ,[Is_Blocked]
           ,[Created_datetime]
         
           ,[CategoryId]
           ,[ChangedBy])
		   
		   select 
		   CMSYear,
		   TIN,
		   Measure,
		   1,
		   GETDATE(),
		   CategoryId
		   ,@UserId
		   from @NewMeasureList		
		   
		   insert into tbl_lookup_MeasureBlockList(BlockId,Measure)
		   Select distinct B.BlockId,b.Measure_Num from tbl_lookup_block_submission B 
					inner join @NewMeasureList T ON B.CMSYear =T.CMSYear
														   AND B.CategoryId=T.CategoryId
														   AND B.TIN =T.TIN										   
END
