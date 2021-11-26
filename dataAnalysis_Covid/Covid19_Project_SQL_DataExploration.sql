--select * 
--from ProjectCovid19..CovidDeaths
--order by 3, 4


-- select Data that I going to be using

SELECT 
	Location 
	,date 
	,total_cases 
	,new_cases 
	,total_deaths 
	,population 
FROM 
	ProjectCovid19..CovidDeaths
ORDER BY 1, 2
GO


-- Looking percentage of deaths due to covid in Mexico
-- Shows likelihood of dying due to covid in Mexico

SELECT 
	Location 
	,date 
	,total_cases
	,total_deaths 
	,ROUND((total_deaths / total_cases )*100, 2) AS DeathPercentaje 
FROM 
	ProjectCovid19..CovidDeaths
WHERE 
	location = 'Mexico'	
GO


-- Looking at Total vs Population
-- Shows what percentage of population infected with Covid in Mexico

SELECT 
	 Location 
	,date 
	,population 
	,total_cases 
	,ROUND((total_cases / population)*100, 2) AS PercentPopulationInfected
FROM 
	ProjectCovid19..CovidDeaths
WHERE 
	location = 'Mexico' AND 
	total_cases >= 1 
GO


-- Countries with highest infection rate compared to population

SELECT 
	 Location 
	,Population 
	,MAX(total_cases) AS HighestInfectionCount
	,ROUND(MAX((total_cases/population))*100, 2) AS PercentPopulationInfected
FROM 
	ProjectCovid19..CovidDeaths
GROUP BY 
	Location, 
	Population
ORDER BY 
	PercentPopulationInfected DESC
GO


-- Countries with Highest Death Count per Population

SELECT Location
	  ,MAX(Total_deaths) AS TotalDeathCount
--SELECT Location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM	
	ProjectCovid19..CovidDeaths
WHERE 
	continent IS NOT NULL 
GROUP BY
	Location
ORDER BY 
	TotalDeathCount DESC
GO


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT 
	continent 
	,MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM	
	ProjectCovid19..CovidDeaths
WHERE	
	continent IS NOT NULL 
GROUP BY 
	continent
ORDER BY 
	TotalDeathCount DESC
GO


-- GLOBAL NUMBERS
-- Using the CONVERT function

SELECT 
	CAST(date AS date) AS Date
	,SUM(new_cases) AS total_cases 
	,SUM(CAST(new_deaths AS int)) AS total_deaths
	,ROUND(SUM(CONVERT(int, new_deaths))/SUM(New_Cases)*100, 2) AS DeathPercentage
FROM 
	ProjectCovid19..CovidDeaths
WHERE 
	continent is not null 
GROUP BY
	date
ORDER BY
	date
GO


SELECT 
	SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS int)) AS total_deaths,
	ROUND(SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100.0, 4) AS 'Death Percentage'
FROM 
	ProjectCovid19..CovidDeaths
WHERE 
	continent IS NOT NULL 
GO


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- Using the WINDOW function

SELECT
	 d.continent
	 ,d.location
	 ,CAST(d.date as date) AS date
	 ,d.population
	 ,v.new_vaccinations
	 ,SUM(CONVERT(bigint, v.new_vaccinations)) OVER 
	 (PARTITION BY d.location ORDER BY d.location, d.date) AS CumulativeNumberOfPeopleVaccinated
FROM
	ProjectCovid19..CovidVaccinations v
JOIN 
	ProjectCovid19..CovidDeaths d
ON
	d.location = v.location AND
	d.date = v.date 
WHERE 
	d.continent IS NOT NULL AND
	v.new_vaccinations IS NOT NULL AND
	'CumulativeNumberOfPeopleVaccinated' IS NOT NULL
ORDER BY
	2,3
GO


-- Using CTE (Common Table Expression) to perform Calculation on Partition By in previous query

WITH Population_Vac 
(
	continent, location, date, population, new_vaccinations, CumulativeNumberOfPeopleVaccinated
)
AS
(
	SELECT
		d.continent
		,d.location
		,CAST(d.date as date) AS date
		,d.population
		,v.new_vaccinations
		,SUM(CONVERT(bigint, v.new_vaccinations)) OVER 
		(PARTITION BY d.location ORDER BY d.location, d.date) AS CumulativeNumberOfPeopleVaccinated
	FROM
		ProjectCovid19..CovidVaccinations v
	JOIN 
		ProjectCovid19..CovidDeaths d
	ON
		d.location = v.location AND
		d.date = v.date 
	WHERE 
		d.continent IS NOT NULL AND
		v.new_vaccinations IS NOT NULL AND
		'CumulativeNumberOfPeopleVaccinated' IS NOT NULL
)
SELECT 
	* ,
	ROUND((CumulativeNumberOfPeopleVaccinated / population)*100, 2) AS PercentageOfVaccinatedVsPopulation
FROM
	Population_Vac 
ORDER BY
	location, date
GO


-- Creating a TEMPORARY TABLE

-- DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255)
	,Location nvarchar(255)
	,Date datetime
	,Population numeric
	,New_Vaccunations numeric
	,CumulativeNumberOfPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT
	d.continent
	,d.location
	,CAST(d.date as date) AS date
	,d.population
	,v.new_vaccinations
	,SUM(CONVERT(bigint, v.new_vaccinations)) OVER 
	(PARTITION BY d.location ORDER BY d.location, d.date) AS CumulativeNumberOfPeopleVaccinated
FROM
	ProjectCovid19..CovidVaccinations v
JOIN 
	ProjectCovid19..CovidDeaths d
ON
	d.location = v.location AND
	d.date = v.date 
WHERE 
	d.continent IS NOT NULL AND
	v.new_vaccinations IS NOT NULL AND
	'CumulativeNumberOfPeopleVaccinated' IS NOT NULL

SELECT 
	*, 
	(CumulativeNumberOfPeopleVaccinated  / Population)*100 AS PercentageOfVaccinatedVsPopulation
FROM
	#PercentPopulationVaccinated
ORDER BY
	location, date
GO


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT
	d.continent
	,d.location
	,CAST(d.date as date) AS date
	,d.population
	,v.new_vaccinations
	,SUM(CONVERT(bigint, v.new_vaccinations)) OVER 
	(PARTITION BY d.location ORDER BY d.location, d.date) AS CumulativeNumberOfPeopleVaccinated
FROM
	ProjectCovid19..CovidVaccinations v
JOIN 
	ProjectCovid19..CovidDeaths d
ON
	d.location = v.location AND
	d.date = v.date 
WHERE 
	d.continent IS NOT NULL AND
	v.new_vaccinations IS NOT NULL AND
	'CumulativeNumberOfPeopleVaccinated' IS NOT NULL
--ORDER BY
	--2,3
GO

SELECT *
FROM
	PercentPopulationVaccinated