-- USE ProjectCovid19

/*

Queries used for Tableau Project

*/

-- 1. 

SELECT	
	SUM(new_cases) AS total_cases
	,SUM(CAST(new_deaths AS int)) AS total_deaths
	,ROUND(SUM(CAST(new_deaths AS int)) / SUM(New_Cases)*100, 4) AS DeathPercentage
FROM 
	ProjectCovid19..CovidDeaths
WHERE 
	continent is not null 
--GROUP BY
--	date
-- ORDER BY
--	1,2
-- GO





/*
Just a double check based off the data provided 
(Sólo una doble comprobación basada en los datos proporcionados)
numbers are extremely close so I will keep them - The Second includes "International"  Location
(los números son extremadamente cercanos, El segundo incluye la ubicación "internacional")
*/

--SELECT 
--	SUM(new_cases) AS total_cases
--	,SUM(CAST(new_deaths as int)) AS total_deaths
--	,SUM(CAST(new_deaths as int)) / SUM(New_Cases) * 100 as DeathPercentage
--FROM
--	ProjectCovid19..CovidDeaths
--WHERE 
--	location = 'World'
--GROUP BY
--	date
--ORDER BY
--	1,2
 GO


-- 2.

-- I take these out as they are not inluded in the above queries and want to stay consistent
-- (Los quito porque no están incluidos en las consultas anteriores y quiero mantener la coherencia)
-- European Union is part of Europe
-- (La Unión Europea es parte de Europa)

SELECT
	location 
	,SUM(CAST(new_deaths as int)) AS TotalDeathCount
FROM 
	ProjectCovid19..CovidDeaths
WHERE
	continent is null AND
	location NOT IN ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
GROUP BY
	location
ORDER BY
	TotalDeathCount DESC
GO



-- 3.

SELECT
	continent
	,Location
	,Population
	,MAX(total_cases) AS HighestInfectionCount
	,ROUND(MAX((total_cases/population))*100, 2) AS PercentPopulationInfected
FROM
	ProjectCovid19..CovidDeaths
WHERE
	continent is not null AND
	location NOT IN ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
GROUP BY 
	Location 
	,Population
	,continent
ORDER BY
	PercentPopulationInfected DESC
GO



-- 4.

SELECT
	location
	,Population
	,CAST(date as date) AS date
	,MAX(total_cases) as HighestInfectionCount
	,MAX((total_cases/population))*100 as PercentPopulationInfected
FROM
	ProjectCovid19..CovidDeaths
GROUP BY
	location
	,population
	,date
ORDER BY
	PercentPopulationInfected DESC

GO
