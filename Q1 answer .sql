WITH field_flags AS (
  SELECT
    Country,
    RecordID,
    Datasource,
    Field,
    MatchStatusID,
    CASE WHEN MatchStatusID = 2 THEN 1 ELSE 0 END AS is_match,
    CASE WHEN MatchStatusID = 3 THEN 1 ELSE 0 END AS is_nomatch
  FROM `vibrant-sound-459613-a3.trulioo.Field_table `
),

per_ds AS (
  SELECT
    Country,
    RecordID,
    Datasource,
    CASE 
      WHEN SUM(CASE WHEN Field = 'FirstName' AND is_match = 1 THEN 1 ELSE 0 END) > 0
       AND SUM(CASE WHEN Field = 'LastName'  AND is_match = 1 THEN 1 ELSE 0 END) > 0
      THEN 1 ELSE 0
    END AS name_match,
    CASE 
      WHEN SUM(CASE WHEN Field = 'DayOfBirth'   AND is_match = 1 THEN 1 ELSE 0 END) > 0
       AND SUM(CASE WHEN Field = 'MonthOfBirth' AND is_match = 1 THEN 1 ELSE 0 END) > 0
       AND SUM(CASE WHEN Field = 'YearOfBirth'  AND is_match = 1 THEN 1 ELSE 0 END) > 0
      THEN 1 ELSE 0
    END AS dob_match,
    CASE 
      WHEN SUM(CASE WHEN Field = 'StreetName'   AND is_match = 1 THEN 1 ELSE 0 END) > 0
       AND SUM(CASE WHEN Field = 'HouseNumber'  AND is_match = 1 THEN 1 ELSE 0 END) > 0
       AND (
             SUM(CASE WHEN Field = 'PostalCode' AND is_match = 1 THEN 1 ELSE 0 END) > 0
          OR SUM(CASE WHEN Field = 'City'       AND is_match = 1 THEN 1 ELSE 0 END) > 0
       )
       AND SUM(CASE WHEN Field = 'UnitNumber' AND is_nomatch = 1 THEN 1 ELSE 0 END) = 0
      THEN 1 ELSE 0
    END AS address_match
  FROM field_flags
  GROUP BY
    Country,
    RecordID,
    Datasource
),

per_record AS (
  SELECT
    Country,
    RecordID,
    CASE
      WHEN SUM(
        CASE 
          WHEN name_match = 1
           AND (address_match = 1 OR dob_match = 1)
          THEN 1 ELSE 0
        END
      ) > 0
      THEN 1 ELSE 0
    END AS record_match_q1
  FROM per_ds
  GROUP BY
    Country,
    RecordID
),

joined AS (
  SELECT
    r.Country,
    r.RecordID,
    pr.record_match_q1
  FROM `vibrant-sound-459613-a3.trulioo.Record_table` r
  LEFT JOIN per_record pr
    ON r.Country = pr.Country
   AND r.RecordID = pr.RecordID
)

SELECT
  Country,
  COUNT(*) AS total_records,
  SUM(record_match_q1) AS matched_records_q1,
  SAFE_DIVIDE(SUM(record_match_q1), COUNT(*)) AS match_rate_q1
FROM joined
GROUP BY Country
ORDER BY Country;
