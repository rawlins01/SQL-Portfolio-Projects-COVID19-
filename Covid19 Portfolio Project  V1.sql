Select * from Project..CovidDeaths
where continent is not NULL
order by 3,4

--Select * from Project..CovidVaccinations
--order by 3,4


--select Data that we using 
Select location, date, total_cases, new_cases, total_deaths, population
from Project..CovidDeaths
where continent is not NULL
order by 1,2


--looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Project..CovidDeaths
where location like '%states%'
order by 1,2


--looking @ the total_cases vs population
--Shows what percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from Project..CovidDeaths
--where location like '%states%'
where continent is not NULL
order by 1,2


--Looking @ countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestIfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
from Project..CovidDeaths
--where location like '%states%'
where continent is not NULL
Group by location, population
order by InfectionPercentage desc



--showing countries with highest death count per population
Select location,  MAX(CAST(total_deaths as int)) as HighestDeathCount
from Project..CovidDeaths
--where location like '%states%'
where continent is not NULL
Group by location
order by HighestDeathCount desc



--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the Continents with the highest death Count per population
Select continent,  MAX(CAST(total_deaths as int)) as HighestDeathCount
from Project..CovidDeaths
--where location like '%states%'
where continent is not NULL
Group by continent
order by HighestDeathCount desc


--Global Numbers 
Select  SUM(new_cases) as TotalNewCases, SUM(CAST(new_deaths as int))as TotalNewDeaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Project..CovidDeaths
--where location like '%states%'
where continent is not NULL
--Group by date
order by 1,2



--Looking @ Total Population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as ROllinPeopleVaccinated,
--(ROllinPeopleVaccinated/population)*100
from Project..CovidDeaths dea
join Project..CovidVaccinations vac
    On dea.location = vac.location
   and dea.date = vac. date 
where dea.continent is not NULL
order by 2,3


--Use CTE
with PopvsVac (continent, location, date, population, new_vaccinations, ROllinPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as ROllinPeopleVaccinated
--, (ROllinPeopleVaccinated/population)*100
from Project..CovidDeaths dea
join Project..CovidVaccinations vac
    On dea.location = vac.location
   and dea.date = vac.date 
where dea.continent is not NULL
--order by 2,3
)
Select *, (ROllinPeopleVaccinated/population)*100 from PopvsVac



--Temp Table

Drop table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
ROllinPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as ROllinPeopleVaccinated
--, (ROllinPeopleVaccinated/population)*100
from Project..CovidDeaths dea
join Project..CovidVaccinations vac
    On dea.location = vac.location
   and dea.date = vac.date 
where dea.continent is not NULL
--order by 2,3

Select *, (ROllinPeopleVaccinated/population)*100 from #PercentPopulationVaccinated



--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as ROllinPeopleVaccinated
--, (ROllinPeopleVaccinated/population)*100
from Project..CovidDeaths dea
join Project..CovidVaccinations vac
    On dea.location = vac.location
   and dea.date = vac.date 
where dea.continent is not NULL
--order by 2,3


Select * from PercentPopulationVaccinated