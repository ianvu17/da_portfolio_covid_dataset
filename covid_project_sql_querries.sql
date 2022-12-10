-- Checking the tables

SELECT * FROM `loyal-env-365109.portfolio_covid_data.covid_vacs` ORDER BY 3,4 LIMIT 1000;

SELECT * FROM `loyal-env-365109.portfolio_covid_data.covid_deaths` ORDER BY 3,4 LIMIT 1000;

-- Check Primary Key, Composite key
SELECT location, COUNT(*)
FROM `loyal-env-365109.portfolio_covid_data.covid_vacs`
GROUP BY location
HAVING COUNT(*)>1; -- Location can't be primary key - has multiple entries


SELECT location, date, COUNT(*)
FROM `loyal-env-365109.portfolio_covid_data.covid_vacs`
GROUP BY location, date
HAVING COUNT(*)>1; -- No results found -> location, date will be Composite Key


-- Select the data that we will work on

SELECT
  location, date, total_cases, new_cases, total_deaths, population
FROM 
  `loyal-env-365109.portfolio_covid_data.covid_deaths`
ORDER BY 1,2;

-- Total Cases vs Total Deaths
SELECT
  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate_by_cases
FROM 
  `loyal-env-365109.portfolio_covid_data.covid_deaths`
WHERE location = 'Vietnam'
ORDER BY 1,2;

-- Total cases vs Population

SELECT
  location, date, total_cases, population, (total_cases/population)*100 as infection_rate_by_population
FROM 
  `loyal-env-365109.portfolio_covid_data.covid_deaths`
ORDER BY 1,2;

-- Total death vs Population
SELECT
  location, date, total_deaths, population, (total_deaths/population)*100 as death_rate_by_population
FROM 
  `loyal-env-365109.portfolio_covid_data.covid_deaths`
ORDER BY 1,2;

--Countries with Highest infection_rate_by_population
SELECT
  location, MAX(total_cases) as max_total_cases, population, MAX((total_cases/population))*100 as infection_rate_by_population
FROM 
  `loyal-env-365109.portfolio_covid_data.covid_deaths`
GROUP BY location, population  
ORDER BY 4 DESC;

-- Countries with Highest death_date_by_population
SELECT
  location, MAX(total_deaths) as max_total_deaths, population, MAX((total_deaths/population))*100 as death_rate_by_population
FROM 
  `loyal-env-365109.portfolio_covid_data.covid_deaths`
GROUP BY location, population  
ORDER BY 2 DESC ,4 DESC;

-- As per results showing groups of countries like Asia, Europe, High Income v.v... - Showing group of countries in the data
SELECT location FROM `loyal-env-365109.portfolio_covid_data.covid_vacs` 
WHERE continent is NULL
GROUP BY location
LIMIT 1000;

-- To ensure correct and relevant data, add Where continent is not null
-- Showing top 10 country which has highest death rate by population
SELECT
  location, MAX(total_deaths) as max_total_deaths, population, MAX((total_deaths/population))*100 as death_rate_by_population
FROM 
  `loyal-env-365109.portfolio_covid_data.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC
LIMIT 10;

-- Highest death rate by group of country
SELECT
  location, MAX(total_deaths) as max_total_deaths, population, MAX((total_deaths/population))*100 as death_rate_by_population
FROM 
  `loyal-env-365109.portfolio_covid_data.covid_deaths`
WHERE continent IS NULL
GROUP BY location, population
ORDER BY 2 DESC, 4 DESC
LIMIT 10;


-- Global situtation per day
SELECT
  date, SUM(new_cases) as total_cases , SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as death_rate_by_cases_per_day
FROM
  `loyal-env-365109.portfolio_covid_data.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1;

-- To date total case vs total death
SELECT
  SUM(new_cases) as total_cases , SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as death_rate_by_cases
FROM
  `loyal-env-365109.portfolio_covid_data.covid_deaths`
WHERE continent IS NOT NULL
ORDER BY 1;

-------------------- Covid Vacs

SELECT *
FROM `loyal-env-365109.portfolio_covid_data.covid_vacs`;

-- Join tables deaths - vacs querry

