-- ===============================================================================
-- FILE 02: 02_data_cleaning.sql
-- Purpose: Execute Data Transformations, Deduplication, and Key Constraints
-- ===============================================================================

USE HealthcareDB;
GO

/* 1. REMOVE BLANK ROWS AND EXACT DUPLICATES */
DELETE FROM dbo.healthcare_staging
WHERE Patient_ID IS NULL AND Name IS NULL AND Age IS NULL AND Gender IS NULL 
  AND Blood_Type IS NULL AND Medical_Condition IS NULL AND Date_of_Admission IS NULL 
  AND Doctor IS NULL AND Hospital IS NULL AND Insurance_Provider IS NULL 
  AND Billing_Amount IS NULL AND Room_Number IS NULL AND Admission_Type IS NULL 
  AND Discharge_Date IS NULL AND Medication IS NULL AND Test_Results IS NULL;

WITH ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY Patient_ID, Name, Age, Gender, Blood_Type,
                         Medical_Condition, Date_of_Admission, Doctor,
                         Hospital, Insurance_Provider, Billing_Amount,
                         Room_Number, Admission_Type, Discharge_Date,
                         Medication, Test_Results
            ORDER BY (SELECT NULL)
        ) AS rn
    FROM dbo.healthcare_staging
)
DELETE FROM ranked WHERE rn > 1;
GO

/* 2. TRIM WHITESPACE */
UPDATE dbo.healthcare_staging
SET
    Patient_ID          = TRIM(Patient_ID),
    Name                = TRIM(Name),
    Age                 = TRIM(Age),
    Gender              = TRIM(Gender),
    Blood_Type          = TRIM(Blood_Type),
    Medical_Condition   = TRIM(Medical_Condition),
    Date_of_Admission   = TRIM(Date_of_Admission),
    Doctor              = TRIM(Doctor),
    Hospital            = TRIM(Hospital),
    Insurance_Provider  = TRIM(Insurance_Provider),
    Billing_Amount      = TRIM(Billing_Amount),
    Room_Number         = TRIM(Room_Number),
    Admission_Type      = TRIM(Admission_Type),
    Discharge_Date      = TRIM(Discharge_Date),
    Medication          = TRIM(Medication),
    Test_Results        = TRIM(Test_Results);
GO

/* 3. STANDARDIZE CATEGORY VALUES */
UPDATE dbo.healthcare_staging
SET Gender = CASE
    WHEN UPPER(Gender) IN ('M', 'MALE') THEN 'Male'
    WHEN UPPER(Gender) IN ('F', 'FEMALE') THEN 'Female'
    ELSE Gender
END;

UPDATE dbo.healthcare_staging
SET Blood_Type = UPPER(REPLACE(REPLACE(Blood_Type, ' Positive', '+'), ' Negative', '-'))
WHERE Blood_Type IS NOT NULL;

UPDATE dbo.healthcare_staging
SET Insurance_Provider = CASE
    WHEN UPPER(Insurance_Provider) = 'MEDICARE' THEN 'Medicare'
    WHEN Insurance_Provider IN ('BlueCross', 'Blue Cross Blue Shield') THEN 'Blue Cross'
    WHEN UPPER(Insurance_Provider) = 'AETNA' THEN 'Aetna'
    WHEN Insurance_Provider IN ('United Healthcare', 'UHC') THEN 'UnitedHealthcare'
    WHEN UPPER(Insurance_Provider) = 'CIGNA' THEN 'Cigna'
    ELSE Insurance_Provider
END;

UPDATE dbo.healthcare_staging
SET
    Medical_Condition = UPPER(LEFT(Medical_Condition,1)) + LOWER(SUBSTRING(Medical_Condition,2,LEN(Medical_Condition))),
    Admission_Type    = UPPER(LEFT(Admission_Type,1)) + LOWER(SUBSTRING(Admission_Type,2,LEN(Admission_Type))),
    Medication        = UPPER(LEFT(Medication,1)) + LOWER(SUBSTRING(Medication,2,LEN(Medication))),
    Test_Results      = UPPER(LEFT(Test_Results,1)) + LOWER(SUBSTRING(Test_Results,2,LEN(Test_Results)))
