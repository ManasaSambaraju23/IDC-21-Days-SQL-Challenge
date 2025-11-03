
USE hospitals;

-- 1. Patients Table
CREATE TABLE patients (
    patient_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    arrival_date DATE,
    departure_date DATE,
    service VARCHAR(50),
    satisfaction INT
);

-- 2. Services Weekly Table
CREATE TABLE services_weekly (
    week INT,
    month INT,
    service VARCHAR(50),
    available_beds INT,
    patients_request INT,
    patients_admitted INT,
    patients_refused INT,
    patient_satisfaction INT,
    staff_morale INT,
    event VARCHAR(100)
);

-- 3. Staff Table
CREATE TABLE staff (
    staff_id VARCHAR(50) PRIMARY KEY,
    staff_name VARCHAR(100),
    role VARCHAR(50),
    service VARCHAR(50)
);

-- 4. Staff Schedule Table
CREATE TABLE staff_schedule (
    week INT,
    staff_id VARCHAR(50),
    staff_name VARCHAR(100),
    role VARCHAR(50),
    service VARCHAR(50),
    present TINYINT(1),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

-- Retrieve all columns from the patients table
SELECT * FROM patients;

-- Select only the patient_id, name, and age columns from the patients table.
SELECT patient_id as id, name , age 
FROM patients;

-- Display the first 10 records from the services_weekly table.
SELECT *
FROM services_weekly 
LIMIT 10;

-- List all unique hospital services available in the hospital.
SELECT DISTINCT SERVICE AS HOSPITAL_SERVICES 
FROM SERVICES_WEEKLY;