SELECT *
FROM `loyal-env-365109.portfolio_covid_data.covid_deaths` a JOIN `loyal-env-365109.portfolio_covid_data.covid_vacs` b
ON a.location = b.location AND a.date = b.date
ORDER BY a.location, a.date;

-- Total population vs total vacs

SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations
FROM `loyal-env-365109.portfolio_covid_data.covid_deaths` a JOIN `loyal-env-365109.portfolio_covid_data.covid_vacs` b
ON a.location = b.location AND a.date = b.date
ORDER BY a.location, a.date;

-- First date of vacs
SELECT location, MIN(date) as start_vac_day
FROM(
SELECT a.location, a.date
FROM `loyal-env-365109.portfolio_covid_data.covid_deaths` a JOIN `loyal-env-365109.portfolio_covid_data.covid_vacs` b
ON a.location = b.location AND a.date = b.date
WHERE new_vaccinations IS NOT NULL AND a.continent IS NOT NULL
)
GROUP BY location
ORDER BY 1,2;

-- Rolling vacs count
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations, SUM(b.new_vaccinations) OVER (PARTITION BY a.location ORDER BY a.date) as total_vacs
FROM `loyal-env-365109.portfolio_covid_data.covid_deaths` a JOIN `loyal-env-365109.portfolio_covid_data.covid_vacs` b
ON a.location = b.location AND a.date = b.date
WHERE a.continent IS NOT NULL
ORDER BY a.location, a.date;

-- Use temp table for total_vacs using

WITH population_vs_vaccination
as(
  SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations, SUM(b.new_vaccinations) OVER (PARTITION BY a.location ORDER BY a.date) as total_vacs
  FROM `loyal-env-365109.portfolio_covid_data.covid_deaths` a JOIN `loyal-env-365109.portfolio_covid_data.covid_vacs` b
  ON a.location = b.location AND a.date = b.date
  WHERE a.continent IS NOT NULL
  ORDER BY a.location, a.date
)
SELECT location, date, total_vacs/population*100 as vac_rate FROM population_vs_vaccination;

-- Country with a highest vac_rate
WITH population_vs_vaccination
as(
  SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations, SUM(b.new_vaccinations) OVER (PARTITION BY a.location ORDER BY a.date) as total_vacs
  FROM `loyal-env-365109.portfolio_covid_data.covid_deaths` a JOIN `loyal-env-365109.portfolio_covid_data.covid_vacs` b
  ON a.location = b.location AND a.date = b.date
  WHERE a.continent IS NOT NULL
  ORDER BY a.location, a.date
)
SELECT location, MAX(total_vacs/population)*100 as vac_rate 
FROM population_vs_vaccination
GROUP BY location
ORDER BY 2 DESC;


-- Try with Temp Table
CREATE TABLE `loyal-env-365109.portfolio_covid_data.population_vs_vaccination` (
  continent STRING,
  location STRING,
  date date,
  population INT64,
  new_vaccinations INT64,
  total_vacs INT64
);

INSERT INTO `loyal-env-365109.portfolio_covid_data.population_vs_vaccination`
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations, SUM(b.new_vaccinations) OVER (PARTITION BY a.location ORDER BY a.date) as total_vacs
  FROM `loyal-env-365109.portfolio_covid_data.covid_deaths` a JOIN `loyal-env-365109.portfolio_covid_data.covid_vacs` b
  ON a.location = b.location AND a.date = b.date
  WHERE a.continent IS NOT NULL
  ORDER BY a.location, a.date;

SELECT location, MAX(total_vacs/population)*100 as vac_rate 
FROM population_vs_vaccination
GROUP BY location
ORDER BY 2 DESC;

-- CREATE VIEWS FOR DATA VIZ

CREATE VIEW `loyal-env-365109.portfolio_covid_data.highest_death_by_population` AS
-- Countries with Highest death_rate_by_population
SELECT
  location, MAX(total_deaths) as max_total_deaths, population, MAX((total_deaths/population))*100 as death_rate_by_population
FROM 
  `loyal-env-365109.portfolio_covid_data.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY location, population  
ORDER BY 2 DESC ,4 DESC;
