USE HOSPITALS;
-- Combine patient names and staff names into a single list.
SELECT name AS person_name, 'Patient' AS person_type
FROM patients
UNION  
SELECT staff_name AS person_name, 'Staff' AS person_type
FROM staff
ORDER BY person_name;

-- Create a union of high satisfaction patients (>90) and low satisfaction patients (<50).
SELECT 
    patient_id,
    name,
    service,
    satisfaction,
    'High Satisfaction' AS category
FROM patients
WHERE satisfaction > 90
UNION 
SELECT 
    patient_id,
    name,
    service,
    satisfaction,
    'Low Satisfaction' AS category
FROM patients
WHERE satisfaction < 50
ORDER BY satisfaction DESC;

-- List all unique names from both patients and staff tables.
SELECT name AS person_name
FROM patients
UNION    
SELECT staff_name AS person_name
FROM staff
ORDER BY person_name;

-- Create a comprehensive personnel and patient list showing: identifier (patient_id or staff_id), full name,
-- type ('Patient' or 'Staff'), and associated service. Include only those in 'surgery' or 'emergency' services.
 -- Order by type, then service, then name.
SELECT 
    p.patient_id AS identifier,
    p.name       AS full_name,
    'Patient'    AS type,
    p.service
FROM patients p
WHERE LOWER(p.service) IN ('surgery', 'emergency')
UNION ALL
SELECT
    s.staff_id   AS identifier,
    s.staff_name AS full_name,
    'Staff'      AS type,
    s.service
FROM staff s
WHERE LOWER(s.service) IN ('surgery', 'emergency')
ORDER BY type, service, full_name;
