-- =============================================
-- Author:		Hari J
-- Create date:30 May 2019
-- Description:	Used to get Exams count based on FileId
-- =============================================
CREATE PROCEDURE SPgetExamCountbyFileId
	@FileId int
AS
BEGIN
	select count(Exam_Id) from tbl_exam with(nolock) where [File_ID]=@FileId
END
