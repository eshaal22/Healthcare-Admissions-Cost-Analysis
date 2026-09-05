-- ===============================================================================
-- FILE 01: 01_schema_and_checks.sql
-- Purpose: Create Staging Table, Import Data, and Run Initial Health Checks
-- ===============================================================================

USE HealthcareDB;
GO

/* 1. CREATE STAGING TABLE */
DROP TABLE IF EXISTS dbo.healthcare_staging;

CREATE TABLE dbo.healthcare_staging (
    Patient_ID          NVARCHAR(50)  NULL,
    Name                NVARCHAR(MAX) NULL,
    Age                 NVARCHAR(50)  NULL,
    Gender              NVARCHAR(50)  NULL,
    Blood_Type          NVARCHAR(50)  NULL,
    Medical_Condition   NVARCHAR(50)  NULL,
    Date_of_Admission   NVARCHAR(50)  NULL,
    Doctor              NVARCHAR(50)  NULL,
    Hospital            NVARCHAR(50)  NULL,
    Insurance_Provider  NVARCHAR(50)  NULL,
    Billing_Amount      NVARCHAR(50)  NULL,
    Room_Number         NVARCHAR(50)  NULL,
    Admission_Type      NVARCHAR(50)  NULL,
    Discharge_Date      NVARCHAR(50)  NULL,
    Medication          NVARCHAR(50)  NULL,
    Test_Results        NVARCHAR(50)  NULL
);
GO

/* 2. IMPORT THE MESSY CSV */
BULK INSERT dbo.healthcare_staging
FROM 'C:\Users\JUST BUY PC\Downloads\healthcare_dataset_messy.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

/* 3. INITIAL DATA CHECKS */
-- Basic Row Count
SELECT COUNT(*) AS Total_Staged_Rows FROM dbo.healthcare_staging;

-- Identify Exact Duplicates
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT CONCAT_WS('|',
        Patient_ID, Name, Age, Gender, Blood_Type, Medical_Condition,
        Date_of_Admission, Doctor, Hospital, Insurance_Provider,
        Billing_Amount, Room_Number, Admission_Type, Discharge_Date,
        Medication, Test_Results
    )) AS distinct_rows
FROM dbo.healthcare_staging;

-- Numeric Outliers Check
SELECT MIN(TRY_CAST(Age AS INT)) AS min_age, MAX(TRY_CAST(Age AS INT)) AS max_age
FROM dbo.healthcare_staging;

SELECT MIN(TRY_CAST(Billing_Amount AS DECIMAL(12,2))) AS min_billing,
       MAX(TRY_CAST(Billing_Amount AS DECIMAL(12,2))) AS max_billing
FROM dbo.healthcare_staging;

-- Categorical Spelling & Casing Check
SELECT DISTINCT Gender FROM dbo.healthcare_staging;
SELECT DISTINCT Blood_Type FROM dbo.healthcare_staging;
SELECT DISTINCT Insurance_Provider FROM dbo.healthcare_staging;
GO