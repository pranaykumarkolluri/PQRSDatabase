


CREATE VIEW [dbo].[VW_NPI_MIPSSubmissionStatus]
AS
     SELECT DISTINCT
            p.NPI,
            CASE
                WHEN G.Physician_NPI IS NOT NULL
                THEN 'Yes'
                WHEN I.NPI IS NOT NULL
                THEN 'Yes'
                WHEN A.NPI IS NOT NULL
                THEN 'Yes'
                ELSE 'No'
            END AS 'SubmittedtoMIPS'
     FROM NRDR..PHYSICIAN_TIN_VW P
          LEFT JOIN tbl_Physician_Aggregation_Year G ON p.NPI = g.Physician_NPI COLLATE DATABASE_DEFAULT
                                                        AND G.CMS_Submission_Year = 2019
          LEFT JOIN tbl_IA_Users I ON P.NPI = I.NPI COLLATE DATABASE_DEFAULT
                                      AND I.CMSYear = 2019
          LEFT JOIN tbl_ACI_Users A ON P.NPI = A.NPI COLLATE DATABASE_DEFAULT
                                       AND A.CMSYear = 2019;



