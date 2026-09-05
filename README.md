# Healthcare Data Analysis - Milestone 1 (MP1)

## Problem Statement
Analyze patient admissions to understand how billing amounts and length of stay vary across medical conditions, admission types, hospitals, insurance providers, and patient groups, and identify patterns associated with higher healthcare utilization and cost.

## Project Workflow & File Structure
The project is structured into sequential phases managed through SQL Server (T-SQL):

* **`01_schema_and_checks.sql`**: Creates the raw staging table (`healthcare_staging`), bulk imports the messy CSV dataset, and runs initial health checks including row counts, duplicate detection, and outlier identification using `TRY_CAST`.
* **`02_data_cleaning.sql`**: Cleans and standardizes the dataset by trimming whitespace, handling missing values, standardizing categorical values (Gender, Blood Type, Insurance Provider), cleaning numeric attributes, parsing dates, and enforcing primary key constraints.
* **`milestone_1final.docx`**: The finalized Milestone 1 report containing complete SQL scripts, query outputs, and analytical insights[cite: 1].

## Milestone 1 Analysis Queries & Key Findings
* **Total Volume & Revenue**: Evaluates total patient volume (1,000 patients) and overall billing revenue ($24,861,148.25)[cite: 1].
* **Patients by Medical Condition**: Identifies Asthma as the leading condition with 136 admissions, followed by Hypertension (132) and Heart Disease (127)[cite: 1].
* **Billing by Admission Type**: Shows that Urgent admissions generate the highest total revenue ($9.21M) and average billing amount ($29,626)[cite: 1].
* **Top Hospitals by Patient Volume**: Identifies Ross LLC Hospital as the highest volume provider with 34 patient admissions[cite: 1].
* **Patient Distribution by Gender**: Demonstrates an almost even split between male (516) and female (484) patients[cite: 1].
* **Billing by Insurance Provider**: Highlights Humana as the leading insurance provider by total revenue ($3.81M)[cite: 1].

## Tech Stack
* **Database Management System**: Microsoft SQL Server (SSMS)
* **Query Language**: T-SQL

## Project Team
* Maryam Asif (DC-376)
* Eshaal Atif (DC-256)
* Dua Fatima (DC-169)
