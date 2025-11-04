use  hospitals;

-- Find all patients who are older than 60 years.
SELECT * 
FROM PATIENTS
WHERE AGE>60;

-- Retrieve all staff members who work in the 'Emergency' service.
SELECT * 
FROM STAFF
WHERE SERVICE = 'emergency';

-- List all weeks where more than 100 patients requested admission in any service.
SELECT week as BUSY_WEEKS
FROM SERVICES_WEEKLY 
GROUP BY month, week
HAVING SUM(PATIENTS_REQUEST) > 100;

-- Find all patients admitted to 'Surgery' service with a satisfaction score below 70, 
-- showing their patient_id, name, age, and satisfaction score.

SELECT PATIENT_ID, NAME, AGE, SATISFACTION AS SATISFACTION_SCORE 
FROM PATIENTS 
WHERE SERVICE = 'surgery'
AND SATISFACTION <70;
