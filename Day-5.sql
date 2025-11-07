USE HOSPITALS;

-- Count the total number of patients in the hospital
SELECT COUNT(PATIENT_ID) AS PATIENT_COUNT
FROM PATIENTS;

-- Calculate the average satisfaction score of all patients

SELECT ROUND(AVG(SATISFACTION),2) AS AVG_SATISFACTION_SCORE
FROM PATIENTS;

-- Find the minimum and maximum age of patients
SELECT MIN(AGE) AS MINIMUM_AGE,
MAX(AGE) AS MAXIMUM_AGE
FROM PATIENTS;

-- Calculate the total number of patients admitted, total patients refused, and the average patient satisfaction 
-- across all services and weeks. Round the average satisfaction to 2 decimal places.

SELECT 
SUM(PATIENTS_ADMITTED) AS TOTAL_ADMISSIONS,
SUM(PATIENTS_REFUSED) AS TOTAL_REFUSED,
ROUND(AVG(PATIENT_SATISFACTION),2) AS AVG_PATIENT_SATISFACTION
FROM SERVICES_WEEKLY;

