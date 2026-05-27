# 🧬 Genomic Variant Analysis (SQL + Power BI)

End-to-end genomic data analysis project using SQL and Power BI to clean, normalize, analyze, and visualize large-scale variant data across human chromosomes.

This project evolved from an initial Excel-based exploration into a full SQL-driven analytical workflow after dataset size and performance limitations made spreadsheet processing impractical.

---

# 🚀 Project Highlights

- Processed and analyzed ~1.4 million genomic variant records
- Built a SQL-based data cleaning and normalization pipeline
- Aggregated chromosome-level genotype metrics and density statistics
- Compared genotype composition across chromosomes
- Visualized variant density and heterozygosity relationships using Power BI
- Debugged large-scale import, datatype, and normalization issues throughout development

---

# 📊 Key Questions Explored

- Which chromosomes contain the highest variant density?
- How do heterozygous and homozygous variant distributions differ across chromosomes?
- Do chromosomes with higher variant density also exhibit higher heterozygosity?
- Which chromosomes behave as statistical outliers?

---

# 🛠️ Tools Used

| Tool | Purpose |
|---|---|
| SQL (MySQL) | Data cleaning, transformation, aggregation |
| Power BI | Data visualization and exploratory analysis |
| Excel | Initial exploration and sampling |
| GitHub | Documentation and version control |

---

# 📁 Project Structure

```text
genomic-variant-analysis/
│
├── README.md
├── sql/
│   └── analysis_queries.sql
├── notes/
│   └── debugging_log.md
├── images/
│   ├── density_by_chromosome.png
│   ├── genotype_percentages.png
│   └── scatter_plot.png
```

---

# 🧹 Data Cleaning Workflow

The original dataset contained approximately 2.4 million genomic records with multiple chromosome naming conventions, alternative contigs, and mixed genotype formats.

Cleaning and normalization steps included:

- Filtering for passing variants
- Standardizing genotype formatting
- Aggregating alternative chromosome labels into standard chromosome groups
- Removing incomplete or malformed rows
- Building chromosome-level summary tables
- Creating normalized density and composition metrics

Final cleaned dataset size:
- ~1.4 million rows

---

# 📈 Visualization 1: Variant Density by Chromosome and Genotype

This visualization compares normalized variant density across chromosomes for:
- heterozygous variants
- homozygous variants
- multi-heterozygous variants

Key observations:
- chr13 exhibited unusually high homozygous density
- chr19 showed consistently high variant density
- multi-heterozygous variants remained relatively sparse across all chromosomes

<p align="center">
  <img src="images/density_by_chromosome.png" width="900">
</p>

---

# 📊 Visualization 2: Genotype Composition by Chromosome

This chart compares the proportional distribution of:
- heterozygous variants
- homozygous variants
- multi-heterozygous variants

Key observations:
- Most chromosomes showed relatively stable distributions
- chr13 displayed elevated homozygosity
- chrY behaved as a strong outlier with substantially lower heterozygosity

<p align="center">
  <img src="images/genotype_percentages.png" width="900">
</p>

---

# 🔍 Visualization 3: Variant Density vs Heterozygosity

Scatter plot comparing chromosome-level heterozygosity against chromosome size.

This analysis was used to identify:
- clustering behavior
- outlier chromosomes
- potential relationships between chromosome scale and variation patterns

<p align="center">
  <img src="images/scatter_plot.png" width="900">
</p>

---

# 🧠 Key Lessons Learned

- Large datasets require different workflows than spreadsheet-based analysis
- SQL schema design significantly impacts import performance and downstream calculations
- Mathematical correctness does not always guarantee analytical correctness
- Clear metric naming is critical when working with normalized data
- Iterative debugging and restructuring are essential parts of real-world analysis

---

# 🧪 Development Notes

See:
- `sql/analysis_queries.sql`
- `notes/debugging_log.md`

for the full SQL workflow, debugging process, and schema adjustments made throughout development.

---

# 🔄 Final Workflow

Raw Genomic Data  
→ SQL Cleaning & Normalization  
→ Aggregation & Metric Engineering  
→ Power BI Visualization  
→ Exploratory Analysis & Interpretation