WHERE Medical_Condition IS NOT NULL OR Admission_Type IS NOT NULL 
   OR Medication IS NOT NULL OR Test_Results IS NOT NULL;
GO

/* 4. CLEAN NUMERICS (BILLING_AMOUNT AND AGE) */
UPDATE dbo.healthcare_staging
SET Billing_Amount = REPLACE(Billing_Amount, '$', '')
WHERE Billing_Amount LIKE '$%';

UPDATE dbo.healthcare_staging
SET Billing_Amount = CAST(ABS(TRY_CAST(Billing_Amount AS DECIMAL(12,2))) AS NVARCHAR(50))
WHERE TRY_CAST(Billing_Amount AS DECIMAL(12,2)) < 0;

UPDATE dbo.healthcare_staging
SET Billing_Amount = 'Unknown'
WHERE TRY_CAST(Billing_Amount AS DECIMAL(12,2)) > 100000;

UPDATE dbo.healthcare_staging
SET Age = NULL
WHERE TRY_CAST(Age AS INT) IS NOT NULL
  AND (TRY_CAST(Age AS INT) < 0 OR TRY_CAST(Age AS INT) > 120);
GO

/* 5. TITLE CASE FOR NAMES */
CREATE OR ALTER FUNCTION dbo.fn_TitleCase (@input NVARCHAR(200))
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @result NVARCHAR(200) = '';
    DECLARE @i INT = 1;
    DECLARE @len INT = LEN(@input);
    DECLARE @prevChar CHAR(1) = ' ';
    DECLARE @currChar CHAR(1);

    IF @input IS NULL RETURN NULL;

    WHILE @i <= @len
    BEGIN
        SET @currChar = SUBSTRING(@input, @i, 1);
        IF @prevChar = ' ' OR @prevChar = '.' OR @prevChar = '-'
            SET @result = @result + UPPER(@currChar);
        ELSE
            SET @result = @result + LOWER(@currChar);

        SET @prevChar = @currChar;
        SET @i = @i + 1;
    END

    RETURN @result;
END;
GO

UPDATE dbo.healthcare_staging SET Name = dbo.fn_TitleCase(Name) WHERE Name IS NOT NULL;
UPDATE dbo.healthcare_staging SET Doctor = dbo.fn_TitleCase(Doctor) WHERE Doctor IS NOT NULL;
UPDATE dbo.healthcare_staging SET Hospital = dbo.fn_TitleCase(Hospital) WHERE Hospital IS NOT NULL;
GO

/* 6. PARSE DATES */
ALTER TABLE dbo.healthcare_staging ADD Date_of_Admission_Clean DATE;
ALTER TABLE dbo.healthcare_staging ADD Discharge_Date_Clean DATE;
GO

UPDATE dbo.healthcare_staging
SET Date_of_Admission_Clean =
    CASE
        WHEN Date_of_Admission LIKE '____-__-__' THEN TRY_CONVERT(DATE, Date_of_Admission, 23)
        WHEN Date_of_Admission LIKE '__/__/____' THEN TRY_CONVERT(DATE, Date_of_Admission, 101)
        WHEN Date_of_Admission LIKE '__-__-____' THEN TRY_CONVERT(DATE, Date_of_Admission, 105)
        WHEN Date_of_Admission LIKE '____/__/__' THEN TRY_CONVERT(DATE, Date_of_Admission, 111)
        WHEN Date_of_Admission LIKE '_/__/____' OR Date_of_Admission LIKE '__/_/____' OR Date_of_Admission LIKE '_/_/____' THEN TRY_CONVERT(DATE, Date_of_Admission, 101)
        ELSE NULL
    END;

