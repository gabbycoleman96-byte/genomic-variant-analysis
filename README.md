# 🧬 Genomic Variant Analysis (SQL + Tableau)

## 📌 Overview
This project analyzes genomic variant data to explore how genetic variation differs across chromosomes. The focus is on comparing **variant density (per Mb)** with **heterozygosity rates**.

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

## 📁 SQL Queries
See `/sql/analysis_queries.sql` for full query logic.
