use HealthcareDB;

select * from healthcare_staging;
--Total Volume & Revenue: What is the total number of patients and the overall total billing amount generated across all records?
SELECT 
    COUNT(*) AS total_patients, 
    SUM(TRY_CAST(Billing_Amount AS DECIMAL(12,2))) AS total_billing_amount
FROM healthcare_staging;



--Patients by Medical Condition: Which medical conditions have the highest total number of patient admissions?
select 
    Medical_condition,
    count(*) as total_patients
from healthcare_staging
group by Medical_condition
order by total_patients desc;


--Billing by Admission Type: What are the total and average billing amounts for each admission type (Emergency, Elective, Urgent)?
Select 
    Admission_Type,
    SUM(TRY_CAST(Billing_Amount AS DECIMAL(12,2))) AS total_billing_amount,
    AVG(TRY_CAST(Billing_Amount AS DECIMAL(12,2))) AS average_billing_amount
from healthcare_staging
group by Admission_Type
order by total_billing_amount desc;


--Top Hospitals by Patient Volume: Which top 5 hospitals handle the largest number of patient admissions?
Select 
    TOP 5 Hospital,
    count(*) as total_patients
from healthcare_staging
group by hospital   
order  by total_patients desc;

--Patient Distribution by Gender: How is the total patient population distributed across different genders?
select 
Gender,
count(*) as total_patients
from healthcare_staging
group by gender;

--Billing by Insurance Provider: Which insurance providers handle the highest total billing revenue?
    select 
    insurance_provider,
    sum(TRY_CAST(Billing_Amount AS DECIMAL(12,2))) as total_billing_amount
    from healthcare_staging
    group by insurance_provider
    order by total_billing_amount desc ;


-- ============================================================================
-- MILESTONE 2 (MP2): FINALIZED SQL ANALYSIS SCRIPT (T-SQL / SQL Server)
-- ============================================================================

--Which medical conditions cost the most money per day in the hospital?
SELECT 
    medical_condition,
    COUNT(*) AS num_admissions,
    ROUND(AVG(CAST(DATEDIFF(day, Date_of_Admission, Discharge_Date) AS FLOAT)), 0) AS avg_length_of_stay,
    AVG(TRY_CAST(Billing_Amount AS FLOAT) / NULLIF(CAST(DATEDIFF(day, Date_of_Admission, Discharge_Date) AS INT), 0)) AS avg_cost_per_day
FROM healthcare_staging
GROUP BY medical_condition
ORDER BY avg_cost_per_day DESC;

--What percentage of patients stay for a short time versus a long time, and how does their total bill change?
SELECT
    CASE 
        WHEN DATEDIFF(day, Date_of_Admission, Discharge_Date) <= 3 THEN 'Short Stay (0-3 days)'
        WHEN DATEDIFF(day, Date_of_Admission, Discharge_Date) BETWEEN 4 AND 7 THEN 'Medium Stay (4-7 days)'
        ELSE 'Long Stay (8+ days)'
    END AS Stay_Category,
    COUNT(*) AS total_patients,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS percentage_of_patients,
    ROUND(AVG(TRY_CAST(Billing_Amount AS FLOAT)), 2) AS avg_billing
FROM healthcare_staging
GROUP BY 
    CASE 
        WHEN DATEDIFF(day, Date_of_Admission, Discharge_Date) <= 3 THEN 'Short Stay (0-3 days)'
        WHEN DATEDIFF(day, Date_of_Admission, Discharge_Date) BETWEEN 4 AND 7 THEN 'Medium Stay (4-7 days)'
        ELSE 'Long Stay (8+ days)'
    END
ORDER BY avg_billing DESC;


