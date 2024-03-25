SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

-- Select the Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
ORDER BY 1,2 

-- Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2 

-- Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases/population)*100 as CovidPopPercent
FROM CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2 

-- Highest Infection Rates 

SELECT location, MAX(total_cases) as HighestInfectionCount, population, (max(total_cases)/population)*100 as CovidPopPercent
FROM CovidDeaths$
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY CovidPopPercent DESC

-- Highest Death Counts

SELECT location, max(cast(total_deaths as int)) as TotalDeaths
FROM CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeaths DESC

SELECT continent, max(cast(total_deaths as int)) as TotalDeaths
FROM CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeaths DESC

SELECT location, max(cast(total_deaths as int)) as TotalDeaths
FROM CovidDeaths$
--WHERE location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeaths DESC

-- Global Numbers

SELECT date, sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM CovidDeaths$
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2 



-- Total Population vd Total Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Use CTE

With PopvsVac (continent, location, date, population, New_Vaccinations, RollingVaccinations)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations

FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingVaccinations/population)*100 
From PopvsVac

-- TEMP TABLE 

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations

FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for future visualisation

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations

FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
