USE HOSPITALS;
SELECT * FROM PATIENTS;
-- Categorise patients as 'High', 'Medium', or 'Low' satisfaction based on their scores.
SELECT PATIENT_ID, SATISFACTION AS SATISFACTION_SCORE,
CASE
    WHEN SATISFACTION >= 80 then 'HIGH'
	WHEN SATISFACTION < 80 AND SATISFACTION >= 50 then 'MEDIUM'
    ELSE 'LOW'
END AS SATISFACTION
FROM PATIENTS;

-- Label staff roles as 'Medical' or 'Support' based on role type.
SELECT STAFF_ID, STAFF_NAME, ROLE,
CASE
    WHEN ROLE ='doctor' OR ROLE = 'nurse' THEN 'medical'
    ELSE 'support'
END AS 'STAFF_TYPE'
FROM STAFF;

-- Create age groups for patients (0-18, 19-40, 41-65, 65+).

SELECT PATIENT_ID, NAME AS PATIENT_NAME, AGE,
CASE
    WHEN AGE >= 65 then 'Senior'
    WHEN AGE >= 41 AND AGE <65 then 'Young'
	WHEN AGE >= 19 AND AGE < 41 then 'Youth'
    ELSE 'Minor'
END AS CATEGORY
FROM PATIENTS;

-- Create a service performance report showing service name, total patients admitted, 
-- and a performance category based on the following: 
-- 'Excellent' if avg satisfaction >= 85, 'Good' if >= 75, 'Fair' if >= 65, otherwise 'Needs Improvement'.
-- Order by average satisfaction descending.

SELECT
  SERVICE,
  SUM(PATIENTS_ADMITTED) AS TOTAL_PATIENTS_ADMITTED,
  ROUND(AVG(PATIENT_SATISFACTION), 2) AS AVG_PATIENT_SATISFACTION,
  CASE
    WHEN AVG(PATIENT_SATISFACTION) >= 85 THEN 'Excellent'
    WHEN AVG(PATIENT_SATISFACTION) >= 75 THEN 'Good'
    WHEN AVG(PATIENT_SATISFACTION) >= 65 THEN 'Fair'
    ELSE 'Needs Improvement'
  END AS SERVICE_PERFORMANCE
FROM SERVICES_WEEKLY
GROUP BY SERVICE
ORDER BY AVG(PATIENT_SATISFACTION) DESC;
