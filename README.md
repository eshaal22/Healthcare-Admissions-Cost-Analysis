# Healthcare Admission And Business Cost Analysis

## Project Overview
This repository contains the comprehensive data analysis pipeline for our healthcare project, covering foundational data exploration (Milestone 1) and advanced SQL-driven operational insights (Milestone 2). The analysis tracks 1,000 patient records and billing revenue to evaluate hospital efficiency, stay durations, cost drivers, and financial risk profiles.

* **Project Team:** Maryam Asif (DC-376), Eshaal Atif (DC-256), Dua Fatima (DC-169)  
* **Program:** AuratTech Data & AI Fellowship (Data Analyst Track)

---

## Business Problem & Objectives
Healthcare billing costs and lengths of stay vary widely across conditions, hospitals, and patient groups, making cost drivers hard to pinpoint. Without clear visibility into these patterns, hospitals and insurers struggle to anticipate high-cost admissions. This project identifies medical, hospital, and patient-related factors associated with higher billing amounts and longer hospital stays.

---

## Key Analytical Questions
* Which medical conditions have the highest average and total billing amounts?
* How do billing amounts and length of stay vary across admission types?
* Which hospitals show higher average billing and longer stays?
* How do billing patterns vary across insurance providers and patient age groups?
* Is longer length of stay associated with higher billing amounts?

---

## Repository Structure & Architecture

### 1. Data Layer (`/data`)
* **Messy / Raw Data (`healthcare_staging`):** Original uncleaned single-table records capturing patient admissions with text-formatted `NVARCHAR` entries, currency symbols, negative values, and inconsistent string capitalization.
* **Cleaned Dataset:** Fully sanitized and standardized version of the 1,000 patient records where blank rows, exact duplicates, invalid ages, and date formatting anomalies have been resolved.

### 2. Documentation & Reports (`/docs`)
* **Milestone 1 (MP1) Report:** Documents foundational data exploration, initial schema inspections, and preliminary metrics.
* **Milestone 2 (MP2) Report:** Covers advanced SQL-driven operational insights, cross-segmentation analyses, and deeper financial risk profiling.
* **Comprehensive Project Report:** Final aggregated technical documentation synthesizing the complete healthcare admission and business cost analysis pipeline.

### 3. Presentation Artifacts (`/slides`)
* **Project Slides (`.pptx`):** Slide deck structured around the core business problem, objectives, analytical questions, key findings, and stakeholder recommendations.

### 4. SQL Code & Scripts (`/sql`)
* **Data Check & Validation Scripts:** Queries utilizing schema inspection and `TRY_CAST` to evaluate data types and identify anomalies.
* **Data Cleaning Queries:** Scripts implementing string manipulation functions (`TRIM`, `REPLACE`, `UPPER`, `LOWER`), deduplication (`ROW_NUMBER()`), and boundary validations.
* **Data Analysis & Aggregation Queries:** Advanced analytical scripts executing `GROUP BY`, `HAVING`, `SUM`, `AVG`, `CASE WHEN` conditional segmentation, window ranking functions, and `DATEDIFF` operations.

---

## Key Findings & Visualizations

### 1. Total Billing Distribution by Medical Condition
* **Insight:** Evaluated cumulative billing totals across conditions to identify primary financial drivers, with conditions like Hypertension and Asthma generating high cumulative totals.
* **Visual:**  
<img width="907" height="476" alt="WhatsApp Image 2026-09-10 at 20 01 42" src="https://github.com/user-attachments/assets/af5206cf-d402-4603-ae46-b3375ad07d72" />

### 2. Admission Type Cost Analysis
* **Insight:** Urgent admissions show the highest average billing ($29,626) and longest length of stay (15.1 days), making them a top priority segment for cost management.
* **Visual:**  
<img width="768" height="414" alt="Average Billing by Admission Type" src="https://github.com/user-attachments/assets/36de2fd4-83b6-4283-bec0-12cd672bc0eb" />

### 3. Hospital Length of Stay & Outliers
* **Insight:** Ross LLC Hospital admissions average 19.5 days (significantly higher than peer hospitals), while Davis Group Hospital records the highest average billing ($30,658) among top hospitals.
* **Visual:**  
<img width="770" height="416" alt="Hospital Length of Stay Outliers" src="https://github.com/user-attachments/assets/1c880a8a-9a63-4055-bc1c-f36b0257cd37" />

### 4. Billing Patterns Across Insurance Providers & Age Groups
* **Insight:** Analysis reveals that length of stay shows no meaningful correlation with billing amounts ($r = -0.01$), indicating costs are driven by condition type or procedures rather than duration alone. Cross-segmentation highlights specific payer variations.
* **Visual:**  
<img width="947" height="475" alt="Billing Patterns Across Insurance Providers Age Groups" src="https://github.com/user-attachments/assets/152d570c-8dd9-4119-8af4-fa369940d1ae" />

---

## Recommendations & Action Plan
* **Hospital Administrators:** Could pilot enhanced case management protocols for urgent admissions, as they show the highest cost and longest stays.
* **Finance & Cost-Analysis Teams:** Could investigate condition-specific and procedure-level cost drivers, given that length of stay alone does not explain billing variation.
* **Hospital Leadership:** Leadership at Ross LLC Hospital could review internal length-of-stay practices, while leadership at Davis Group Hospital could review billing practices given gaps versus peer hospitals.
* **Insurance & Finance Teams:** Could examine cost variations across insurance providers (such as Blue Cross and Cigna) to understand provider-specific impacts.
