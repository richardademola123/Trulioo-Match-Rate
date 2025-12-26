# Match Rate Analysis – BigQuery SQL Case Study

## Overview
This case study analyzes transaction match rates across multiple countries using BigQuery SQL.  
The objective is to calculate match rates under different rule definitions and evaluate how changes to specific matching criteria impact overall results.

The analysis follows the requirements provided in the assignment and does not go beyond the requested scope.

---

## Problem Statement
Using transaction-level and field-level match data, calculate:

1. **Q1** – The overall match rate per country using the baseline match rule  
2. **Q2** – The new match rate per country after changing the Name definition  
3. **Q3** – The new match rate per country after modifying the Address definition  

For Q2 and Q3, include the **change in match rate compared to Q1**.

---

## Data Model
Three tables are used in this analysis:

- **Record_table**  
  One row per transaction  
  - Country  
  - RecordID  
  - Verified  

- **Field_table**  
  Multiple rows per transaction and datasource  
  - Country  
  - RecordID  
  - Datasource  
  - Field  
  - MatchStatusID  

- **Duplicate_table**  
  Indicates duplicate transactions (not used in match-rate calculations)

**MatchStatusID values:**
- `2` = match  
- `3` = no match  
- Other values = missing  

---

## Match Logic

### Baseline Rule (Q1)
A transaction is considered a match if **at least one datasource** satisfies:

- **Name**: FirstName AND LastName match  
- **AND**  
- (**Address** OR **Date of Birth**) matches  

**Date of Birth**
- DayOfBirth AND MonthOfBirth AND YearOfBirth match  

**Address**
- StreetName AND HouseNumber match  
- AND (PostalCode OR City) match  
- AND UnitNumber is NOT a no-match  

---

### Name Change (Q2)
Same logic as Q1, except:

- **Name** is redefined as: FirstInitial AND LastName  

---

### Address Change (Q3)
Same logic as Q1, except:

- The UnitNumber “not no-match” requirement is removed from Address matching  

---

## Approach
All queries are written in BigQuery SQL using layered Common Table Expressions (CTEs):

1. Convert field-level MatchStatusID values into match/no-match flags  
2. Aggregate field-level data into datasource-level match indicators  
3. Determine record-level matches if any datasource satisfies the rule  
4. Aggregate results to the country level to compute match rates  
5. Compare updated match rates (Q2, Q3) against the Q1 baseline  
---

## Results
Final outputs are stored in the `/results` directory.

- **Q1**: Baseline match rate per country  
- **Q2**: Match rate after updating Name definition  
- **Q3**: Match rate after updating Address definition  

Comparison files show:
- Baseline match rate (Q1)
- Updated match rate (Q2 or Q3)
- Percentage-point change relative to Q1  

---

## Key Observations
- Match rate sensitivity varies by country.
- Changes to Name matching improved results in some regions while reducing them in others.
- Removing the UnitNumber constraint increased match rates where unit data was inconsistently provided.
- Some countries showed no change, indicating stable data quality under both rule definitions.

---

## Tools Used
- BigQuery SQL
- GitHub (documentation and version control)


