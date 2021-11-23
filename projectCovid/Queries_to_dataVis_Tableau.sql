-- USE ProjectCovid19

/*

Queries used for Tableau Project

*/

-- 1. 

SELECT	
	SUM(new_cases) AS total_cases
	,SUM(CAST(new_deaths AS int)) AS total_deaths
	,SUM(CAST(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM 
	ProjectCovid19..CovidDeaths
WHERE 
	continent is not null 
--Group By date
ORDER BY
	1,2
GO