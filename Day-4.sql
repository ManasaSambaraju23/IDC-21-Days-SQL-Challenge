USE hospitals;

-- Display the first 5 patients from the patients table

SELECT PATIENT_ID, NAME,AGE 
FROM PATIENTS
LIMIT 5;

-- Show patients 11-20 using OFFSET
SELECT PATIENT_ID, NAME,AGE 
FROM PATIENTS
LIMIT 10
OFFSET 10;

-- Get the 10 most recent patient admissions based on arrival_date
SELECT * 
FROM PATIENTS 
ORDER BY ARRIVAL_DATE DESC
LIMIT 10;

-- Find the 3rd to 7th highest patient satisfaction scores from the patients table, 
-- showing patient_id, name, service, and satisfaction. Display only these 5 records.

SELECT PATIENT_ID, NAME, SERVICE, SATISFACTION 
FROM PATIENTS
ORDER BY SATISFACTION DESC
LIMIT 7 OFFSET 2;