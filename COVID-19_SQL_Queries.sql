-- Looking at total cases vs. population
-- Shows what percentage of population got COVID
-- Excludes null total_deaths entries

SELECT location, date, total_cases, population, total_deaths, (total_cases/population)*100 AS contraction_percentage
FROM [Portfolio Project].dbo.COVID_Deaths
WHERE location LIKE '%states%' AND total_deaths IS NOT NULL
ORDER BY 1,2;


-- Looking at countries with the highest infection rate

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 AS max_contraction_percentage
FROM [Portfolio Project].dbo.COVID_Deaths
WHERE total_deaths IS NOT NULL
GROUP BY location, population
ORDER BY max_contraction_percentage DESC;


-- Showing the countries with the highest death count

SELECT location, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM [Portfolio Project].dbo.COVID_Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;


-- Let's group by continent and order by highest death count

SELECT continent, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM [Portfolio Project].dbo.COVID_Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;


-- GLOBAL DEATH RATE

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM [Portfolio Project].dbo.COVID_Deaths
ORDER BY total_cases, total_deaths;


-- JOINING THE DEATH AND VACCINATION DATA

SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations AS bigint)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS total_vaccinations_rolling
FROM [Portfolio Project].dbo.COVID_Deaths Deaths
JOIN [Portfolio Project].dbo.COVID_Vaccinations Vac
	ON Deaths.location = Vac.location
	AND Deaths.date = Vac.date
WHERE Deaths.continent IS NOT NULL
AND Vac.new_vaccinations IS NOT NULL
ORDER BY 2,3


-- Using a CTE
-- CTE = Common Table Expression
-- CTEs work as virtual tables, (with records and columns), created during the execution of a query, used by the query, and eliminated after query execution.

WITH Pop_Vs_Vac (continent, location, date, population, new_vaccinations, total_vaccinations_rolling)
AS
(
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations AS bigint)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS total_vaccinations_rolling
FROM [Portfolio Project].dbo.COVID_Deaths Deaths
JOIN [Portfolio Project].dbo.COVID_Vaccinations Vac
	ON Deaths.location = Vac.location
	AND Deaths.date = Vac.date
WHERE Deaths.continent IS NOT NULL
AND Vac.new_vaccinations IS NOT NULL
)
SELECT *, (total_vaccinations_rolling/population)*100 AS vaccination_rate_rolling
FROM Pop_Vs_Vac



-- TEMP TABLE

DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinations_rolling numeric
)
INSERT INTO #percent_population_vaccinated
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations AS bigint)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS total_vaccinations_rolling
FROM [Portfolio Project].dbo.COVID_Deaths Deaths
JOIN [Portfolio Project].dbo.COVID_Vaccinations Vac
	ON Deaths.location = Vac.location
	AND Deaths.date = Vac.date
WHERE Deaths.continent IS NOT NULL
AND Vac.new_vaccinations IS NOT NULL

SELECT *, (total_vaccinations_rolling/population)*100 AS vaccination_rate_rolling
FROM #percent_population_vaccinated



-- CREATING A VIEW

CREATE VIEW count_of_people_vaccinated AS
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations AS bigint)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS total_vaccinations_rolling
FROM [Portfolio Project].dbo.COVID_Deaths Deaths
JOIN [Portfolio Project].dbo.COVID_Vaccinations Vac
	ON Deaths.location = Vac.location
	AND Deaths.date = Vac.date
WHERE Deaths.continent IS NOT NULL
AND Vac.new_vaccinations IS NOT NULL

DROP VIEW count_of_people_vaccinated