# 🧪 Debugging & Development Notes

This project evolved through multiple iterations while transitioning from spreadsheet-based exploration into a full SQL + Power BI workflow for large-scale genomic analysis.

The development process included substantial debugging, schema redesign, metric restructuring, and workflow optimization.

---

# 🚀 Project Evolution

## Initial Workflow
The project originally began using:
- Excel
- sampled subsets of the genomic dataset
- simple aggregation analysis

However, spreadsheet limitations quickly became apparent due to:
- dataset size
- browser instability
- performance bottlenecks
- row limitations

The workflow was then migrated into MySQL for scalable processing.

---

# 📦 Large Dataset Import Challenges

## Problem
The original dataset (~2.4M rows) produced repeated import failures during early MySQL setup attempts.

Observed issues included:
- import wizard performance bottlenecks
- connection timeouts
- datatype overflow errors
- inconsistent field lengths across genomic columns

Examples:
```sql
Error Code: 1406 - Data too long for column
Error Code: 2013 - Lost connection to MySQL server during query
```

---

## Solution

The import pipeline evolved through several schema redesigns:

### Early Attempts
Initial schemas used restrictive VARCHAR limits:
```sql
qual VARCHAR(10),
filter VARCHAR(10)
```

These failed due to unexpectedly long genomic metadata fields.

---

### Final Approach
The final import schema:
- expanded several columns to TEXT
- increased VARCHAR limits substantially
- optimized import performance using `LOAD DATA INFILE`

Example:
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

## Performance Optimization

To stabilize imports and prevent disconnects, server settings were adjusted:

```sql
SET GLOBAL max_allowed_packet = 1073741824;
SET GLOBAL interactive_timeout = 28800;
SET GLOBAL wait_timeout = 28800;
SET GLOBAL net_write_timeout = 600;
SET GLOBAL net_read_timeout = 600;
```

Final import runtime:
- ~40 seconds for ~1.4M cleaned rows

---

# 🧹 Data Cleaning & Normalization

## Filtering Valid Variants

Only variants with:
```sql
filter = 'PASS'
```

were retained for analysis.

This reduced noise and excluded low-confidence genomic records.

---

## Genotype Extraction

The genotype values were embedded inside a larger sample field and required extraction:

```sql
SET geno_type = SUBSTR(sample, 1, 3);
```

---

## Genotype Normalization

Several genotype formatting inconsistencies emerged during exploration.

Examples:
- phased notation (`0|1`)
- flipped heterozygous notation (`1/0`)

Normalization steps included:

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

# 🧬 Chromosome Standardization

## Problem

The raw dataset contained:
- alternative assemblies
- random contigs
- scaffold variants
- non-standard chromosome labels

Examples:
- `chr14_GL000225v1_random`
- `chr14_KI270722v1_random`

---

## Solution

Chromosome labels were simplified into standardized groups:
- chr1–chr22
- chrX
- chrY
- chrM

This process evolved iteratively through multiple update queries:

```sql
UPDATE raw_genome
SET chromosome = REPLACE(chromosome, 'chr1_', 'chr1');
```

Repeated for all chromosome variants.

Unknown chromosomes (`chrUn`) were removed entirely.

---

# 📊 Aggregation & Metric Engineering

## Summary Table Construction

A dedicated chromosome-level analysis table was created to store:
- genotype counts
- percentages
- density metrics
- normalized chromosome statistics

This represented a transition from:
- row-level genomic analysis
to:
- chromosome-level analytical summaries

---

## Early Aggregation Challenges

Several failed attempts occurred while learning how to:
- group by chromosome
- calculate conditional counts
- update summary tables using aggregated subqueries

Example failed attempts included:

```sql
SELECT chromosome, COUNT(geno_type = '1/1')
FROM raw_genome
GROUP BY chromosome;
```

and:

```sql
UPDATE analysis
SET hetero = (
    SELECT chromosome, COUNT(*)
    FROM raw_genome
    GROUP BY chromosome
);
```

These attempts helped clarify:
- aggregate behavior
- conditional counting logic
- subquery structure inside UPDATE statements

---

# 🧠 Percentage vs Density Debugging

One of the largest analytical debugging stages involved distinguishing between:

| Metric Type | Purpose |
|---|---|
| Percentage Composition | proportion of genotype categories |
| Density Metrics | variants per megabase |
| Inverse Density / Sparsity | megabases per variant |

---

## Problem

Several mathematically valid formulas produced misleading interpretations due to naming confusion.

Example formulas explored:

```sql
(size_Mb * 100.0) / hetero
```

```sql
hetero / size_Mb
```

```sql
hetero / total
```

Although syntactically valid, these formulas represented completely different analytical concepts.

---

## Key Realization

The debugging process revealed an important distinction:

> Mathematical correctness does not guarantee analytical correctness.

The final workflow separated metrics into:
- percentage composition metrics
- normalized density metrics

---

# ⚠️ Datatype Overflow Errors

## Problem

While experimenting with inverse-density formulas, unusually large values appeared for sparse chromosomes such as chrY.

This triggered:

```sql
Error Code: 1264 - Out of range value
```

because:
```sql
DECIMAL(5,2)
```

could not store large sparsity metrics.

---

## Solution

Metric columns were expanded:

```sql
ALTER TABLE analysis
MODIFY percent_multi_hetero DECIMAL(10,4);
```

This enabled:
- larger calculated values
- improved decimal precision
- more stable normalization analysis

---

# 📈 Visualization & Interpretation

After SQL aggregation was completed, the project transitioned into Power BI for:
- density comparisons
- genotype composition analysis
- scatter plot analysis
- outlier identification

Major findings included:
- elevated homozygous density on chr13
- distinctive chrY composition patterns
- relatively stable multi-heterozygous proportions across chromosomes

---

# 🧠 Key Lessons Learned

- Large datasets require fundamentally different workflows than spreadsheets
- SQL schema design strongly impacts import reliability and performance
- Data normalization is essential before aggregation
- Aggregation logic often requires iterative debugging
- Clear metric naming prevents analytical misinterpretation
- Real-world analysis involves repeated restructuring and refinement

---

# 🔄 Final Workflow

Raw Genomic Data  
→ SQL Import & Schema Design  
→ Cleaning & Normalization  
→ Chromosome Standardization  
→ Aggregation & Metric Engineering  
→ Power BI Visualization  
→ Exploratory Analysis & Interpretation
