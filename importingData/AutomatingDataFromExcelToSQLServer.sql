
-- Importing Data using and BULK INSERT


-- Automating from excel to SQL Server


-- Step1: Create table

USE ProjectCovid19


IF OBJECT_ID('CovidVaccinationsTest') IS NOT NULL DROP TABLE CovidVaccinationsTest

CREATE TABLE CovidVaccinationsTest 
(
		iso_code								varchar(50)
		,continent							    varchar(50)
		,location								nvarchar(250)
		,date									nvarchar(250)
		,new_tests								int
		,total_tests							int
		,total_tests_per_thousand				float
		,new_tests_per_thousand					float
		,new_tests_smoothed						int
		,new_tests_smoothed_per_thousand		float
		,positive_rate							float
		,tests_per_case							float
		,tests_units							nvarchar(250)
		,total_vaccinations						bigint
		,people_vaccinated						bigint
		,people_fully_vaccinated				bigint
		,total_boosters							int
		,new_vaccinations						int
		,new_vaccinations_smoothed				int
		,total_vaccinations_per_hundred			float
		,people_vaccinated_per_hundred			float
		,people_fully_vaccinated_per_hundred	float
		,total_boosters_per_hundred				float
		,new_vaccinations_smoothed_per_million	int
		,new_people_vaccinated_smoothed			float
		,new_people_vaccinated_smoothed_per_hundred	float
		,stringency_index						float
		,population_density						float
		,median_age								float
		,aged_65_older							float
		,aged_70_older							float
		,gdp_per_capita							float
		,extreme_poverty						float
		,cardiovasc_death_rate					float
		,diabetes_prevalence					float
		,female_smokers							float
		,male_smokers							float
		,handwashing_facilities					float
		,hospital_beds_per_thousand				float
		,life_expectancy						float
		,human_development_index				float
		,excess_mortality_cumulative_absolute	float
		,excess_mortality_cumulative			float
		,excess_mortality						float
		,excess_mortality_cumulative_per_million	float

)

-- Step2: Import the Data

BULK INSERT CovidVaccinationsTest
FROM 'C:\Users\Dael\Desktop\data\CovidVaccinations.csv'
WITH (FORMAT = 'csv');


SELECT 
	* 
FROM 
	ProjectCovid19..CovidVaccinationsTest
GO

---------------------------------------------------------------------------------------------------------------------------

-- top 3 countries with the largest populations

SELECT 
	TOP 3
	location
	,MAX(population) AS population
FROM 
	ProjectCovid19..CovidDeaths
WHERE 
	location NOT IN('World', 'Asia', 'Africa', 'European Union', 'Lower middle income', 'Upper middle income', 'High income', 'Europe', 'Low income', 'North America', 'South America')
GROUP BY 
	location
ORDER BY
	population DESC, location
GO


-- replace null values in new_vaccinations column 

UPDATE  CovidVaccinationsTest
	SET new_vaccinations =
	CASE	
		WHEN new_vaccinations IS NULL THEN 0 
		ELSE new_vaccinations
	END
--FROM 
--	ProjectCovid19..CovidVaccinationsTest
GO
-- SELECT new_vaccinations FROM ProjectCovid19..CovidVaccinationsTest

---------------------------------------------------------------------------------------------------------------------------

-- Step 3: Create the view

-- DROP VIEW population_vaccinated_top3_most_populated_countries_ExcelInput
CREATE VIEW  population_vaccinated_top3_most_populated_countries_ExcelInput AS

SELECT 
	d.location
	,d.date
	,d.population
	,v.new_vaccinations
	, SUM(CONVERT(bigint,v.new_vaccinations)) OVER
		(PARTITION BY d.Location 
			ORDER BY d.location, d.date) as PeopleVaccinated
	,ROUND((v.new_vaccinations/population)*100, 2) as PercentagePeopleVaccinated
FROM 
	ProjectCovid19..CovidDeaths d
JOIN 
	ProjectCovid19..CovidVaccinationsTest v
	ON d.location = v.location
	AND d.iso_code = v.iso_code
WHERE 
	v.location IN ('United States', 'India', 'China') 
	AND v.new_vaccinations > 1
GO

/* Test the View
SELECT * FROM vaccinated_population_top10_most_populated_countries_ExcelInput
*/


---------------------------------------------------------------------------------------------------------------------------------


-- Step4 : Creating a Store Procedure

CREATE PROCEDURE CovidVaccinationsTest_Monthly @country varchar(150) 
AS 

IF OBJECT_ID('CovidVaccinationsTest') IS NOT NULL DROP TABLE CovidVaccinationsTest

CREATE TABLE CovidVaccinationsTest 
(
		iso_code								varchar(50)
		,continent							    varchar(50)
		,location								nvarchar(250)
		,date									nvarchar(250)
		,new_tests								int
		,total_tests							int
		,total_tests_per_thousand				float
		,new_tests_per_thousand					float
		,new_tests_smoothed						int
		,new_tests_smoothed_per_thousand		float
		,positive_rate							float
		,tests_per_case							float
		,tests_units							nvarchar(250)
		,total_vaccinations						bigint
		,people_vaccinated						bigint
		,people_fully_vaccinated				bigint
		,total_boosters							int
		,new_vaccinations						int
		,new_vaccinations_smoothed				int
		,total_vaccinations_per_hundred			float
		,people_vaccinated_per_hundred			float
		,people_fully_vaccinated_per_hundred	float
		,total_boosters_per_hundred				float
		,new_vaccinations_smoothed_per_million	int
		,new_people_vaccinated_smoothed			float
		,new_people_vaccinated_smoothed_per_hundred	float
		,stringency_index						float
		,population_density						float
		,median_age								float
		,aged_65_older							float
		,aged_70_older							float
		,gdp_per_capita							float
		,extreme_poverty						float
		,cardiovasc_death_rate					float
		,diabetes_prevalence					float
		,female_smokers							float
		,male_smokers							float
		,handwashing_facilities					float
		,hospital_beds_per_thousand				float
		,life_expectancy						float
		,human_development_index				float
		,excess_mortality_cumulative_absolute	float
		,excess_mortality_cumulative			float
		,excess_mortality						float
		,excess_mortality_cumulative_per_million	float
)

BULK INSERT CovidVaccinationsTest
FROM 'C:\Users\Dael\Desktop\data\CovidVaccinations.csv'
WITH (FORMAT = 'csv');


-- Execute provedure	
-- (Ejecutar procedimeinto)

EXEC CovidVaccinationsTest_Monthly 'Mexico'

SELECT 
	d.location
	,d.date
	,d.population
	,SUM(v.new_vaccinations) OVER
		(
		PARTITION BY d.Location 
			ORDER BY d.location, d.date
		) as PeopleVaccinated
	,ROUND(v.new_vaccinations/population*100, 2) as PercentagePeopleVaccinated
FROM 
	ProjectCovid19..CovidDeaths d
JOIN 
	ProjectCovid19..CovidVaccinationsTest v
	ON d.location = v.location
	AND d.date = v.date
WHERE
	v.location = 'Mexico'