-- 3. Which hospitals charge way more (or way less) than the normal hospital average after factoring in stay lengths?
   WITH hospital_stats AS (
    SELECT
        Hospital,
        COUNT(*) AS patient_volume,
        AVG(TRY_CAST(Billing_Amount AS FLOAT) / NULLIF(CAST(DATEDIFF(day, Date_of_Admission, Discharge_Date) AS FLOAT), 0)) AS avg_daily_billing
    FROM healthcare_staging
    WHERE Hospital IS NOT NULL AND Discharge_Date >= Date_of_Admission
    GROUP BY Hospital
),
overall_stats AS (
    SELECT AVG(TRY_CAST(Billing_Amount AS FLOAT) / NULLIF(CAST(DATEDIFF(day, Date_of_Admission, Discharge_Date) AS FLOAT), 0)) AS overall_avg
    FROM healthcare_staging
)
SELECT
    h.Hospital,
    h.patient_volume,
    ROUND(h.avg_daily_billing, 2) AS avg_daily_billing,
    CASE
        WHEN h.avg_daily_billing > o.overall_avg * 1.2 THEN 'Unusually High'
        WHEN h.avg_daily_billing < o.overall_avg * 0.8 THEN 'Unusually Low'
        ELSE 'Normal Range'
    END AS billing_flag
FROM hospital_stats h
CROSS JOIN overall_stats o
ORDER BY avg_daily_billing DESC;

-- 4. Which specific doctor and hospital combinations bring in the highest total revenue?
SELECT TOP 10
    h1.Hospital,
    h1.Doctor,
    COUNT(h1.Patient_ID) AS total_patients,
    ROUND(SUM(TRY_CAST(h1.Billing_Amount AS FLOAT)), 2) AS total_revenue
FROM healthcare_staging h1
INNER JOIN healthcare_staging h2 
    ON h1.Hospital = h2.Hospital 
    AND h1.Doctor = h2.Doctor
GROUP BY h1.Hospital, h1.Doctor
ORDER BY total_revenue DESC;


--5.Which insurance providers have patient bills that are higher than the overall hospital average?
WITH OverallAverage AS (
    SELECT AVG(TRY_CAST(Billing_Amount AS FLOAT)) AS system_avg_billing
    FROM healthcare_staging
)
SELECT 
    i.Insurance_Provider,
    COUNT(*) AS total_patients,
    ROUND(AVG(TRY_CAST(i.Billing_Amount AS FLOAT)), 2) AS provider_avg_billing,
    CASE 
        WHEN AVG(TRY_CAST(i.Billing_Amount AS FLOAT)) > o.system_avg_billing THEN 'Above Average Cost'
        ELSE 'Below Average Cost'
    END AS cost_comparison_flag
FROM healthcare_staging i
CROSS JOIN OverallAverage o
WHERE i.Insurance_Provider IS NOT NULL
GROUP BY i.Insurance_Provider, o.system_avg_billing
ORDER BY provider_avg_billing DESC;

--6.How do hospital billing averages compare against the network average when we look at how patients were admitted (Emergency, Urgent, or Elective)?
WITH hospital_admission_stats AS (
    SELECT
        Hospital,
        Admission_Type,
        COUNT(*) AS total_patients,
        ROUND(AVG(TRY_CAST(Billing_Amount AS FLOAT)), 2) AS avg_billing
    FROM healthcare_staging
    WHERE Hospital IS NOT NULL AND Admission_Type IS NOT NULL
    GROUP BY Hospital, Admission_Type
),
network_benchmark AS (
    SELECT
        Admission_Type,
        ROUND(AVG(TRY_CAST(Billing_Amount AS FLOAT)), 2) AS network_avg_billing
    FROM healthcare_staging
    WHERE Admission_Type IS NOT NULL
    GROUP BY Admission_Type
)
SELECT
    has.Hospital,
    has.Admission_Type,
    has.total_patients,
    has.avg_billing,
    nb.network_avg_billing,
    CASE
        WHEN has.avg_billing > nb.network_avg_billing THEN 'Above Network Average'
        ELSE 'Below Network Average'
    END AS Efficiency_Status
FROM hospital_admission_stats has
JOIN network_benchmark nb ON has.Admission_Type = nb.Admission_Type
ORDER BY has.Admission_Type, has.avg_billing DESC;