-- =============================================
-- Author:		Raju G
-- Create date: 20 march,2018
-- Description:	getting facility tin related physician data
-- =============================================
CREATE PROCEDURE [dbo].[SPGetFacilityTinRelatedPhysicianDetails]
	-- Add the parameters for the stored procedure here
@Username VARCHAR(256),
@TIN      VARCHAR(9)
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.


             --IF OBJECT_ID('tempdb..#FacilityPhysicianNPISTINS') IS NOT NULL
             --    DROP TABLE #FacilityPhysicianNPISTINS;
             DECLARE @FacilityPhysicianNPISTINS TABLE
(first_name VARCHAR(256),
 last_name  VARCHAR(256),
 npi        VARCHAR(10),
 tin        VARCHAR(9)
 ,is_active bit, 
 deactivation_date datetime,
 is_enrolled bit
);
             DECLARE @Records VARCHAR(MAX);
             INSERT INTO @FacilityPhysicianNPISTINS
             EXEC sp_getFacilityPhysicianNPIsTINs
                  @Username,@TIN;
             DECLARE @TinRelatedRecords TABLE
(npi        VARCHAR(10),
 UserId     INT,
 UserName   VARCHAR(256),
 FirstName  VARCHAR(256),
 LastName   VARCHAR(256),
 Records    VARCHAR(MAX),
 Registered VARCHAR(10)
);
             INSERT INTO @TinRelatedRecords
(npi,
 UserId,
 UserName,
 FirstName,
 LastName,
 Records,
 Registered
)
                    SELECT LTRIM(RTRIM(F.npi)) AS npi,
                           ISNULL(U.UserID, 0) AS UserId,
                           CASE
                               WHEN U.UserName IS NOT NULL
                               THEN U.UserName
                               ELSE 'Not Registered'
                           END AS UserName,
                           ISNULL(U.FirstName, '') AS FirstName,
                           ISNULL(U.LastName, '') AS LastName,
                           dbo.fnGetCOALESCEByTinNpi(f.TIN, f.NPI,0,1) AS Records,
                           CASE
                               WHEN U.Attested IS NULL
                               THEN 'N/A'
                               WHEN U.Attested = 1
                               THEN 'True'
                               ELSE 'False'
                           END AS Registered
                    FROM @FacilityPhysicianNPISTINS F
                         LEFT JOIN tbl_Users U with(nolock) ON F.npi = U.NPI
                         LEFT JOIN tbl_Physian_Tin_Count P with(nolock)  ON P.TIN = @tin
                                                              AND F.npi = P.NPI
                    WHERE F.tin = @tin
                    ORDER BY P.CMS_Year DESC;
             IF NOT EXISTS
(
    SELECT 1
    FROM @TinRelatedRecords
)
                 BEGIN
                     INSERT INTO @TinRelatedRecords
(npi,
 UserId,
 UserName,
 FirstName,
 LastName,
 Records,
 Registered
)
VALUES
(''
 ,	--npi, 
 0
 ,	--UserId , 
 ''
 ,	--UserName , 
 ''
 ,	--FirstName , 
 ''
 ,	--LastName, 
 ''
 ,	--Records , 
 ''	--Registered 
);
                 END;
             SELECT T.npi,
                    T.UserId,
                    T.UserName,
                    T.FirstName,
                    T.LastName,
                    T.Records,
                    T.Registered
             FROM @TinRelatedRecords T
             GROUP BY T.npi,
                      T.FirstName,
                      T.LastName,
                      T.UserId,
                      T.Records,
									--T.UserId,
                      T.UserName,
                      T.Registered;
         END;

