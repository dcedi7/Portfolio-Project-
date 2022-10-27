SELECT *
 FROM PortfolioProject..[Covid Deaths]
 WHERE continent is not null
 ORDER BY 3,4
 
 --SELECT *
 --FROM PortfolioProject..[Covid Vaccinations]
 --ORDER BY 3,4
 
 SELECT Location, date, total_cases, new_cases, total_deaths, population
 FROM PortfolioProject..[Covid Deaths]
 ORDER BY 1,2

 --Looking at Total Cases vs Total Cases

 SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
 FROM PortfolioProject..[Covid Deaths]
 WHERE location = 'United States'
 ORDER BY 1,2

 --Currently, the death percentage if you were to get infected would be around 2% chance of dying. 

 --Population vs Covid cases
 
 SELECT Location, date,population,total_cases, (total_cases/population)*100 AS InfectedPopulation
 FROM PortfolioProject..[Covid Deaths]
 WHERE location = 'United States'
 ORDER BY 1,2

 --Highest infectious rate per country

 SELECT Location,population,MAX(total_cases)as InfectiousCount, Max((total_cases/population))*100 As InfectedPopulationPercent                                                  
 FROM PortfolioProject..[Covid Deaths]
 GROUP BY Location, population
 ORDER BY InfectedPopulationPercent DESC

 --Highest death toll per country

 --To get the Max total deaths, i had to cast as integer since in the original database it is a varchar. Giving more accurate numbers rather than 'characters'.
 SELECT Location,MAX(cast(total_deaths as int)) AS TotalDeathCount
 FROM PortfolioProject..[Covid Deaths]
 WHERE continent is not null
 GROUP BY Location
 ORDER BY TotalDeathCount DESC

 --Broken down by continent 

 SELECT continent,MAX(cast(total_deaths as int)) AS TotalDeathCount
 FROM PortfolioProject..[Covid Deaths]
 WHERE continent is not null
 GROUP BY continent
 ORDER BY TotalDeathCount DESC

 --Numbers Worldwide
 SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths,
 SUM(cast(new_deaths as int))/SUM(New_cases)*100 AS DeathPercentage
 FROM PortfolioProject..[Covid Deaths]
 WHERE continent is not null
 ORDER BY 1,2


 --Daily Covid new cases
 SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths,
 SUM(cast(new_deaths as int))/SUM(New_cases)*100 AS DeathPercentage
 FROM PortfolioProject..[Covid Deaths]
 WHERE continent is not null
 GROUP BY date
 ORDER BY 1,2

 --Total population vs Vaccination
 SELECT death.continent, death.location, death.date, death.population, vaxx.new_vaccinations,
 SUM(cast(vaxx.new_vaccinations as int)) OVER (Partition by death.location ORDER BY death.location, death.date) AS PeopleVaccinated
 FROM PortfolioProject..[Covid Deaths] death	
 JOIN PortfolioProject..[Covid Vaccination] vaxx
	On death.location = vaxx.location 
	AND death.date = vaxx.date
WHERE death.continent is NOT null
ORDER BY 2,3


--CTE

WITH PopvsVac (Continent, location, date, population, new_vaccinations, PeopleVaccinated)
AS 
(
 SELECT death.continent, death.location, death.date, death.population, vaxx.new_vaccinations
 , SUM(cast(vaxx.new_vaccinations as int)) OVER (Partition by death.location ORDER BY death.location, death.date) AS PeopleVaccinated
 FROM PortfolioProject..[Covid Deaths] death	
 JOIN PortfolioProject..[Covid Vaccination] vaxx
	On death.location = vaxx.location 
	AND death.date = vaxx.date
WHERE death.continent is NOT null
)

SELECT * , (PeopleVaccinated/ population)*100
FROM PopvsVac
---
---TEMP TABLE

DROP TABLE IF EXISTS #PopulationVaccinatedByPercentage
CREATE TABLE #PopulationVaccinatedByPercentage
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)
INSERT INTO #PopulationVaccinatedByPercentage
SELECT death.continent, death.location, death.date, death.population, vaxx.new_vaccinations,
 SUM(cast(vaxx.new_vaccinations as bigint)) OVER (Partition by death.location ORDER BY death.location, death.date) AS PeopleVaccinated
 FROM PortfolioProject..[Covid Deaths] death	
 JOIN PortfolioProject..[Covid Vaccination] vaxx
	On death.location = vaxx.location 
	AND death.date = vaxx.date
WHERE death.continent is NOT null

SELECT * , (PeopleVaccinated/ population)*100
FROM #PopulationVaccinatedByPercentage


---
--Creating View for visuals
--

CREATE VIEW PopulationVaccinatedPercentage as 
SELECT death.continent, death.location, death.date, death.population, vaxx.new_vaccinations,
 SUM(cast(vaxx.new_vaccinations as bigint)) OVER (Partition by death.location ORDER BY death.location, death.date) AS PeopleVaccinated
 FROM PortfolioProject..[Covid Deaths] death	
 JOIN PortfolioProject..[Covid Vaccination] vaxx
	On death.location = vaxx.location 
	AND death.date = vaxx.date
WHERE death.continent is NOT null

