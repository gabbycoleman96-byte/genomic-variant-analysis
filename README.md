# 🧬 Genomic Variant Analysis (SQL + Tableau)

**End-to-end data analysis project using SQL and Tableau to explore variation patterns across chromosomes.**

## 📌 Overview
This project analyzes genomic variant data to explore how genetic variation differs across chromosomes. The focus is on comparing **variant density (per Mb)** with **heterozygosity rates**.

---

## 🚀 Highlights

- Processed and analyzed ~1.4M genomic records using SQL
- Built a raw → clean data pipeline (ETL)
- Calculated normalized metrics (variants per Mb)
- Identified relationships and outliers using visualization
- Created Tableau visualizations to communicate insights

---

## 📁 Project Structure

- `sql/analysis_queries.sql` → full SQL pipeline (data cleaning + analysis)
- `images/scatter_plot.png` → final visualization
- `README.md` → project overview and findings

---

## 🎯 Objective
To determine whether chromosomes with higher variant density also exhibit higher heterozygosity and identify patterns or anomalies.

---

## 🛠️ Tools Used
- SQL (MySQL)
- Tableau

---

## 🔧 Data Preparation
- Processed ~2.4M rows of genomic data
- Filtered to ~1.4M high-quality variants
- Built a raw → clean pipeline in SQL
- Extracted and normalized genotype data
- Removed non-standard chromosome entries

---

## 📊 Visualization

![Variant Density vs Heterozygosity](images/scatter_plot.png)

---

## 🔍 Key Findings

- Moderate positive relationship between variant density and heterozygosity
- Most chromosomes cluster within a consistent range
- Notable outliers:
  - **chrY** → low density, low heterozygosity
  - **chrM** → 0% heterozygosity (haploid inheritance)
  - **chr13** → high density, lower-than-expected heterozygosity

---

## 🧠 Key Takeaways
- Data normalization is critical for fair comparison
- Variant density and heterozygosity are related but not strongly dependent
- Outliers reveal structural or biological differences

---

## ⚙️ How to Reproduce

1. Import dataset using `LOAD DATA INFILE`
2. Run SQL queries in `/sql/analysis_queries.sql`
3. Connect Tableau to the resulting dataset
4. Recreate visualizations using calculated fields

---

## 📁 SQL Queries
See `/sql/analysis_queries.sql` for full query logic.
