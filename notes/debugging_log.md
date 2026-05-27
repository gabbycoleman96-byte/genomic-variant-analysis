# Debugging & Development Notes

This project went through several iterations while transitioning from spreadsheet-based exploration into a full SQL + Power BI workflow for large-scale genomic analysis. The development process included a fair amount of debugging, schema redesign, metric restructuring, and workflow optimization — all of which ended up being useful learning experiences.

---

## Project Evolution

### Initial Workflow

The project originally started with Excel, using sampled subsets of the genomic dataset and simple aggregation analysis. Spreadsheet limitations became apparent pretty quickly due to dataset size, browser instability, performance bottlenecks, and row limitations. The workflow was then migrated into MySQL for scalable processing.

---

## Large Dataset Import Challenges

### Problem

The original dataset (~2.4M rows) produced repeated import failures during early MySQL setup attempts. Issues included import wizard performance bottlenecks, connection timeouts, datatype overflow errors, and inconsistent field lengths across genomic columns.

Examples:
```sql
Error Code: 1406 - Data too long for column
Error Code: 2013 - Lost connection to MySQL server during query
```

---

### Solution

The import pipeline went through several schema redesigns.

**Early Attempts**

Initial schemas used restrictive VARCHAR limits:
```sql
qual VARCHAR(10),
filter VARCHAR(10)
```

These failed due to unexpectedly long genomic metadata fields.

**Final Approach**

The final import schema expanded several columns to TEXT and increased VARCHAR limits substantially, then optimized import performance using `LOAD DATA INFILE`:

```sql
CREATE TABLE genomic_raw (
    chrom VARCHAR(250),
    pos INT,
    id TEXT,
    ref VARCHAR(250),
    alt VARCHAR(250),
    qual TEXT,
    filter TEXT,
    info TEXT,
    format TEXT,
    sample TEXT
);
```

---

### Performance Optimization

To stabilize imports and prevent disconnects, server settings were adjusted:

```sql
SET GLOBAL max_allowed_packet = 1073741824;
SET GLOBAL interactive_timeout = 28800;
SET GLOBAL wait_timeout = 28800;
SET GLOBAL net_write_timeout = 600;
SET GLOBAL net_read_timeout = 600;
```

Final import runtime: approximately 40 seconds for ~1.4M cleaned rows.

---

## Data Cleaning & Normalization

### Filtering Valid Variants

Only variants with `filter = 'PASS'` were retained for analysis. This reduced noise and excluded low-confidence genomic records.

---

### Genotype Extraction

Genotype values were embedded inside a larger sample field and required extraction:

```sql
SET geno_type = SUBSTR(sample, 1, 3);
```

---

### Genotype Normalization

Several genotype formatting inconsistencies came up during exploration, including phased notation (`0|1`) and flipped heterozygous notation (`1/0`). Normalization steps included:

```sql
UPDATE genomic_clean
SET genotype = REPLACE(genotype, '|', '/');
```

```sql
UPDATE genomic_clean
SET genotype = '0/1'
WHERE genotype = '1/0';
```

---

## Chromosome Standardization

### Problem

The raw dataset contained alternative assemblies, random contigs, scaffold variants, and non-standard chromosome labels — for example:
- `chr14_GL000225v1_random`
- `chr14_KI270722v1_random`

### Solution

Chromosome labels were simplified into standardized groups (chr1–chr22, chrX, chrY, chrM) through a series of iterative update queries:

```sql
UPDATE raw_genome
SET chromosome = REPLACE(chromosome, 'chr1_', 'chr1');
```

This was repeated for all chromosome variants. Unknown chromosomes (`chrUn`) were removed entirely.

---

## Aggregation & Metric Engineering

### Summary Table Construction

A dedicated chromosome-level analysis table was created to store genotype counts, percentages, density metrics, and normalized chromosome statistics. This represented a shift from row-level genomic analysis to chromosome-level analytical summaries.

---

### Early Aggregation Challenges

Several failed attempts came up while working through how to group by chromosome, calculate conditional counts, and update summary tables using aggregated subqueries.

Example failed attempts:

```sql
SELECT chromosome, COUNT(geno_type = '1/1')
FROM raw_genome
GROUP BY chromosome;
```

```sql
UPDATE analysis
SET hetero = (
    SELECT chromosome, COUNT(*)
    FROM raw_genome
    GROUP BY chromosome
);
```

These attempts were useful for clarifying aggregate behavior, conditional counting logic, and how subqueries work inside UPDATE statements.

---

## Percentage vs. Density Debugging

One of the larger analytical debugging phases involved sorting out the difference between:

| Metric Type | Purpose |
|---|---|
| Percentage Composition | Proportion of genotype categories |
| Density Metrics | Variants per megabase |
| Inverse Density / Sparsity | Megabases per variant |

### Problem

Several mathematically valid formulas produced misleading interpretations because of naming confusion. For example:

```sql
(size_Mb * 100.0) / hetero
```

```sql
hetero / size_Mb
```

```sql
hetero / total
```

These are syntactically valid but represent completely different analytical concepts.

### Key Realization

The debugging process made it clear that mathematical correctness does not guarantee analytical correctness. The final workflow separated metrics into percentage composition metrics and normalized density metrics, which resolved the confusion.

---

## Datatype Overflow Errors

### Problem

While working with inverse-density formulas, unusually large values appeared for sparse chromosomes like chrY, triggering:

```sql
Error Code: 1264 - Out of range value
```

The issue was that `DECIMAL(5,2)` could not store large sparsity metrics.

### Solution

Metric columns were expanded:

```sql
ALTER TABLE analysis
MODIFY percent_multi_hetero DECIMAL(10,4);
```

This allowed for larger calculated values, improved decimal precision, and more stable normalization analysis.

---

## Visualization & Interpretation

After SQL aggregation was complete, the project moved into Power BI for density comparisons, genotype composition analysis, scatter plot analysis, and outlier identification.

Major findings included:
- Elevated homozygous density on chr13
- Distinctive chrY composition patterns
- Relatively stable multi-heterozygous proportions across most chromosomes

---

## Key Lessons Learned

- Large datasets require fundamentally different workflows than spreadsheets
- SQL schema design strongly impacts import reliability and downstream performance
- Data normalization is essential before aggregation
- Aggregation logic often requires iterative debugging
- Clear metric naming prevents analytical misinterpretation
- Real-world analysis involves a lot of repeated restructuring and refinement

---

## Final Workflow

Raw Genomic Data  
→ SQL Import & Schema Design  
→ Cleaning & Normalization  
→ Chromosome Standardization  
→ Aggregation & Metric Engineering  
→ Power BI Visualization  
→ Exploratory Analysis & Interpretation
