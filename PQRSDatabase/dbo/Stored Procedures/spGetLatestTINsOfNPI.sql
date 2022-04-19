
CREATE PROCEDURE [dbo].[spGetLatestTINsOfNPI] 

	-- Add the parameters for the stored procedure here

    @strNPI VARCHAR(10) = ''

AS 

    BEGIN

        DECLARE @curNPI AS VARCHAR(10)

        DECLARE @curUserID AS INT

        DECLARE @TINS TABLE

            (

              Userid INT,

              NPI VARCHAR(10),

              TIN NVARCHAR(50),

              Registry NVARCHAR(50),

              TIN_Description NVARCHAR(256)

            )



  



        DECLARE CurNPIS CURSOR

            FOR SELECT  a.NPI,

                        a.Userid

                FROM    tbl_Users a

                WHERE   a.NPI = CASE ISNULL(@strNPI, '')

                                  WHEN '' THEN NPI

                                  ELSE @strNPI

                                END

                GROUP BY a.NPI,

                        a.UserID

                HAVING  a.UserID = ( SELECT MAX(UserID)

                                     FROM   tbl_Users

                                     WHERE  NPI = a.NPI

                                   )





        OPEN CurNPIS



        FETCH NEXT FROM CurNPIS INTO @curNPI, @curUserID



        WHILE @@FETCH_STATUS = 0 

            BEGIN



-- step #1 : Call NRDR and get latest information on  

                INSERT  @TINS

                        (

                          TIN,

                          Registry,

                          TIN_Description

                        )

                        EXEC nrdr..[sp_getTINNumbers] @curNPI, 'ALL'

  

                UPDATE  @TINS

                SET     NPI = @curNPI,

                        Userid = @curUserID

                WHERE   NPI IS NULL 



                FETCH NEXT FROM CurNPIS INTO @curNPI, @curUserID

            END 

        CLOSE CurNPIS ;

        DEALLOCATE CurNPIS ;





        INSERT  INTO [dbo].[tbl_Physician_TIN]

                (

                  [UserID],

                  [TIN],

                  [Facility_name],

                  [Created_Date],

                  [Created_By],

                  [Last_Mod_Date],

                  [Last_Mod_By],

                  [TIN_DESCRIPTION],

                  [REGISTRY_NAME]

                )

                SELECT  Userid,

                        LTRIM(RTRIM(ISNULL(TIN, ''))),

                        NULL,

                        GETDATE(),

                        0,

                        GETDATE(),

                        0,

                        TIN_Description,

                        Registry

                FROM    @TINS N

                WHERE   RTRIM(LTRIM(ISNULL(N.NPI, '')))

                        + RTRIM(LTRIM(ISNULL(N.TIN, ''))) NOT IN (

                        SELECT DISTINCT

                                ( RTRIM(LTRIM(ISNULL(U.NPI, '')))

                                  + RTRIM(LTRIM(ISNULL(T.TIN, ''))) )

                        FROM    tbl_Users U WITH ( NOLOCK )

                                INNER JOIN tbl_Physician_TIN T WITH ( NOLOCK ) ON T.UserID = U.UserID )







    END

