# SQL-Layoffs-Data-Cleaning-EDA
Cleaning and analyzing layoffs data using SQL from Alex The Analyst bootcamp
# 🧹 SQL Data Cleaning & EDA – Layoffs Dataset

## 📌 Overview
This project focuses on cleaning and exploring a dataset of tech layoffs using MySQL. It includes tasks like removing duplicates, fixing formatting, handling missing values, and analyzing layoff trends, and from there specify which company has the biggest layy_off throgh years.

## 🔧 Steps Taken:

### 1. Remove Duplicates
- Used `ROW_NUMBER()` window function inside a CTE
- Deleted rows with `row_num > 1`

### 2. Standardize Data
- Used `TRIM()` to remove unwanted spaces
- Removed trailing text from country names
- Converted `date` column from string to date format using `STR_TO_DATE()`
- Used `ALTER TABLE` to change data types

### 3. Handle Nulls
- Replaced blank cells with `NULL`
- Used `SELF JOIN` to populate missing industries
- Deleted rows with too many nulls

### 4. Remove Unwanted Columns
- Dropped helper columns like `row_num` using `ALTER TABLE`

### 5. Exploratory Data Analysis
- Top companies with most layoffs
- Layoffs by industry, location, year
- Rolling totals over time using window functions

## 📁 Dataset Source
- From [Alex The Analyst SQL Bootcamp]

## 💻 Tools Used:
- MySQL
