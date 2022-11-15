Select * 
from PortfolioProject ..CovidDeaths
where continent is not NULL

--Select * 
--from PortfolioProject ..CovidVaccinations
--Order  by 3,4;

--Select the data we are going to be using

Select Location, Date, total_cases, new_cases, total_deaths
from PortfolioProject ..CovidDeaths
order by 1,2;
--Looking at total_cases vs Total_death
--Shows the likelihood of dying if you contract covid in your country
Select Location, Date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_percentage 
from PortfolioProject ..CovidDeaths
where location like '%india%'
order by 1,2


---Looking at total cases vs population
--Shows what percentage of population got Covid
Select Location, Date,population,total_cases,(total_cases/population)*100 AS Infectionpercentage 
from PortfolioProject ..CovidDeaths
where location = 'United States' 
order by date

---looking at countries with higher infection rate compared to population

Select Location,population, Max(total_cases) AS 'total_cases',MAX((total_cases/population))*100 AS Infectionpercentage 
from PortfolioProject ..CovidDeaths
--where location = 'United States' 
Group by location,population
order by Infectionpercentage desc;

----showing the countries with the highest death count for the population 
Select Location,total_cases,Max(cast (total_deaths as int)) AS total_deaths
from PortfolioProject ..CovidDeaths
--where location = 'United States'
--Where continent is not null
Group by location 
order by total_deaths desc;

----Lets check the covid data based on the continents

Select continent,Max(cast (total_deaths as int)) AS 'total_deaths'
from PortfolioProject ..CovidDeaths
--where location = 'United States'
Where continent is not null
Group by continent 
order by 'total_deaths' desc;

Select location,Max(cast (total_deaths as int)) AS 'total_deaths'
from PortfolioProject ..CovidDeaths
--where location = 'United States'
Where continent is not null
Group by location 
order by 'total_deaths'

--Showing the continents with highest death count per population
Select location, continent,population, Max(cast (total_deaths as int)) AS 'total_deaths'
from PortfolioProject ..CovidDeaths
--where location = 'United States'
Where continent is not null
Group by Continent, population, location
order by 'total_deaths' desc

--Showing the maximum number of total deaths in Asia continent in descending order
Select location,continent,population--Max(cast (total_deaths as int)) AS 'total_deaths'
from PortfolioProject ..CovidDeaths
Where continent IN ('Asia') 
Group by Continent, population, location
--order by 'total_deaths' asc

--How many locations belong to each continent
Select count(distinct location) as 'Numberofcountries',continent
from PortfolioProject ..CovidDeaths
where continent is not null
group by continent

--Global numbers
--how many cases each day reported?

Select date,sum(new_cases) 
from PortfolioProject ..CovidDeaths
where continent is not null
group by date
order by 1, 2


--Showing the Percentage of death cases according to tht date. 
Select date,Sum(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
from PortfolioProject ..CovidDeaths
--where location = 'United States'
Where continent is not null
Group by date
order by 1,2

--Globally
Select Sum(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
from PortfolioProject ..CovidDeaths
--where location = 'United States'
Where continent is not null
--Group by date
order by 1,2
--It shows the total cases vs total deaths and their percentage. 


--Looking at total population VS Total Vaccination
Select cd.continent, cd.location, cd.date,cd.population,cv.new_vaccinations
,Sum(convert(bigint, cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location, cd.date) as accumulatednumberofvaccination
--(accumulatednumberofvaccination/cd.population)*100 
From CovidDeaths cd
Join CovidVaccinations cv 
	ON cd.location = cv.location 
	and cd.date = cv.date
Where cd.continent is not null
Order by 2,3

---Because we couldn't use the accumulatednumberofvaccination as an immediate column in the previous query so we will be using CTE.
--Use of CTE

With popvsvac (continent, location, date, population, new_vaccinations, accumulatednumberofvaccination)
as
(
	Select cd.continent, cd.location, cd.date,cd.population,cv.new_vaccinations
,Sum(convert(bigint, cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location, cd.date) as accumulatednumberofvaccination
--(accumulatednumberofvaccination/cd.population)*100 
From CovidDeaths cd
Join CovidVaccinations cv 
	ON cd.location = cv.location 
	and cd.date = cv.date
Where cd.continent is not null
--Order by 2,3
)
Select *,(accumulatednumberofvaccination/population)*100 
From popvsvac
-----------------------------------------------------------------------------
--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
accumulatednumberofvaccination numeric
)

Select cd.continent, cd.location, cd.date,cd.population,cv.new_vaccinations
,Sum(convert(bigint, cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location, cd.date) as accumulatednumberofvaccination
--(accumulatednumberofvaccination/cd.population)*100 
From CovidDeaths cd
Join CovidVaccinations cv 
	ON cd.location = cv.location 
	and cd.date = cv.date
Where cd.continent is not null
--Order by 2,3
Select *,(accumulatednumberofvaccination/population)*100 
From #PercentPopulationVaccinated

------------------------------------------------------
--creating view to store data for visualization

Create view percentpopulationvaccinated as 
Select cd.continent, cd.location, cd.date,cd.population,cv.new_vaccinations
,Sum(convert(bigint, cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location, cd.date) as accumulatednumberofvaccination
--(accumulatednumberofvaccination/cd.population)*100 
From CovidDeaths cd
Join CovidVaccinations cv 
	ON cd.location = cv.location 
	and cd.date = cv.date
Where cd.continent is not null
--Order by 2,3
--------
Select * from percentpopulationvaccinated










