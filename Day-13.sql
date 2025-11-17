USE HOSPITALS;

-- Join patients and staff based on their common service field (show patient and staff who work in same service).
SELECT P.PATIENT_ID,P.NAME,S.STAFF_ID,S.STAFF_NAME,P.SERVICE
FROM PATIENTS P
INNER JOIN STAFF S
ON P.SERVICE = S.SERVICE

-- Join services_weekly with staff to show weekly service data with staff information.
SELECT * 
FROM SERVICES_WEEKLY SW
INNER JOIN STAFF S
ON SW.SERVICE =S.SERVICE;

-- Create a report showing patient information along with staff assigned to their service.
SELECT *
FROM PATIENTS P
INNER JOIN STAFF S
ON P.SERVICE = S.SERVICE

-- Create a comprehensive report showing patient_id, patient name, age, service, and the total number of staff members available in their service.
-- Only include patients from services that have more than 5 staff members. Order by number of staff descending, then by patient name.

SELECT P.PATIENT_ID,P.NAME,P.AGE,P.SERVICE,COUNT(S.STAFF_ID) AS STAFF_IN_SERVICE
FROM PATIENTS P
INNER JOIN STAFF S
ON P.SERVICE = S.SERVICE
GROUP BY P.PATIENT_ID
HAVING STAFF_IN_SERVICE>5
ORDER BY STAFF_IN_SERVICE DESC, NAME;