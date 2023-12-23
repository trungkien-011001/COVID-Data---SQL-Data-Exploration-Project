--Checking the Data
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
ORDER BY 3,4

--Select using Data
SELECT continent, location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 2,3

--Total Deaths vs Total Cases
--The likelihood of dying if you contract the Covid in Vietnam
SELECT continent, location, date, CAST(total_cases AS INT) AS total_cases, CAST(total_deaths AS INT) AS total_deaths, 
new_deaths, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 AS DeathsPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'Viet%'
ORDER BY 2,3

--Total_cases vs Population
--Showing what percentage of population got infected by the Covid in each country.
SELECT continent, location, date, CAST(total_cases AS INT) AS total_cases, population, 
(CAST(total_cases AS FLOAT)/population)*100 AS CasesPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 2,3

--Showing countries having the Total Infection Count compared to Population from highest to smallest.
SELECT location, population, MAX(CAST(total_cases AS INT)) AS TotalInfectionCount,
MAX(CAST(total_cases AS FLOAT)/population)*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectionRate DESC

--Showing countries having the Total Deaths Count from highest to smallest.
SELECT continent, location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location
ORDER BY TotalDeathCount DESC

--Showing continents having the Total Deaths Count from highest to smallest.
SELECT continent, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing global numbers.
SELECT SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS INT)) AS Total_death, 
(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 TotalDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

--Showing the Total population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Using CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinations) 
AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingVaccinations/population)*100 AS VacOverPop
FROM PopvsVac
ORDER BY 2,3

--Creating TEMP TABLE
DROP TABLE IF EXISTS #PopvsVac
CREATE TABLE #PopvsVac(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinations numeric
)

INSERT INTO #PopvsVac
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingVaccinations/population)*100 AS VacOverPop
FROM #PopvsVac
ORDER BY 2,3

--Creating View
CREATE VIEW PercentPopVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopVaccinated
