SELECT * 
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2 -- Order by location and date 

-- Looking at Total Cases VS Total Deaths
-- Shows the likelyhood of dying if an invidual caught covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%' --Take every location in the united states, take total_deaths / total_cases to see the deathpercentage of total_deaths and total_cases
Order by 1,2 

-- Looking at Total Cases VS Total Deaths
-- Shows the percentage of population who got Covid
Select Location, population, date, total_cases, (total_cases / population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%' --Take every location in the united states, take total_deaths / total_cases to see the deathpercentage of total_deaths and total_cases
Order by 1,2 


--Looking at Countries with highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases / population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where Location like '%states%' --Take every location in the united states, take total_deaths / total_cases to see the deathpercentage of total_deaths and total_cases
Group By Location, Population
Order by PercentPopulationInfected desc



-- Let's break things down by continent 



--Showing Countries with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--Where Location like '%states%' --Take every location in the united states, take total_deaths / total_cases to see the deathpercentage of total_deaths and total_cases
Where continent is not null 
Group By continent
Order by TotalDeathCount desc


--Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2



-- Looking at total population vs Vaccinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date) as RollingNewVaccinations
--(RollingNewVaccinations / dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3


--USE CTE 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingNewVaccinations)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date) as RollingNewVaccinations
--(RollingNewVaccinations / dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
Select *, (RollingNewVaccinations/Population)*100 
From PopvsVac



-- Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingNewVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date) as RollingNewVaccinations
--(RollingNewVaccinations / dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select *, (RollingNewVaccinated/Population)*100 
From #PercentPopulationVaccinated



-- Creating view to store data for later visualizations
Create View PercentPopulationVaccinations as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date) as RollingNewVaccinations
--(RollingNewVaccinations / dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinations