# Healthcare Data Analysis - Milestone 1 (MP1)

## Problem Statement
Analyze patient admissions to understand how billing amounts and length of stay vary across medical conditions, admission types, hospitals, insurance providers, and patient groups, and identify patterns associated with higher healthcare utilization and cost.

## Project Workflow & File Structure
The project is structured into sequential phases managed through SQL Server (T-SQL):

File 01 (01_schema_and_checks.sql): Creates the staging table, bulk imports the messy CSV data, and runs initial checks for row counts, duplicates, data types, and value ranges.

File 02 (02_data_cleaning.sql): Cleans the data by removing duplicates, trimming spaces, fixing categorical spellings, handling negative numbers, formatting dates, and filling missing values.

File 03 (03_data_analysis.sql / Milestone 1 Report): Runs the 6 mentor-aligned analysis queries (SELECT, COUNT, SUM, AVG, GROUP BY, ORDER BY) to generate our final insights and numbers.

## Milestone 1 Analysis Queries & Key Findings
* **Total Volume & Revenue**: Evaluates total patient volume (1,000 patients) and overall billing revenue ($24,861,148.25).
* **Patients by Medical Condition**: Identifies Asthma as the leading condition with 136 admissions, followed by Hypertension (132) and Heart Disease (127).
* **Billing by Admission Type**: Shows that Urgent admissions generate the highest total revenue ($9.21M) and average billing amount ($29,626).
* **Top Hospitals by Patient Volume**: Identifies Ross LLC Hospital as the highest volume provider with 34 patient admissions.
* **Patient Distribution by Gender**: Demonstrates an almost even split between male (516) and female (484) patients.
* **Billing by Insurance Provider**: Highlights Humana as the leading insurance provider by total revenue ($3.81M).

## Tech Stack
* **Database Management System**: Microsoft SQL Server (SSMS)
* **Query Language**: T-SQL

## Project Team
* Maryam Asif (DC-376)
* Eshaal Atif (DC-256)
* Dua Fatima (DC-169)
