USE HOSPITALS;

-- Calculate running total of patients admitted by week for each service.
SELECT
    service,
    week,
    patients_admitted,
    SUM(patients_admitted) OVER (
        PARTITION BY service
        ORDER BY week
    ) AS running_total_admitted
FROM services_weekly
ORDER BY service, week;

-- Find the moving average of patient satisfaction over 4-week periods.
SELECT
  service,
  week,
  patient_satisfaction,
  CASE
    WHEN COUNT(patient_satisfaction) OVER (
           PARTITION BY service
           ORDER BY week
           ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
         ) = 4
    THEN ROUND(
           AVG(patient_satisfaction) OVER (
             PARTITION BY service
             ORDER BY week
             ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
           ), 2
         )
    ELSE NULL
  END AS movavg_4wk
FROM services_weekly
ORDER BY service, week;

-- Show cumulative patient refusals by week across all services.
SELECT
    week,
    weekly_refused,
    SUM(weekly_refused) OVER (
        ORDER BY week
    ) AS cumulative_refused
FROM (
    SELECT 
        week,
        SUM(patients_refused) AS weekly_refused
    FROM services_weekly
    GROUP BY week
) AS w
ORDER BY week;

-- Create a trend analysis showing for each service and week: week number, patients_admitted,
-- running total of patients admitted (cumulative), 3-week moving average of patient satisfaction 
-- (current week and 2 prior weeks), and the difference between current week admissions and the service average. 
-- Filter for weeks 10-20 only.

SELECT
  service,
  week,
  patients_admitted,
  SUM(patients_admitted) OVER (
    PARTITION BY service
    ORDER BY week
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_total_admitted,
  CASE
    WHEN COUNT(patient_satisfaction) OVER (
           PARTITION BY service
           ORDER BY week
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
         ) = 3
    THEN ROUND(
           AVG(patient_satisfaction) OVER (
             PARTITION BY service
             ORDER BY week
             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
           ), 2
         )
    ELSE NULL
  END AS movavg_3wk_satisfaction,
  ROUND(
    patients_admitted
    - AVG(patients_admitted) OVER (PARTITION BY service),
    2
  ) AS diff_from_service_avg

FROM services_weekly
WHERE week BETWEEN 10 AND 20
ORDER BY service, week;

