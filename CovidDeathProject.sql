USE PorfolioProject

select * from
Coviddeath$

select location, date, population, total_cases, new_cases,total_deaths
from Coviddeath$
order by 1,2


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as
DeathPercent
from Coviddeath$
Where location like 'India'
order by 1,2

select location, total_cases as TotalInfection, (total_cases/population)*100 as
InfectionPercent
from Coviddeath$
order by 1,2

select location, population, MAX(total_cases) as TotalInfection, MAX(total_cases/population)*100 as
PercentPopulationInfection
from Coviddeath$
Where continent is not null --and location like 'India'
Group By location, population
order by PercentPopulationInfection desc

select location, population, MAX(CAST(total_deaths AS INT)) as TotalDeathCount, MAX(total_deaths/population)*100 as
PercentPopulationDeath
from Coviddeath$
Where continent is not null --and location like 'India'
Group By location, population
order by TotalDeathCount desc

select continent, MAX(total_cases) as TotalDeathCount
from Coviddeath$
Where continent is not null --and location like 'India'
Group By continent
order by TotalDeathCount desc

SELECT SUM(NEW_CASES) GlobalNewCases, SUM(CAST(NEW_DEATHS AS INT)) AS GlobalDeaths, 
(SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES))*100 AS GlobalDeathPercent
FROM Coviddeath$
WHERE continent IS NOT NULL
--GROUP BY DATE
ORDER BY 1,2

SELECT * FROM Covidvaccination$

SELECT a.continent, a.location,a.date, a.population, b.new_vaccinations,
SUM(CAST(b.new_vaccinations AS INT)) OVER (PARTITION BY a.location ORDER BY a.location,
a.date) AS RollingPeopleVaccinated

FROM Coviddeath$ a
JOIN
Covidvaccination$ b
ON a.date = b.date
AND
a.location = b.location
WHERE a.continent is not null
order by 2,3



WITH PopulationvsVaccination (continent, location, date, population,
new_vaccinations, RollingPeopleVaccinated) AS
(
SELECT a.continent, a.location,a.date, a.population, b.new_vaccinations,
SUM(CAST(b.new_vaccinations AS INT)) OVER (PARTITION BY a.location ORDER BY a.location,
a.date) AS RollingPeopleVaccinated

FROM Coviddeath$ a
JOIN
Covidvaccination$ b
ON a.date = b.date
AND
a.location = b.location
WHERE a.continent is not null
)

SELECT *, (RollingPeopleVaccinated/population) AS VaccinatedPercent
FROM PopulationvsVaccination


DROP TABLE IF EXISTS PopulationVaccinated

CREATE TABLE #PopulationVaccinated
(
continent varchar(255),
location varchar(255),
date date,
population int,
new_vaccination int,
RollingPeopleVaccinated numeric
)


INSERT INTO #PopulationVaccinated
SELECT a.continent, a.location,a.date, a.population, b.new_vaccinations,
SUM(CAST(b.new_vaccinations AS INT)) OVER (PARTITION BY a.location ORDER BY a.location,
a.date) AS RollingPeopleVaccinated
FROM Coviddeath$ a
JOIN
Covidvaccination$ b
ON a.date = b.date
AND
a.location = b.location
WHERE a.continent is not null
order by 2,3
SELECT *, (RollingPeopleVaccinated/population) AS VaccinatedPercent
FROM #PopulationVaccinated


CREATE VIEW 
PopulationVaccinated AS
SELECT a.continent, a.location,a.date, a.population, b.new_vaccinations,
SUM(CAST(b.new_vaccinations AS INT)) OVER (PARTITION BY a.location ORDER BY a.location,
a.date) AS RollingPeopleVaccinated
FROM Coviddeath$ a
JOIN
Covidvaccination$ b
ON a.date = b.date
AND
a.location = b.location
WHERE a.continent is not null


CREATE VIEW 
GlobalNumbers AS
SELECT SUM(NEW_CASES) GlobalNewCases, SUM(CAST(NEW_DEATHS AS INT)) AS GlobalDeaths, 
(SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES))*100 AS GlobalDeathPercent
FROM Coviddeath$
WHERE continent IS NOT NULL


CREATE VIEW 
ContinentNumber AS
select continent, MAX(total_cases) as TotalDeathCount
from Coviddeath$
Where continent is not null --and location like 'India'
Group By continent


CREATE VIEW 
CountryWiseDeath AS
select location, population, MAX(CAST(total_deaths AS INT)) as TotalDeathCount, MAX(total_deaths/population)*100 as
PercentPopulationDeath
from Coviddeath$
Where continent is not null
Group By location, population

CREATE VIEW 
CountryWiseDeathWithoutIndia AS
select location, population, MAX(CAST(total_deaths AS INT)) as TotalDeathCount, MAX(total_deaths/population)*100 as
PercentPopulationDeath
from Coviddeath$
Where continent is not null
Group By location, population
HAVING location <> 'India'

CREATE VIEW 
TotalDeathInIndia AS
select location, population, MAX(CAST(total_deaths AS INT)) as TotalDeathCount, MAX(total_deaths/population)*100 as
PercentPopulationDeath
from Coviddeath$
Where continent is not null and location like 'India'
Group By location, population

CREATE VIEW
CountryWiseInfection AS
select location, population, MAX(total_cases) as TotalInfection, MAX(total_cases/population)*100 as
PercentPopulationInfection
from Coviddeath$
Where continent is not null
Group By location, population

CREATE VIEW
CountryWiseInfectionWithoutIndia AS
select location, population, MAX(total_cases) as TotalInfection, MAX(total_cases/population)*100 as
PercentPopulationInfection
from Coviddeath$
Where continent is not null
Group By location, population
HAVING location <> 'India'

CREATE VIEW 
TotalInfectionInIndia AS
select location, population, MAX(total_cases) as TotalInfection, MAX(total_cases/population)*100 as
PercentPopulationInfection
from Coviddeath$
Where continent is not null and location like 'India'
Group By location, population

CREATE VIEW 
CovidInfectionTrendIndia AS
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as
DeathPercent
from Coviddeath$
Where location like 'India'

CREATE VIEW 
CovidInfectionTrendCountryWise AS
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as
DeathPercent
from Coviddeath$
EXCEPT
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as
DeathPercent
from Coviddeath$
WHERE location in ('India','World', 'European Union', 'International') 
