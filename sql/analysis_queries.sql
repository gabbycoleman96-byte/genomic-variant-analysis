-- =========================================
-- GENOMIC VARIANT ANALYSIS (SQL PIPELINE)
-- =========================================

-- -----------------------------------------
-- 1. RAW TABLE CREATION
-- -----------------------------------------

CREATE TABLE genomic_raw (
    chrom VARCHAR(20),
    pos INT,
    id TEXT,
    ref VARCHAR(10),
    alt VARCHAR(10),
    qual TEXT,
    filter TEXT,
    info TEXT,
    format TEXT,
    sample TEXT
);

-- -----------------------------------------
-- 2. BULK IMPORT (FAST LOAD)
-- -----------------------------------------

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/genomic_data_clean_ish.csv'
INTO TABLE genomic_raw
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- -----------------------------------------
-- 3. CREATE CLEAN TABLE
-- -----------------------------------------

CREATE TABLE genomic_clean AS
SELECT
    chrom AS chromosome,
    SUBSTRING_INDEX(sample, ':', 1) AS genotype
FROM genomic_raw
WHERE filter = 'PASS';

-- -----------------------------------------
-- 4. NORMALIZE GENOTYPES
-- -----------------------------------------

-- Replace phased format (e.g., 0|1 → 0/1)
UPDATE genomic_clean
SET genotype = REPLACE(genotype, '|', '/');

-- Normalize flipped heterozygous values (1/0 → 0/1)
UPDATE genomic_clean
SET genotype = '0/1'
WHERE genotype = '1/0';

-- Remove invalid or missing values
DELETE FROM genomic_clean
WHERE genotype IS NULL
   OR genotype = ''
   OR genotype = './.';

-- -----------------------------------------
-- 5. FILTER TO STANDARD CHROMOSOMES
-- -----------------------------------------

DELETE FROM genomic_clean
WHERE chromosome NOT REGEXP '^chr([1-9]|1[0-9]|2[0-2]|X|Y|M)$';

-- -----------------------------------------
-- 6. BASIC DISTRIBUTION ANALYSIS
-- -----------------------------------------

-- Variant count per chromosome
SELECT chromosome, COUNT(*) AS variant_count
FROM genomic_clean
GROUP BY chromosome
ORDER BY chromosome;

-- Genotype distribution
SELECT genotype, COUNT(*) AS count
FROM genomic_clean
GROUP BY genotype;

-- -----------------------------------------
-- 7. GENOTYPE BREAKDOWN BY CHROMOSOME
-- -----------------------------------------

SELECT chromosome,
       COUNT(*) AS total,
       SUM(CASE WHEN genotype = '0/1' THEN 1 ELSE 0 END) AS hetero,
       SUM(CASE WHEN genotype = '1/1' THEN 1 ELSE 0 END) AS homo,
       SUM(CASE WHEN genotype = '1/2' THEN 1 ELSE 0 END) AS multi
FROM genomic_clean
GROUP BY chromosome;

-- -----------------------------------------
-- 8. PERCENTAGE CALCULATIONS
-- -----------------------------------------

SELECT chromosome,
       COUNT(*) AS total,
       SUM(CASE WHEN genotype = '0/1' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS hetero_pct,
       SUM(CASE WHEN genotype = '1/1' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS homo_pct,
       SUM(CASE WHEN genotype = '1/2' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS multi_pct
FROM genomic_clean
GROUP BY chromosome;

-- -----------------------------------------
-- 9. CHROMOSOME SIZE TABLE (FOR NORMALIZATION)
-- -----------------------------------------

CREATE TABLE chromosome_sizes (
    chromosome VARCHAR(10),
    size_mb FLOAT
);

INSERT INTO chromosome_sizes VALUES
('chr1',248),('chr2',242),('chr3',198),('chr4',190),('chr5',181),
('chr6',171),('chr7',159),('chr8',146),('chr9',141),('chr10',135),
('chr11',135),('chr12',134),('chr13',115),('chr14',107),('chr15',102),
('chr16',90),('chr17',83),('chr18',80),('chr19',59),('chr20',64),
('chr21',47),('chr22',51),('chrX',156),('chrY',57),('chrM',0.016);

-- -----------------------------------------
-- 10. VARIANT DENSITY (PER Mb)
-- -----------------------------------------

SELECT g.chromosome,
       COUNT(*) AS variant_count,
       s.size_mb,
       COUNT(*) / s.size_mb AS variants_per_mb
FROM genomic_clean g
JOIN chromosome_sizes s ON g.chromosome = s.chromosome
GROUP BY g.chromosome, s.size_mb
ORDER BY variants_per_mb DESC;

-- -----------------------------------------
-- 11. FINAL ANALYSIS DATASET (FOR TABLEAU)
-- -----------------------------------------

CREATE OR REPLACE VIEW genomic_final AS
SELECT
    g.chromosome,
    COUNT(*) AS variant_count,
    s.size_mb,
    COUNT(*) / s.size_mb AS variants_per_mb,
    SUM(CASE WHEN g.genotype = '0/1' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS hetero_pct
FROM genomic_clean g
JOIN chromosome_sizes s
  ON g.chromosome = s.chromosome
GROUP BY g.chromosome, s.size_mb;

-- Preview final dataset
SELECT * FROM genomic_final;
