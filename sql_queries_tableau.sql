-- Using these querry results to build a Tableau Portfolio Project at 
-- https://public.tableau.com/views/GlobalCovidSituation/Dashboard1?:language=en-US&:display_count=n&:origin=viz_share_link

-- Data start date - end date
SELECT
  MIN(date) as data_start_date, MAX(date) as data_to_date
FROM 
  `loyal-env-365109.portfolio_covid_data.covid_deaths`
WHERE continent IS NOT NULL;


--Showing number of countries
SELECT
  COUNT(DISTINCT location) as number_of_country
FROM 
  `loyal-env-365109.portfolio_covid_data.covid_deaths`
WHERE continent IS NOT NULL;


-- Total confirmed cases, deaths
SELECT
  SUM(new_cases) as total_confirmed_cases, SUM(new_deaths) as total_confirmed_deaths 
FROM
  `loyal-env-365109.portfolio_covid_data.covid_deaths`
WHERE continent IS NOT NULL;

--Total deaths by continent
SELECT
  location, (MAX(total_deaths)/MAX(total_cases))*100 as death_rate_by_cases
FROM 
  `loyal-env-365109.portfolio_covid_data.covid_deaths`
WHERE continent IS NULL AND location LIKE '%income'
GROUP BY location
ORDER BY 2;

-- Cases vs deaths by date per country
SELECT
  location, date, total_cases as confirmed_total_case, total_deaths
FROM 
  `loyal-env-365109.portfolio_covid_data.covid_deaths`
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Joint table
SELECT *
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
ORDER BY 2 ASC
LIMIT 10;


--Total dose
SELECT sum(b.new_vaccinations) total_dose
FROM `loyal-env-365109.portfolio_covid_data.covid_deaths` a JOIN `loyal-env-365109.portfolio_covid_data.covid_vacs` b
ON a.location = b.location AND a.date = b.date
WHERE a.continent IS NOT NULL;

-- Race for vac

WITH population_vs_vaccination
as(
  SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations, SUM(b.new_vaccinations) OVER (PARTITION BY a.location ORDER BY a.date) as total_vacs
  FROM `loyal-env-365109.portfolio_covid_data.covid_deaths` a JOIN `loyal-env-365109.portfolio_covid_data.covid_vacs` b
  ON a.location = b.location AND a.date = b.date
  WHERE a.continent IS NOT NULL
  ORDER BY a.location, a.date
)
SELECT location, MAX(total_vacs/population*100) as vac_rate FROM population_vs_vaccination
GROUP BY location
HAVING vac_rate < 100 and vac_rate > 0
ORDER BY 2 DESC;

-- Cases vs Population density
SELECT a.location, SUM(a.total_cases) as total_cases, b.population_density
FROM `loyal-env-365109.portfolio_covid_data.covid_deaths` a JOIN `loyal-env-365109.portfolio_covid_data.covid_vacs` b
ON a.location = b.location AND a.date = b.date
WHERE a.continent IS NOT NULL
GROUP BY location, population_density
ORDER BY 2 desc
LIMIT 25;
