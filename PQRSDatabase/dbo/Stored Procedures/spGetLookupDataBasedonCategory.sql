
-- =============================================
-- Author:		Pavan A
-- Create date: 01-Feb-2022
-- Description:	Get lookup Data based on table type
--======================================================
CREATE PROCEDURE [dbo].[spGetLookupDataBasedonCategory]
	-- Add the parameters for the stored procedure here

   @CMSYear int,
   @CategoryId int,
   @tbl_Measure_Type tbl_Measure_Type Readonly
AS
BEGIN
	IF(@CategoryId = 1)
	BEGIN
		select distinct
		M.CMSYear
		,M.Measure_Num
		,M.Measure_Title
		,M.Measure_Desc as Measure_Description
		,M.Age_Restriction_From as Age_From
		,M.Age_Restriction_To  as Age_To
		,M.Begin_Date as Begin_Date
		,M.End_Date as End_Date
		,CASE	WHEN M.Mandatory_Diagnos_Code = 1 THEN 'Y'
				WHEN  M.Mandatory_Diagnos_Code = 0 THEN 'N'
				ELSE '' END as [Mandatory_Diagnos_Code (Y/N)]
		,M.NQS_Domain_Code
		,'' As [Mark_Delete(Y/N)]
		 from tbl_Lookup_Measure M join @tbl_Measure_Type T on T.Measure_Num = M.Measure_num where CMSYear = @CMSYear
	END
	ELSE IF(@CategoryId = 2)
	BEGIN
		select distinct
			CMSYear
			,C.Measure_Num
			,Proc_code
			,Denominator_Exclusion as [Denominator_Exclusion (Y/N)]
			,Gender_Exclusion
			,Atleast_Condition_226
			,Proc_Criteria
			,IsMain_ProcCode as [IsMain_ProcCode (Y/N)]
			,'' As [Mark_Delete(Y/N)]
		from tbl_lookup_Denominator_Proc_Code C join @tbl_Measure_Type T on T.Measure_Num = C.Measure_num where CMSYear = @CMSYear
	END
	ELSE IF(@CategoryId = 3)
	BEGIN
		select distinct
			CMSYear
			,C.Measure_Num
			,Code
			,'' As [Mark_Delete(Y/N)]
		from tbl_Lookup_Denominator_Diag_Code C join @tbl_Measure_Type T on T.Measure_Num = C.Measure_num where CMSYear = @CMSYear
	END
	ELSE IF(@CategoryId = 4)
	BEGIN
		select distinct
			CMSYear
			,C.Measure_Num
			,Numerator_Code
			,Numerator_Code_Desc
			,Numerator_response_Value
			,Exclusion as [Exclusion (Y/N)]
			,Performance_met as [Performance_Met (Y/N/NA)]
			,Denominator_Exceptions as [Denominator_Exceptions (Y/N)]
			,Criteria
			,'' As [Mark_Delete(Y/N)]
		from tbl_lookup_Numerator_Code C join @tbl_Measure_Type T on T.Measure_Num = C.Measure_num where CMSYear = @CMSYear
	END
END


