USE HOSPITALS;

-- Extract the year from all patient arrival dates.
SELECT  patient_id,
    year(arrival_date) AS ARRIVAL_YEAR
FROM PATIENTS;

-- Calculate the length of stay for each patient (departure_date - arrival_date).
SELECT 
    patient_id,
    arrival_date,
    departure_date,
    DATEDIFF(departure_date, arrival_date) AS length_of_stay
FROM patients;

-- Find all patients who arrived in a specific month.
SELECT PATIENT_ID,
MONTH(ARRIVAL_DATE) AS MONTH
FROM PATIENTS;

-- Calculate the average length of stay (in days) for each service, showing only services 
-- where the average stay is more than 7 days. Also show the count of patients and order by average stay descending.

SELECT 
SERVICE, 
ROUND(AVG(DATEDIFF(departure_date, arrival_date)),0) AS AVG_DAYS_OF_STAY,
COUNT(PATIENT_ID) AS PATIENT_COUNT
FROM PATIENTS 
GROUP BY SERVICE 
HAVING AVG_DAYS_OF_STAY>7
ORDER BY AVG_DAYS_OF_STAY DESC;