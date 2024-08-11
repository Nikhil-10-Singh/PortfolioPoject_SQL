SELECT *
FROM PortfolioPoject.[dbo].[Covid_Deaths]
WHERE continent IS NOT NULL
ORDER BY 3, 4



-- Select DATA that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioPoject.[dbo].[Covid_Deaths]
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths
-- Showing likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioPoject.[dbo].[Covid_Deaths]
WHERE location like '%india%'
ORDER BY 1, 2 


-- looking at Total Cases vs Population
-- Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as Cases_Percentage
FROM PortfolioPoject.[dbo].[Covid_Deaths]
WHERE location like '%india%'
ORDER BY 1, 2 


--looking at countries with highest infection rate  compared to population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX(total_cases/population)*100 as Highest_Infection_Percentage
FROM PortfolioPoject.[dbo].[Covid_Deaths]
--WHERE location like '%india%'
GROUP BY location, population
ORDER BY Highest_Infection_Percentage DESC


--Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM PortfolioPoject.[dbo].[Covid_Deaths]
--WHERE location like '%india%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC


--Let's Break Things Down BY Continent

--Showing Continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM PortfolioPoject.[dbo].[Covid_Deaths]
--WHERE location like '%india%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC



--Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
FROM PortfolioPoject.[dbo].[Covid_Deaths]
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2 


--LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(BIGINT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date)
AS Rolling_Peaople_Vaccinated
FROM PortfolioPoject.[dbo].[Covid_Deaths] DEA
JOIN PortfolioPoject.[dbo].[Covid_Vacination] VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2, 3

--USE CTE

WITH PopvsVac( continent, locstion, date, population, new_vaccinations, Rolling_Peaople_Vaccinated)
AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(BIGINT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date)
AS Rolling_Peaople_Vaccinated
FROM PortfolioPoject.[dbo].[Covid_Deaths] DEA
JOIN PortfolioPoject.[dbo].[Covid_Vacination] VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (Rolling_Peaople_Vaccinated / population)
FROM PopvsVac


--Use TEMP TABLE

DROP TABLE IF EXISTS #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population NUMERIC,
New_Vaccinations numeric,
Rolling_Peaople_Vaccinated NUMERIC
)

INSERT INTO #Percent_Population_Vaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(BIGINT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date)
AS Rolling_Peaople_Vaccinated
FROM PortfolioPoject.[dbo].[Covid_Deaths] DEA
JOIN PortfolioPoject.[dbo].[Covid_Vacination] VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
--WHERE DEA.continent IS NOT NULL
ORDER BY 2, 3

SELECT *, (Rolling_Peaople_Vaccinated / population)
FROM #Percent_Population_Vaccinated

--Creating view to store data for later visualizations

CREATE VIEW Percent_Population_Vaccinated AS 
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(BIGINT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date)
AS Rolling_Peaople_Vaccinated
FROM PortfolioPoject.[dbo].[Covid_Deaths] DEA
JOIN PortfolioPoject.[dbo].[Covid_Vacination] VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM Percent_Population_Vaccinated


