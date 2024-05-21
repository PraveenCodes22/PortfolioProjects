select * from CovidDeath$
where continent is not null
order by 3,4

select location, date,total_cases,total_deaths
from CovidDeath$
where continent is not null
order by 1,2

--total cases vs total deaths
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as DeathPercentage
from CovidDeath$
where location like '%ndia%' and continent is not null
order by 1,2

--Total cases vs Population
--Percentage of people got covid
select location, date, population, total_cases, (total_cases/population) *100 as InfectedPercentage
from CovidDeath$
where continent is not null
order by 1,2

--countries with highest infection rate to population
select location, population, max(total_cases) as HighestInfectionCount, (MAX(total_cases/population)*100) as InfectionPercentage
from CovidDeath$
where continent is not null
group by location, population
order by InfectionPercentage desc

--countries with highest Death count
select location, max(cast(total_deaths as int)) as TotalDeaths
from CovidDeath$
where continent is not null
group by location
order by TotalDeaths desc

--break by continent
select continent, max(cast(total_deaths as int)) as TotalDeaths
from CovidDeath$
where continent is not null
group by continent
order by TotalDeaths desc

--Global numbers
select date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/nullif(sum(new_cases),0) as DeathPercentage
from CovidDeath$
where continent is not null
group by date
order by 1,2

--
--total Population vs Vaccinations

select cd.continent, cd.location,cd.date,cd.population, cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations )) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeath$ cd
join CovidVaccinations$ cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
order by 2,3

-- Use CTE
with PopvsVac(continent, location,date, population,new_vaccinations, RollingPeopleVaccinated)
as
(select cd.continent, cd.location,cd.date,cd.population, cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations )) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeath$ cd
join CovidVaccinations$ cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null)
--order by 2,3)

select *, (RollingPeopleVaccinated/population)*100 from PopvsVac

--Temp Table
drop table if exists #PercentPeopleVaccinated
Create table #PercentPeopleVaccinated(
	continent varchar(200),
	Location varchar(200),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric,

)
insert into #PercentPeopleVaccinated
select cd.continent, cd.location,cd.date,cd.population, cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations )) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeath$ cd
join CovidVaccinations$ cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null


select *, (RollingPeopleVaccinated/population)*100 from #PercentPeopleVaccinated

--creating View to store data to visualize later
create view PercentPeopleVaccinated
as
select cd.continent, cd.location,cd.date,cd.population, cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations )) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeath$ cd
join CovidVaccinations$ cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null;
select * from PercentPeopleVaccinated