UPDATE dbo.healthcare_staging
SET Discharge_Date_Clean =
    CASE
        WHEN Discharge_Date LIKE '____-__-__' THEN TRY_CONVERT(DATE, Discharge_Date, 23)
        WHEN Discharge_Date LIKE '__/__/____' THEN TRY_CONVERT(DATE, Discharge_Date, 101)
        WHEN Discharge_Date LIKE '__-__-____' THEN TRY_CONVERT(DATE, Discharge_Date, 105)
        WHEN Discharge_Date LIKE '____/__/__' THEN TRY_CONVERT(DATE, Discharge_Date, 111)
        WHEN Discharge_Date LIKE '_/__/____' OR Discharge_Date LIKE '__/_/____' OR Discharge_Date LIKE '_/_/____' THEN TRY_CONVERT(DATE, Discharge_Date, 101)
        ELSE NULL
    END;
GO

ALTER TABLE dbo.healthcare_staging DROP COLUMN Date_of_Admission;
ALTER TABLE dbo.healthcare_staging DROP COLUMN Discharge_Date;
GO
EXEC sp_rename 'dbo.healthcare_staging.Date_of_Admission_Clean', 'Date_of_Admission', 'COLUMN';
EXEC sp_rename 'dbo.healthcare_staging.Discharge_Date_Clean', 'Discharge_Date', 'COLUMN';
GO

/* 7. FIX DUPLICATE IDS AND ENFORCE PRIMARY KEY */
ALTER TABLE dbo.healthcare_staging ADD RowTempID INT IDENTITY(1,1);
GO

WITH ranked AS (
    SELECT RowTempID, Patient_ID,
        ROW_NUMBER() OVER (PARTITION BY Patient_ID ORDER BY RowTempID) AS rn
    FROM dbo.healthcare_staging
),
to_rename AS (
    SELECT RowTempID, ROW_NUMBER() OVER (ORDER BY RowTempID) AS offset
    FROM ranked
    WHERE rn > 1
)
UPDATE s
SET s.Patient_ID = 'P' + RIGHT('00000' + CAST(1000 + t.offset AS VARCHAR(5)), 5)
FROM dbo.healthcare_staging s
JOIN to_rename t ON t.RowTempID = s.RowTempID;
GO

ALTER TABLE dbo.healthcare_staging DROP COLUMN RowTempID;
GO
ALTER TABLE dbo.healthcare_staging ALTER COLUMN Patient_ID NVARCHAR(50) NOT NULL;
GO
ALTER TABLE dbo.healthcare_staging ADD CONSTRAINT PK_healthcare_staging PRIMARY KEY (Patient_ID);
GO

/* 8. HANDLE REMAINING NULLS */
UPDATE dbo.healthcare_staging SET Name = 'Unknown' WHERE Name IS NULL;
UPDATE dbo.healthcare_staging SET Age = 'Unknown' WHERE Age IS NULL;
UPDATE dbo.healthcare_staging SET Gender = 'Unknown' WHERE Gender IS NULL;
UPDATE dbo.healthcare_staging SET Blood_Type = 'Unknown' WHERE Blood_Type IS NULL;
UPDATE dbo.healthcare_staging SET Medical_Condition = 'Unknown' WHERE Medical_Condition IS NULL;
UPDATE dbo.healthcare_staging SET Doctor = 'Unknown' WHERE Doctor IS NULL;
UPDATE dbo.healthcare_staging SET Hospital = 'Unknown' WHERE Hospital IS NULL;
UPDATE dbo.healthcare_staging SET Insurance_Provider = 'Unknown' WHERE Insurance_Provider IS NULL;
UPDATE dbo.healthcare_staging SET Billing_Amount = 'Unknown' WHERE Billing_Amount IS NULL;
UPDATE dbo.healthcare_staging SET Room_Number = 'Unknown' WHERE Room_Number IS NULL;
UPDATE dbo.healthcare_staging SET Admission_Type = 'Unknown' WHERE Admission_Type IS NULL;
UPDATE dbo.healthcare_staging SET Medication = 'Unknown' WHERE Medication IS NULL;
UPDATE dbo.healthcare_staging SET Test_Results = 'Unknown' WHERE Test_Results IS NULL;
GO

select * from dbo.healthcare_staging;