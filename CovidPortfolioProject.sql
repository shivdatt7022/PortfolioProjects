select * from PortfolioProject.dbo.CovidDeaths
--select * from PortfolioProject..CovidDeaths
--select * from dbo.CovidDeaths
where continent is not null -- to avoid continent name in location
order by 3,4--3rd column

select * from dbo.CovidVaccinations
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
order by 1,2

--looking at total cases vs total deaths
-- shows likelihood of dying if u get covid
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 DeathPercentage
from dbo.CovidDeaths
where location like'%india%'
order by 1,2

--total case vs pop
--shows what percentage of people got covid
select location, date, total_cases, population, (total_cases/population) * 100 PercentPopInfected
from dbo.CovidDeaths
--where location like'%india%'
order by 1,2

--looking at countries with highest infection rate compared to population
select location, population, max(total_cases) HighestInfectionCount, 
	max((total_cases/population)) * 100 PercentPopInfected
from dbo.CovidDeaths
--where location like'%india%'
group by location, population
order by PercentPopInfected desc

--looking at countries with highest death count per population
select location, max(cast(total_deaths as int)) TotalDeaths
from dbo.CovidDeaths
where continent is not null
--and location like'%india%'
group by location
order by TotalDeaths desc

-- breaking this down by continent
select location, max(cast(total_deaths as int)) TotalDeathCount
from dbo.CovidDeaths
where continent is null --excludes world'
--and location like'%india%'
group by location
order by TotalDeathCount desc

--showing continents with highest death count per population
select continent, max(cast(total_deaths as int)) TotalDeathCount
from dbo.CovidDeaths
where continent is not null
--and location like'%india%'
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select date, sum(new_cases) TotalCases,sum(cast(new_deaths as int)) TotalDeaths,sum(cast(new_deaths as int)) / sum(new_cases)
* 100 DeathPercentage
from dbo.CovidDeaths
--where location like'%india%'
where continent is not null
group by date
order by date


--ANOMALITY
select  location, max(total_cases),sum(new_cases) --max(cast(total_deaths as int)),max(cast(total_deaths as int)) / max(total_cases)
--* 100 DeathPercentage
from dbo.CovidDeaths
--where location like'%india%'
where continent is not null
group by location
having max(total_cases) !=sum(new_cases)
--order by 2,3


--vaccination table join
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
from dbo.CovidDeaths cd 
join dbo.CovidVaccinations cv
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null
order by 2,3

--looking at total population vs vaccination
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.date) RollingPeopleVaccinated
from dbo.CovidDeaths cd 
join dbo.CovidVaccinations cv
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null
--order by 2,3


--use CTE to get percentage of vaccinated people
with PopVsVac as 
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.date) RollingPeopleVaccinated
from dbo.CovidDeaths cd 
join dbo.CovidVaccinations cv
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null
)
select *, (RollingPeopleVaccinated/population) * 100  from PopVsVac

--TEMP TABLE	

Drop table if exists PercentPopulationVaccinated
Create table PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.date) RollingPeopleVaccinated
from dbo.CovidDeaths cd 
join dbo.CovidVaccinations cv
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null

select *, (RollingPeopleVaccinated/population) * 100  from PercentPopulationVaccinated


-- creating view to store data for later visualizations

drop view if exists PercentPopulationVaccinated2
create view PercentPopulationVaccinated2 as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.date) RollingPeopleVaccinated
from dbo.CovidDeaths cd 
join dbo.CovidVaccinations cv
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null
--order by 2,3
select * from PercentPopulationVaccinated2