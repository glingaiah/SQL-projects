-- DATA CLEANING

SELECT *
FROM layoffs;

-- steps: 
-- 1. Remove Duplicates
-- 2. Standardize the data
-- 3. Null Values or blank values
-- 4. Remove colums and rows that are not necessary

-- Staging, to create a table so we are not working with the raw data and cleaning from the raw data

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT 
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Step 1: Identify duplicates. -- do row_number, if row_num has 2 or above that means it has duplicates

SELECT *, 
ROW_NUMBER() OVER ( PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *, 
ROW_NUMBER() OVER ( PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num -- select all the colums in the data
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper'; -- to check if query worked

-- make a staging 2 database to delete the duplicates - right click layoff_staging > copy to clipboard > create statement > paste > add row_num INT

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL, 
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *, 
ROW_NUMBER() OVER ( PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num -- select all the colums in the data
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num >1;

DELETE -- to delete duplicates
FROM layoffs_staging2
WHERE row_num >1;

SELECT * -- checkign again
FROM layoffs_staging2;

-- Step2: Standardizing data ( spacing, naming, time series,

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company); -- spacing for company name

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

-- looking at industry and updating crytocurrency

SELECT DISTINCT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2 -- updating
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT * -- check again
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry
FROM layoffs_staging2;

-- looking at location

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

-- looking at country and fixing name United States

SELECT DISTINCT country -- checking
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT * 
FROM layoffs_staging2
WHERE country LIKE 'United States%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) -- trim the trailing '.' from country
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2 -- updating
SET country = 'United States'
WHERE country LIKE 'United States%';

-- changing date from text to time series

SELECT `date`, 
STR_TO_DATE(`date`,'%m/%d/%Y') -- helps to go from string (text) to date, capital Y stands for year in 4 characters
FROM layoffs_staging2;

UPDATE layoffs_staging2 -- updating date
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

SELECT date -- check again
FROM layoffs_staging2;

-- change date column from text int he actual staging database

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Step 3. WORKING WITH NULLS and blank values

-- total_laid_off column

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- industry

UPDATE layoffs_staging2 -- first setting industry to NULL where there are blanks
SET industry = NULL
WHERE industry = '';



SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

SELECT * -- checking Airbnb to see if there are others
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT * -- checking if in the table does it have one that is blank and not blank, if so populate the blank with not blank
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2 
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1 -- updating those that are null to the value on industry in table 2 
JOIN layoffs_staging2 t2 
	ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Bally's is still NULL but leave it because there is only 1 

SELECT * -- checking Ballys to see if there are others
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

-- Step4. Remove columns and rows that we dont need, based on what we are trying to do with the data in the future. in this case we cant do anything if total laid off and % laid off is not available

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;


SELECT * -- checking again
FROM layoffs_staging2;

-- Remove row_num column because we dont need that again

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;