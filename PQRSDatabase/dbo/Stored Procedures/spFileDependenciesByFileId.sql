CREATE PROCEDURE [dbo].[spFileDependenciesByFileId]

@InFileid int

AS
BEGIN


declare @DependentFileIds table(FileId int,depid int)
declare @PhyNpi varchar(10);

declare @FileName varchar(256);


select @PhyNpi=NPI from tbl_PQRS_FILE_UPLOAD_HISTORY where ID=@InFileid

			if not exists( select 1 from tbl_MultipleFileUpload_History where FileId=@InFileid)
			Begin
			 
				  With DependentFileIds_CTE as
				  (
				     
					    select distinct p.ID from tbl_PQRS_FILE_UPLOAD_HISTORY P where (p.STATUS='Pending'  or p.STATUS='Queued')   and P.ID >  @InFileid 
					 and p.NPI=@PhyNpi --and p.NPI is not null
					 and p.ID not in (
										select distinct p.ID from tbl_PQRS_FILE_UPLOAD_HISTORY P inner join 
									    tbl_MultipleFileUpload_History M on P.ID=M.FileId and  (p.STATUS='Pending'  or p.STATUS='Queued') and P.ID  > @InFileid 
										-- and p.NPI is null
									    and m.NPI=@PhyNpi
									 )
					 union
				     select distinct p.ID from tbl_PQRS_FILE_UPLOAD_HISTORY P inner join 
					 tbl_MultipleFileUpload_History M on P.ID=M.FileId  and (p.STATUS='Pending'  or p.STATUS='Queued') and P.ID > @InFileid 
					 -- and p.NPI is null
					 and m.NPI=@PhyNpi
				  )
				insert into @DependentFileIds(FileId,depid)
				select distinct @InFileid,ID  from  DependentFileIds_CTE
			end
			else
			begin
					With FlleTIN_NPIS_CTE as
					(
					  select  Tin,npi from  tbl_MultipleFileUpload_History where FileId=@InFileid and (TIN is not null or TIN != '')
					),
					DependentFiles As
					(
					   select p.ID from  tbl_MultipleFileUpload_History M  
		   
					   inner join tbl_PQRS_FILE_UPLOAD_HISTORY P on M.FileId=P.ID and P.ID > @InFileid
					   inner join FlleTIN_NPIS_CTE F
		   
					   on M.TIN=F.TIN and M.NPI=F.NPI and p.ID > @InFileid 
					)
					insert into @DependentFileIds(FileId,depid)

					select distinct  @InFileid,ID from DependentFiles
			end



 delete from tbl_File_Dependencies where DepFileId=@InFileid
insert into tbl_File_Dependencies(DepFileId,FileId)
 select distinct * from  @DependentFileIds D

END

