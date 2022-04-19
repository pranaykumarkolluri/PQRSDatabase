CREATE VIEW [dbo].[VW_NPI_CMSSubmissionStatus]
AS
     SELECT DISTINCT
            p.TIN,
            p.NPI,
            CASE
                WHEN g.Npi IS NOT NULL
                THEN 'Yes'
                ELSE 'No'
            END AS 'SubmittedtoCMS',
            c.Category_Name,
            G.CmsYear
     FROM NRDR..PHYSICIAN_TIN_VW P
          INNER JOIN tbl_CI_Source_UniqueKeys G ON p.TIN = g.Tin COLLATE DATABASE_DEFAULT
                                                   AND p.NPI = g.Npi COLLATE DATABASE_DEFAULT
                                                   AND g.Npi IS NOT NULL
                                                   AND g.IsMSetIdActive = 1  
          LEFT JOIN tbl_CI_lookup_Categories c ON g.Category_Id = c.Category_Id;
