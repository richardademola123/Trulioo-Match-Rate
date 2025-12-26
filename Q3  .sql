CASE 
  WHEN SUM(CASE WHEN Field = 'StreetName'   AND is_match = 1 THEN 1 ELSE 0 END) > 0
   AND SUM(CASE WHEN Field = 'HouseNumber'  AND is_match = 1 THEN 1 ELSE 0 END) > 0
   AND (
         SUM(CASE WHEN Field = 'PostalCode' AND is_match = 1 THEN 1 ELSE 0 END) > 0
      OR SUM(CASE WHEN Field = 'City'       AND is_match = 1 THEN 1 ELSE 0 END) > 0
      THEN 1 ELSE 0
   )
END AS address_match;
