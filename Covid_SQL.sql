Select
	*
From 
	PortfolioProject..CovidDeaths
Where continent is not null

Select
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
From
	PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelyhood of dying if you contract Covid in your country.

Select
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 as DeathPercentage
From
	PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2

--Looking at total cases vs population.
-- Shows what % of population got Covid.

Select
	location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 as InfectedPercentage
From
	PortfolioProject..CovidDeaths
--Where location like '%states%'
Order by 1,2

--Looking at countries with highest infection rate compared to population


Select
	location,
	population,
	MAX(total_cases) as HighestInfectionCount,
	Max((total_cases/population))*100 as InfectedPercentage
From
	PortfolioProject..CovidDeaths
--Where location like '%states%'
Group By 
	location, population
Order by InfectedPercentage desc
	

-- Countries with highest dead counts per population


Select
	location,
	MAX(Cast(total_deaths as INT)) as TotalDeathCount
From
	PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By 
	location
Order by TotalDeathCount desc



--Showing continents with highest death count per population


Select
	continent,
	MAX(Cast(total_deaths as INT)) as TotalDeathCount
From
	PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By 
	continent
Order by TotalDeathCount desc


-- Global numbers

--Per Date

Select
	date,
	SUM(new_cases) as Total_Cases,
	SUM(Cast(new_deaths as int)) as Total_Deaths, 
	SUM(Cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
From
	PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1

--Totals

Select
	SUM(new_cases) as Total_Cases,
	SUM(Cast(new_deaths as int)) as Total_Deaths, 
	SUM(Cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
From
	PortfolioProject..CovidDeaths
Where continent is not null
Order by 1

--Total population vs Vaccinations

Select
	D.continent,
	D.location,
	D.date,
	D.population,
	V.new_vaccinations,
	SUM(Cast(V.new_vaccinations as int)) OVER (Partition by D.location order by D.location, D.date) as Rolling_People_Vaccinated
From 
	PortfolioProject..CovidVaccinations V
Join 
	PortfolioProject..CovidDeaths D
On
	V.location = D.location and V.date = D.date
Where
	D.continent is not null
Order by 2,3


--Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as
(
Select
	D.continent,
	D.location,
	D.date,
	D.population,
	V.new_vaccinations,
	SUM(Cast(V.new_vaccinations as int)) OVER (Partition by D.location order by D.location, D.date) as Rolling_People_Vaccinated
From 
	PortfolioProject..CovidVaccinations V
Join 
	PortfolioProject..CovidDeaths D
On
	V.location = D.location and V.date = D.date
Where
	D.continent is not null
--Order by 2,3
)
Select *, (Rolling_People_Vaccinated/population)*100  From PopvsVac


--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select
	D.continent,
	D.location,
	D.date,
	D.population,
	V.new_vaccinations,
	SUM(Cast(V.new_vaccinations as int)) OVER (Partition by D.location order by D.location, D.date) as Rolling_People_Vaccinated
From 
	PortfolioProject..CovidVaccinations V
Join 
	PortfolioProject..CovidDeaths D
On
	V.location = D.location and V.date = D.date
Where
	D.continent is not null
--Order by 2,3

Select *, (Rolling_People_Vaccinated/population)*100  From #PercentPopulationVaccinated

--Creating a View to store data for later visualizations

USE PortfolioProject
GO
Create View PercentPopulationVaccinated as 
Select
	D.continent,
	D.location,
	D.date,
	D.population,
	V.new_vaccinations,
	SUM(Cast(V.new_vaccinations as int)) OVER (Partition by D.location order by D.location, D.date) as Rolling_People_Vaccinated
From 
	PortfolioProject..CovidVaccinations V
Join 
	PortfolioProject..CovidDeaths D
On
	V.location = D.location and V.date = D.date
Where
	D.continent is not null
--Order by 2,3

