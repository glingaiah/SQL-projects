-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

-- Working with total_laid_off and percentage_laid_off

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2; 

SELECT * -- companies that completely lost all their employees (percentage laid off of 1 = 100%)
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off) -- which companies laid off most amount of people
FROM layoffs_staging2
GROUP BY company
ORDER BY SUM(total_laid_off) DESC;

SELECT MIN(`date`), MAX(`date`) -- checking the date range of layoffs
FROM layoffs_staging2;

SELECT industry, SUM(total_laid_off) -- which industries got affected
FROM layoffs_staging2
GROUP BY industry
ORDER BY SUM(total_laid_off) DESC;

SELECT country, SUM(total_laid_off) -- which countries got affected
FROM layoffs_staging2
GROUP BY country
ORDER BY SUM(total_laid_off) DESC;

SELECT `date`, SUM(total_laid_off) -- most layoffs by date
FROM layoffs_staging2
GROUP BY `date`
ORDER BY `date` DESC;

SELECT YEAR(`date`), SUM(total_laid_off) -- most layoffs by year (use YEAR function)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY YEAR(`date`) DESC;

SELECT stage, SUM(total_laid_off) -- which stage of company they were high layoffs
FROM layoffs_staging2
GROUP BY stage
ORDER BY stage DESC;

SELECT company, AVG(percentage_laid_off) -- which companies laid off most percentage of people -- doesnt help us that much
FROM layoffs_staging2
GROUP BY company
ORDER BY SUM(percentage_laid_off) DESC;

-- Progression of layoffs or Rolling sum

-- Rolling total layoffs based on the month and year

SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off) -- to take only months and year (date column, start at position 1 and take 7 characters)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY `Month` ASC;

WITH Rolling_total AS
(
SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off) AS total_off -- Rolling total calculation using CTE
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY `Month` ASC
)
SELECT `Month`, total_off, SUM(total_off) OVER(ORDER BY `Month`) AS rolling_total
FROM Rolling_total;

-- Companies that laid off most people per year

SELECT company, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company
ORDER BY SUM(total_laid_off) DESC;

SELECT company, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC; -- 3 here is the 3rd column

-- Rank which year they laid off most employees (highest laid off should be ranked number 1)

WITH company_year AS -- using CTE
(
SELECT company, YEAR(`date`) AS Years, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), company_year_rank AS -- another CTE to filter on ranking to filter only top 5 per year
(
SELECT *, DENSE_RANK() OVER(PARTITION BY `Years` ORDER BY total_laid_off DESC) AS Ranking
FROM company_year
WHERE Years IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE Ranking <=5;





