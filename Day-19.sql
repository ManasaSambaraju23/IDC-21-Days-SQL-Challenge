USE HOSPITALS;
-- Rank patients by satisfaction score within each service.
SELECT
    p.patient_id,
    p.name,
    p.service,
    p.satisfaction,
    RANK() OVER (
        PARTITION BY p.service
        ORDER BY p.satisfaction DESC
    ) AS satisfaction_rank
FROM patients p
ORDER BY p.service, satisfaction_rank;

-- Assign row numbers to staff ordered by their name.
SELECT
    s.staff_id,
    s.staff_name,
    s.service,
    ROW_NUMBER() OVER (
        ORDER BY s.staff_name
    ) AS row_num
FROM staff s
ORDER BY s.staff_name;

-- Rank services by total patients admitted.
SELECT
    s.service,
    s.total_admitted,
    RANK() OVER (
        ORDER BY s.total_admitted DESC
    ) AS admission_rank
FROM (
    SELECT 
        service,
        SUM(patients_admitted) AS total_admitted
    FROM services_weekly
    GROUP BY service
) AS s
ORDER BY admission_rank;

-- For each service, rank the weeks by patient satisfaction score (highest first).
-- Show service, week, patient_satisfaction, patients_admitted, and the rank. Include only the top 3 weeks per service.
SELECT
  service,
  week,
  patient_satisfaction,
  patients_admitted,
  week_rank
FROM (
  SELECT
    service,
    week,
    patient_satisfaction,
    patients_admitted,
    ROW_NUMBER() OVER (
      PARTITION BY service
      ORDER BY patient_satisfaction DESC
    ) AS week_rank
  FROM services_weekly
  WHERE patient_satisfaction IS NOT NULL
) t
WHERE week_rank <= 3
ORDER BY service, week_rank;
