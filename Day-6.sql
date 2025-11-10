USE HOSPITALS;

-- Count the number of patients by each service.

SELECT SERVICE,COUNT(PATIENT_ID) AS PATIENT_COUNT
FROM PATIENTS
GROUP BY SERVICE;

-- Calculate the average age of patients grouped by service.
SELECT SERVICE,ROUND(AVG(AGE),0) AS AVERAGE_PATIENT_AGE
FROM PATIENTS
GROUP BY SERVICE;

-- Find the total number of staff members per role.
SELECT ROLE,COUNT(STAFF_ID) AS STAFF_COUNT
FROM STAFF
GROUP BY ROLE;

-- For each hospital service, calculate the total number of patients admitted, total patients refused, 
-- and the admission rate (percentage of requests that were admitted). Order by admission rate descending.

SELECT SERVICE,
SUM(PATIENTS_ADMITTED) AS TOTAL_PATIENTS_ADMITTED,
SUM(PATIENTS_REFUSED) AS TOTAL_PATIENTS_REFUSED,
ROUND((SUM(PATIENTS_ADMITTED)/SUM(PATIENTS_REQUEST))*100,2) AS ADMISSION_RATE
FROM SERVICES_WEEKLY
GROUP BY SERVICE
ORDER BY ADMISSION_RATE DESC;

