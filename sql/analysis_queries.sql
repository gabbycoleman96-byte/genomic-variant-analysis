-- =========================================================
-- GENOMIC VARIANT ANALYSIS PROJECT
-- SQL Cleaning, Aggregation, and Metric Engineering Pipeline
-- =========================================================


-- =========================================================
-- DATABASE SETUP & DATA IMPORT
-- =========================================================

CREATE DATABASE genome_project_2;

USE genome_project_2;


-- Raw genomic variant table
CREATE TABLE raw_genome (
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


-- Import raw TSV dataset
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fullRawDNA.csv'
INTO TABLE raw_genome
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- =========================================================
-- DATA CLEANING & NORMALIZATION
-- =========================================================


-- Remove non-passing variants
DELETE
FROM raw_genome
WHERE filter <> 'PASS';


-- Extract genotype values from sample column
ALTER TABLE raw_genome
ADD geno_type VARCHAR(3);


UPDATE raw_genome
SET geno_type = SUBSTR(sample, 1, 3);


-- Create simplified chromosome labels
ALTER TABLE raw_genome
ADD chromosome VARCHAR(5);


UPDATE raw_genome
SET chromosome = SUBSTR(chrom, 1, 5);


-- Normalize chromosome naming conventions
-- Example:
-- chr1_GL000191v1_random → chr1
-- Repeat for additional chromosome variants as needed

UPDATE raw_genome
SET chromosome = REPLACE(chromosome, 'chr1_', 'chr1');


-- Remove unknown chromosome assignments
DELETE
FROM raw_genome
WHERE chromosome = 'chrUn';


-- Normalize genotype formatting
-- Replace phased format (0|1) with unphased format (0/1)

UPDATE raw_genome
SET geno_type = REPLACE(geno_type, '|', '/');


-- Normalize flipped heterozygous values
-- 1/0 → 0/1

UPDATE raw_genome
SET geno_type = REPLACE(geno_type, '1/0', '0/1');


-- =========================================================
-- AGGREGATION & METRIC ENGINEERING
-- =========================================================


-- Chromosome-level analysis table
CREATE TABLE analysis (
    chromosome VARCHAR(5),

    hetero INT,
    homo INT,
    multi_hetero INT,

    size_Mb INT,
    total INT,

    percent_hetero DECIMAL(10,4),
    percent_homo DECIMAL(10,4),
    percent_multi_hetero DECIMAL(10,4),

    density_hetero DECIMAL(10,4),
    density_homo DECIMAL(10,4),
    density_multi_hetero DECIMAL(10,4)
);


-- Insert standard chromosomes
INSERT INTO analysis (chromosome)
VALUES
('chr1'), ('chr2'), ('chr3'),
('chr4'), ('chr5'), ('chr6'),
('chr7'), ('chr8'), ('chr9'),
('chr10'), ('chr11'), ('chr12'),
('chr13'), ('chr14'), ('chr15'),
('chr16'), ('chr17'), ('chr18'),
('chr19'), ('chr20'), ('chr21'),
('chr22'), ('chrX'), ('chrY');


-- =========================================================
-- GENOTYPE COUNTS
-- =========================================================


-- Count heterozygous variants per chromosome
UPDATE analysis
SET hetero = (
    SELECT COUNT(*)
    FROM raw_genome
    WHERE geno_type = '0/1'
      AND chromosome = analysis.chromosome
    GROUP BY chromosome
);


-- Count homozygous variants per chromosome
UPDATE analysis
SET homo = (
    SELECT COUNT(*)
    FROM raw_genome
    WHERE geno_type = '1/1'
      AND chromosome = analysis.chromosome
    GROUP BY chromosome
);


-- Count multi-heterozygous variants per chromosome
UPDATE analysis
SET multi_hetero = (
    SELECT COUNT(*)
    FROM raw_genome
    WHERE geno_type = '1/2'
      AND chromosome = analysis.chromosome
    GROUP BY chromosome
);


-- Calculate total variants per chromosome
UPDATE analysis
SET total = hetero + homo + multi_hetero;


-- =========================================================
-- CHROMOSOME SIZE NORMALIZATION
-- =========================================================


-- Chromosome sizes in megabases (Mb)

UPDATE analysis SET size_Mb = 248 WHERE chromosome = 'chr1';
UPDATE analysis SET size_Mb = 242 WHERE chromosome = 'chr2';
UPDATE analysis SET size_Mb = 198 WHERE chromosome = 'chr3';
UPDATE analysis SET size_Mb = 190 WHERE chromosome = 'chr4';
UPDATE analysis SET size_Mb = 181 WHERE chromosome = 'chr5';
UPDATE analysis SET size_Mb = 171 WHERE chromosome = 'chr6';
UPDATE analysis SET size_Mb = 159 WHERE chromosome = 'chr7';
UPDATE analysis SET size_Mb = 146 WHERE chromosome = 'chr8';
UPDATE analysis SET size_Mb = 141 WHERE chromosome = 'chr9';
UPDATE analysis SET size_Mb = 135 WHERE chromosome = 'chr10';
UPDATE analysis SET size_Mb = 135 WHERE chromosome = 'chr11';
UPDATE analysis SET size_Mb = 134 WHERE chromosome = 'chr12';
UPDATE analysis SET size_Mb = 115 WHERE chromosome = 'chr13';
UPDATE analysis SET size_Mb = 107 WHERE chromosome = 'chr14';
UPDATE analysis SET size_Mb = 102 WHERE chromosome = 'chr15';
UPDATE analysis SET size_Mb = 90 WHERE chromosome = 'chr16';
UPDATE analysis SET size_Mb = 83 WHERE chromosome = 'chr17';
UPDATE analysis SET size_Mb = 80 WHERE chromosome = 'chr18';
UPDATE analysis SET size_Mb = 59 WHERE chromosome = 'chr19';
UPDATE analysis SET size_Mb = 64 WHERE chromosome = 'chr20';
UPDATE analysis SET size_Mb = 47 WHERE chromosome = 'chr21';
UPDATE analysis SET size_Mb = 51 WHERE chromosome = 'chr22';
UPDATE analysis SET size_Mb = 156 WHERE chromosome = 'chrX';
UPDATE analysis SET size_Mb = 57 WHERE chromosome = 'chrY';


-- =========================================================
-- PERCENTAGE METRICS
-- =========================================================


-- Percentage composition by genotype
-- Example:
-- 0.43 = 43%

UPDATE analysis
SET percent_hetero = hetero / total
WHERE total > 0;


UPDATE analysis
SET percent_homo = homo / total
WHERE total > 0;


UPDATE analysis
SET percent_multi_hetero = multi_hetero / total
WHERE total > 0;


-- =========================================================
-- DENSITY METRICS
-- =========================================================


-- Variant density per megabase
-- Example:
-- 202 = 202 variants per Mb

UPDATE analysis
SET density_hetero = hetero / size_Mb
WHERE size_Mb > 0;


UPDATE analysis
SET density_homo = homo / size_Mb
WHERE size_Mb > 0;


UPDATE analysis
SET density_multi_hetero = multi_hetero / size_Mb
WHERE size_Mb > 0;


-- =========================================================
-- FINAL EXPLORATORY ANALYSIS
-- =========================================================


-- View completed chromosome summary table
SELECT *
FROM analysis
ORDER BY chromosome;


-- Example exploratory queries


-- Chromosomes with highest heterozygous density
SELECT chromosome, density_hetero
FROM analysis
ORDER BY density_hetero DESC;


-- Chromosomes with highest homozygous percentage
SELECT chromosome, percent_homo
FROM analysis
ORDER BY percent_homo DESC;


-- Compare density vs heterozygosity
SELECT
    chromosome,
    density_hetero,
    percent_hetero
FROM analysis;
