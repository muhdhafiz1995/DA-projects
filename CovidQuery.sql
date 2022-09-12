--- Covid Query project will showcase how data exploration regarding Covid-19 can be done with SQL using data taken from https://ourworldindata.org/covid-deaths#citation

--- References:
--- Ritchie, H., Mathieu, E., Rodés-Guirao, L., Appel, C., Giattino, C., Ortiz-Ospina, E., Hasell, J., Macdonald, B., Beltekian, D., &amp; Roser, M. (2020, March 5). Coronavirus (COVID-19) deaths. Our World in Data. Retrieved September 12, 2022, from https://ourworldindata.org/covid-deaths#citation 

--- Overview of table

SELECT * 
FROM [Portfolio projects]..CovidDeaths;
SELECT continent, location, date, population, total_cases, new_cases
FROM [Portfolio projects]..CovidDeaths
WHERE continent is not null
Order by 2,4

--- Zooming into the cases in Singapore

SELECT continent, location, date, population, total_cases, new_cases
FROM [Portfolio projects]..CovidDeaths
WHERE location = 'Singapore'
ORDER BY date

--- Sorting table by number of new cases

SELECT continent, location, date, population, total_cases, new_cases
FROM [Portfolio projects]..CovidDeaths
WHERE location = 'Singapore'
ORDER BY new_cases DESC

--- Global Numbers by date


SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM [Portfolio projects]..CovidDeaths
WHERE continent is not null
Group by date
Order by 1,2

--- Global Numbers in total

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM [Portfolio projects]..CovidDeaths
WHERE continent is not null
Order by 1,2

--- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio projects]..CovidDeaths dea
Join [Portfolio projects]..CovidVaccine vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
Order by 2,3


--- Using CTE

With PopsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio projects]..CovidDeaths dea
Join [Portfolio projects]..CovidVaccine vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio projects]..CovidDeaths dea
Join [Portfolio projects]..CovidVaccine vac
   On dea.location = vac.location
   and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio projects]..CovidDeaths dea
Join [Portfolio projects]..CovidVaccine vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
