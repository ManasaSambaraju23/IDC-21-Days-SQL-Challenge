USE HOSPITALS;

-- Convert all patient names to uppercase.
SELECT UPPER(NAME) AS PATIENT_NAME 
FROM PATIENTS;

-- Find the length of each staff member's name.

SELECT STAFF_NAME, LENGTH(STAFF_NAME) AS NAME_LENGTH 
FROM STAFF;

-- Concatenate staff_id and staff_name with a hyphen separator.
SELECT CONCAT(STAFF_ID, ' - ', STAFF_NAME) AS STAFF_INFO
FROM STAFF;

-- Create a patient summary that shows patient_id, full name in uppercase, service in lowercase, 
-- age category (if age >= 65 then 'Senior', if age >= 18 then 'Adult', else 'Minor'), and name length. 
-- Only show patients whose name length is greater than 10 characters.

SELECT PATIENT_ID, UPPER(NAME) AS PATIENT_NAME, LOWER(SERVICE) AS SERVICE,
CASE
    WHEN AGE >= 65 then 'Senior'
	WHEN AGE >= 18 AND AGE <65 then 'Adult'
    ELSE 'Minor'
END AS CATEGORY,
LENGTH(NAME) AS NAME_LENGTH
FROM PATIENTS 
WHERE LENGTH(NAME) >10;
      