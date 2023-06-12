--Select Relevant Data
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths;

--Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT)/total_cases)*100 AS death_percent
FROM CovidProject..CovidDeaths
WHERE location LIKE 'United%';

--Countries with highest infected percentage of population
SELECT location, population, MAX(total_cases) AS highest_case_count, MAX((CAST(total_cases AS FLOAT)/population)*100) AS infected_population_percent
FROM CovidProject..CovidDeaths
GROUP BY location, population
ORDER BY infected_population_percent DESC;

--Countries with highest death count per population
SELECT location, population, MAX(total_deaths) AS highest_death_count, MAX((CAST(total_deaths AS FLOAT)/population)*100) AS population_death_percent
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY population_death_percent DESC;

--Death count by continent
SELECT continent, MAX(total_deaths) as total_death_count
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

--Death count per population by continent
SELECT continent, MAX((CAST(total_deaths AS FLOAT)/population)*100) AS population_death_percent
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY population_death_percent DESC;

--Global Daily Numbers
SELECT date, SUM(new_cases) AS daily_cases, SUM(new_deaths) AS daily_deaths, SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases)*100 AS daily_death_percent
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1;

--Joining Death and Vaccination Tables
SELECT *
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
ORDER BY 3,4;

--Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count_vaccinations
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- USE CTE
WITH PopVsVac (continent, lcoation, date, population, new_vaccinations, rolling_count_vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count_vaccinations
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_count_vaccinations/CAST(population AS FLOAT))*100 AS percent_population_vaccinated
FROM PopVsVac;


--Creating view for Tableau
CREATE VIEW percent_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count_vaccinations
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL