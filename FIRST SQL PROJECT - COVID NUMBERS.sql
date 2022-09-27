--SELECT * 
--FROM PortfolioProject..covid_deaths
--WHERE continent is not null
--ORDER BY 3,4


--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..Covid_Deaths
--ORDER BY 1,2

-- LOOKING AT tOTAL cASES Vs Total deaths
--SHOWS likelihood of dying if you contract covid in your country
--SELECT location, date, total_cases, total_deaths, (total_deaths/ total_cases) * 100 as DeathPercentage
--FROM PortfolioProject..Covid_Deaths
--WHERE location LIKE '%states%'
--ORDER BY 1,2

-- LOOKING AT tOTAL cASES Vs population
--Shows what percentage of the population has gotten covid
----SELECT location, date, total_cases, population, (total_cases/population) * 100 as Got_Covid
----FROM PortfolioProject..Covid_Deaths
----WHERE location LIKE '%states%'
----ORDER BY 1,2

--SELECT location, MAX(total_cases) AS HIghestInfectionCount, population, (MAX(total_cases)/population) * 100 as Population_infected
--FROM PortfolioProject..Covid_Deaths
----WHERE location LIKE '%states%'
--GROUP BY population, location
--ORDER BY Population_Infected DESC

--Showing Countries with the highest death count 
SELECT continent, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..Covid_Deaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT date,SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS float))/SUM
(new_cases) * 100 AS Death_Global
FROM PortfolioProject..Covid_Deaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 DESC


--Total POpulation vs Vaccination
-- WITH CTE
WITH popvsvac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date)
AS RollingPeopleVaccinated

FROM PortfolioProject..Covid_Deaths dea
JOIN PortfolioProject..Covid_Vaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population) * 100 AS Vaccinated_Percentage
FROM popvsvac
WHERE LOCATION = 'UNITED STATES'





-- TEMP TABLE 
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric )

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date)
AS RollingPeopleVaccinated

FROM PortfolioProject..Covid_Deaths dea
JOIN PortfolioProject..Covid_Vaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3


Select *, (RollingPeopleVaccinated/Population) * 100
FROM #PercentPopulationVaccinated

--Creating View to store in temp table for later visuals

Create View PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date)
AS RollingPeopleVaccinated

FROM PortfolioProject..Covid_Deaths dea
JOIN PortfolioProject..Covid_Vaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3
