--select * from CovidDeaths order by 3,4

--select Location, date,total_cases,new_cases, total_deaths,population
--from CovidDeaths
--order by 1,2

select distinct location, continent,total_deaths 
from project.dbo.CovidDeaths
where continent is null

-- Total cases vs Total Deaths
select Location, date,total_cases,total_deaths, (total_deaths* 1.0/total_cases)*100 as DeathPercentage
from project.dbo.CovidDeaths
where location = 'Egypt'
order by 1,2

-- Total cases vs population
select Location, date,total_cases,population, (total_cases* 1.0/population)*100 as population_covid_Percentage
from project.dbo.CovidDeaths
where location like '%states%'
order by 1,2

-- countries with highest infection rate compared to population
select location ,population , MAX(total_cases) as Highest_infection_count ,MAX((total_cases* 1.0/population)*100) as population_covid_Percentage
from project.dbo.CovidDeaths
Group by location ,population
order by population_covid_Percentage desc

--
--select continent,MAX(total_deaths) as TotalDeathCount
--from project.dbo.CovidDeaths
--where continent is not null
--Group by continent
--order by TotalDeathCount desc
-- countries with highest death count per population
select location, MAX(total_deaths) as TotalDeathCount
from project.dbo.CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

--Global Numbers
Select --date, 
       SUM(new_cases) as total_cases, 
       SUM(new_deaths) as total_deaths, 
       SUM(new_deaths) *1.0/ SUM(New_Cases) * 100 as DeathPercentage
From project.dbo.CovidDeaths
where continent is not null
--Group By date
order by 1,2
--looking at Total population vs vaccoinations
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent ,dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.Date) as RollingPeopleVaccinated
From  project.dbo.CovidDeaths dea
Join project.dbo.CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
Select *,(RollingPeopleVaccinated*1.0/Population)*100 --as of this date, what percentage of the country's total population has been vaccinated so far?
From PopvsVac

-- another way 

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
From project.dbo.CovidDeaths dea
Join project.dbo.CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date

Select *, (RollingPeopleVaccinated*1.0/Population)*100
From #PercentPopulationVaccinated
--for later visulaization

--create view PercentPopulationVaccinated2 as
--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
--From project.dbo.CovidDeaths dea
--Join project.dbo.CovidVaccinations vac
--    On dea.location = vac.location
--    and dea.date = vac.date
--where dea.continent is not null

-- Death rate before vs after each country's vaccination campaign began
With FirstVax as
(
    select location, MIN(date) as first_vax_date
    from project.dbo.CovidVaccinations
    where new_vaccinations is not null and new_vaccinations > 0
    group by location
)
select dea.location,
       SUM(case when dea.date <  fv.first_vax_date then dea.new_deaths else 0 end) * 1.0
     / NULLIF(SUM(case when dea.date <  fv.first_vax_date then dea.new_cases  else 0 end), 0) * 100 as DeathRate_BeforeVax,
       SUM(case when dea.date >= fv.first_vax_date then dea.new_deaths else 0 end) * 1.0
     / NULLIF(SUM(case when dea.date >= fv.first_vax_date then dea.new_cases  else 0 end), 0) * 100 as DeathRate_AfterVax
from project.dbo.CovidDeaths dea
join FirstVax fv on dea.location = fv.location
where dea.continent is not null
group by dea.location
order by DeathRate_BeforeVax desc

select COUNT(*) as good_rows
from project.dbo.CovidVaccinations
where location = 'Egypt' and new_vaccinations > 0