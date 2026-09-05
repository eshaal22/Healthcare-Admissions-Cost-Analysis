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