/****** Script for SelectTopNRows command from SSMS  ******/
select * from 
PortfolioProject..CovidDeath

select * from 
PortfolioProject..CovidVaccination


select Location, date, total_cases_per_million, new_cases, total_deaths, population
from PortfolioProject..CovidDeath
order by  1,2


--looking at total cases vs total death
select date, total_cases , total_deaths,
(total_deaths/total_cases)*100 as ["Percantage of Death"]
from PortfolioProject..CovidDeath
where location like '%states%' and date = '2020-12-31'
order by  1,2

--looking at total cases vs Population
select date,location,  population, convert( int,total_cases) as TotalCases ,FORMAT (total_cases, '###,###,###') AS Total_cases,
(Total_cases/population)*100 as ["Percantage of Population"]
from PortfolioProject..CovidDeath
where location like '%states%' and date = '2020-12-31'
order by  1,2


-- showing Countries with highest infection as percentage of population
select location,  population,Format(MAX(total_cases),'N') as HighestInfectionCount ,
max((total_cases/population))*100 as ["Percantage of Population"]
from PortfolioProject..CovidDeath
where continent is not null
group by location , population
order by  HighestInfectionCount desc


-- showing countries with highest death count per population

select location, MAX(Convert(int,total_deaths)) as HighestDeathCount ,
max((Convert(int,total_deaths)/population))*100 as ["Percantage of death Population"]
from PortfolioProject..CovidDeath
where continent is not null
group by location 
order by  HighestDeathCount desc


-- Breaking things down by continent

 
select continent ,MAX(Convert(int,total_deaths)) as HighestDeathCount 
from PortfolioProject..CovidDeath
where continent is not null
group by continent
order by HighestDeathCount desc

--Global Numbers

select sum(new_cases) as newCases, sum(convert(int, new_deaths )) as newDeaths,
sum(convert(int, new_deaths )) / SUM(new_Cases)* 100 as DeathPercentage 
from dbo.CovidDeath
where continent is not null
--group by date
order by 1,2	



-- Looking at Total Popualtion vs Total Vaccination
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations )) over (Partition by dea.location order 
by dea.location, dea.date) as Rolling_People_Vaccinated
from PortfolioProject..CovidVaccination vac 
join PortfolioProject..CovidDeath  dea
on vac.date=dea.date and vac.location=dea.location
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3



-- Using CTE 

with PopVsVacc (Continent, location, date, Population, new_vaccination, Rolling_People_Vaccinated)

as 
(

	select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
	sum(convert(float,vac.new_vaccinations )) over (Partition by dea.location order 
	by dea.location, dea.date) as Rolling_People_Vaccinated
	from 
	PortfolioProject..CovidVaccination vac 
	join PortfolioProject..CovidDeath  dea
	on vac.date=dea.date and vac.location=dea.location
	where dea.continent is not null 
)
select * ,(Rolling_People_Vaccinated/Population)*100 as RollingVaccPercentage
from PopVsVacc


--Temp Table

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	new_vaccination numeric,
	Rolling_People_Vaccinated numeric
)
insert into #PercentPopulationVaccinated 
	select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
	sum(convert(float,vac.new_vaccinations )) over (Partition by dea.location order 
	by dea.location, dea.date) as Rolling_People_Vaccinated
	from 
	PortfolioProject..CovidVaccination vac 
	join PortfolioProject..CovidDeath  dea
	on vac.date=dea.date and vac.location=dea.location
	--where dea.continent is not null 

select * from 
#PercentPopulationVaccinated




-- Create View to store data for future visualizations 

use PortfolioProject -- used to let the view appear in the views Table
drop view if exists PercentPopulationVaccinated 

create view PercentPopulationVaccinated as 

select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
	sum(convert(float,vac.new_vaccinations )) over (Partition by dea.location order 
	by dea.location, dea.date) as Rolling_People_Vaccinated
	from 
	PortfolioProject..CovidVaccination vac 
	join PortfolioProject..CovidDeath  dea
	on vac.date=dea.date and vac.location=dea.location
	where dea.continent is not null 



select * from  PercentPopulationVaccinated 
