--Look at Total Cases vs Total Deaths
--Shows rough estimate deah percentage if contracted covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project].dbo.CovidDeaths
where location like '%states%'
order by location, date


--Look at total cases Vs Population
--Shows what population had got Covid
select location, date, population, total_cases, (total_cases/population)*100 as ContractedCovid
from [Portfolio Project].dbo.CovidDeaths
where location like '%states%'
order by location, date


--Looking at Country's with highest Infection rate compared to population
select location, population, max(total_cases) as highest_infection_Count, max((total_cases/population))*100 as PercentofPopulationInfected
from [Portfolio Project].dbo.CovidDeaths
group by location, population
order by PercentofPopulationInfected desc


--Showing Countries with Highest Death Count per Population
select location, max(cast(total_deaths as int)) as Total_DeathCount
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
group by location
order by Total_DeathCount desc

select *
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
order by 3,4

--BREAKING THINGS DOWN BY CONTINENT


--Showing the continents with the highest death counts
select continent, max(cast(total_deaths as int)) as Total_DeathCount
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
group by continent
order by Total_DeathCount desc


--GLOBAL NUMBERS	

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
--group by date
order by 1, 2


--Looking at total population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as 
RollingPeopleVaccinated--, (RollingPeopleVaccinated/dea.population)*100
from [Portfolio Project].dbo.CovidDeaths dea
join [Portfolio Project].dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
with PopVsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as 
RollingPeopleVaccinated--, (RollingPeopleVaccinated/dea.population)*100
from [Portfolio Project].dbo.CovidDeaths dea
join [Portfolio Project].dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac


--TEMP TABLE

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as 
RollingPeopleVaccinated--, (RollingPeopleVaccinated/dea.population)*100
from [Portfolio Project].dbo.CovidDeaths dea
join [Portfolio Project].dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #percentpopulationvaccinated



--Creating view to store data for later vizualization

create View percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as 
RollingPeopleVaccinated--, (RollingPeopleVaccinated/dea.population)*100
from [Portfolio Project].dbo.CovidDeaths dea
join [Portfolio Project].dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpopulationvaccinated