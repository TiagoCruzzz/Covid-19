CREATE TABLE covid_data (
    iso_code VARCHAR(255),
    continent VARCHAR(255),
    location VARCHAR(255),
    date VARCHAR(255),
    population FLOAT,
    aged_65_older FLOAT,
    aged_70_older FLOAT,
    gdp_per_capita FLOAT,
    extreme_poverty FLOAT,
    cardiovasc_death_rate FLOAT,
    diabetes_prevalence FLOAT,
    life_expectancy FLOAT,
    total_cases FLOAT,
    new_cases FLOAT,
    new_cases_smoothed FLOAT,
    total_deaths FLOAT,
    new_deaths FLOAT,
    new_deaths_smoothed FLOAT,
    total_cases_per_million FLOAT,
    new_cases_per_million FLOAT,
    new_cases_smoothed_per_million FLOAT,
    total_deaths_per_million FLOAT,
    new_deaths_per_million FLOAT,
    new_deaths_smoothed_per_million FLOAT,
    reproduction_rate FLOAT,
    icu_patients FLOAT,
    icu_patients_per_million FLOAT,
    hosp_patients FLOAT,
    hosp_patients_per_million FLOAT,
    weekly_icu_admissions FLOAT,
    weekly_icu_admissions_per_million FLOAT,
    weekly_hosp_admissions FLOAT,
    weekly_hosp_admissions_per_million FLOAT,
    total_tests FLOAT,
    new_tests FLOAT,
    total_tests_per_thousand FLOAT,
    new_tests_per_thousand FLOAT,
    new_tests_smoothed FLOAT,
    new_tests_smoothed_per_thousand FLOAT,
    positive_rate FLOAT,
    tests_per_case FLOAT,
    tests_units VARCHAR(255)
);

SHOW VARIABLES LIKE 'secure_file_priv';
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\covid_deaths.csv' INTO TABLE covid_data
FIELDS TERMINATED BY ';'
ESCAPED BY '\\'
IGNORE 1 LINES;

-- Data Manipulation: 
SELECT * FROM covid_data; -- Analyzing the data

-- The date is not in the correct format (it is a text that represents a number where January 1, 1900, is represented as 1, and the next dates are represent as a count since that date and number, so we need to put it in the right way:
ALTER TABLE covid_data
ADD new_date DATE; 

SET SQL_SAFE_UPDATES = 0; -- To allow me to make updates in this session

UPDATE covid_data
SET new_date = DATE_FORMAT(
    FROM_UNIXTIME((date-25569)*86400),
    '%Y.%m-%d'
);

ALTER TABLE covid_data 
DROP COLUMN date; 

SELECT * FROM covid_data; 

-- Data exploring: 
-- Selecting the data that I will work first: location, population, total_cases, new_cases, total_deaths and new_date: 
SELECT location, new_date AS date, population, total_cases, new_cases, total_deaths
FROM covid_data; 

-- Finding the percentage of deaths that had a positive test (That is a case o covid): 
SELECT location, new_date AS date, population, (total_deaths/total_cases)*100 AS Death_Percentage
FROM covid_data; 

-- Checking the death percentage caused by covid in Portugal: 
SELECT location, new_date AS date, population, (total_deaths/total_cases)*100 AS Death_Percentage
FROM covid_data
WHERE location LIKE 'Portugal'; 

-- Checking the locations with the highest infection rate:
SELECT location, population, ROUND(MAX((total_cases/population)*100),2) AS Percent_Pop_Infected
FROM covid_data
GROUP BY location, population
ORDER BY Percent_Pop_Infected DESC;

-- Checking the percentage of population that got covid declared at Portugal:
SELECT location,  population, ROUND(MAX((total_cases/population)*100),2) AS Percent_Pop_Infected
FROM covid_data
WHERE location LIKE 'Portugal'
GROUP BY location, population;

-- Checking the highest percentage of population infected per day in Portugal and the date where that fact occurred: 
SELECT location, new_date, population, new_cases, ROUND(MAX((new_cases/population)*100),5) AS Percent_Pop_Infected
FROM covid_data
WHERE location LIKE 'Portugal'
GROUP BY new_date
ORDER BY Percent_Pop_Infected DESC; 


-- Checking the locations with the highest death per population: 
SELECT location, population, ROUND(MAX((total_deaths/population)*100),2) AS Percent_Pop_Death
FROM covid_data
GROUP BY location, population
ORDER BY Percent_Pop_Death DESC;

-- Checking the total deaths per population at Portugal:
SELECT location, population, ROUND(MAX((total_deaths/population)*100),2) AS Percent_Pop_Death
FROM covid_data
WHERE location LIKE 'Portugal'
GROUP BY location, population; 

-- Checking the highest percentage of population death per day in Portugal and the date where that fact occurred: 
SELECT location, new_date, population, new_deaths, ROUND(MAX((new_deaths/population)*100),5) AS Percent_Pop_Death
FROM covid_data
WHERE location LIKE 'Portugal'
GROUP BY new_date
ORDER BY Percent_Pop_Death DESC; 

-- The maximum percentage of population death occurs before the highest number of percentage of population infected, probably because of the implementation and use of vaccines, implemented rules and people adaptation to this disease: 
-- Analyze the vaccines information! 

-- Checking the total cases (Number of confirmed cases) of covid in Portugal: 
SELECT location, population, MAX(total_cases) AS confirmed_cases
FROM covid_data
WHERE location LIKE 'Portugal'
GROUP BY location, population; 
-- OR 
SELECT location, population, SUM(new_cases) AS confirmed_cases
FROM covid_data
WHERE location LIKE 'Portugal'; 

-- Checking the total number of deaths in Portugal: 
SELECT location, population, MAX(convert( total_deaths,SIGNED)) AS deaths
FROM covid_data
WHERE location LIKE 'Portugal'
GROUP BY location, population; 
-- Or
SELECT location, population, SUM(new_deaths) AS deaths
FROM covid_data
WHERE location LIKE 'Portugal'; 

-- Checking the total number of deaths: 
SELECT location, population, MAX(convert(total_deaths,SIGNED)) AS deaths
FROM covid_data
GROUP BY location
ORDER BY deaths DESC;  

-- AS we can see there are some fields in location column that should not be there, for example World, European Union, etc, as we want the countries. 
SELECT location, population, MAX(convert(total_deaths, SIGNED)) AS deaths
FROM covid_data
WHERE continent != '0.0'
GROUP BY location
ORDER BY deaths DESC;

-- Looking for the values by continent: 
-- Number of deaths by continent: 
SELECT continent, population, MAX(convert(total_deaths, SIGNED)) AS deaths
FROM covid_data
WHERE continent != '0.0'
GROUP BY continent
ORDER BY deaths DESC; 

-- Checking the continents with the highest death rate: 
SELECT continent, population, MAX(total_deaths),  ROUND(Max((total_deaths/population)*100),3) AS PercentPopDeath
FROM covid_data
WHERE continent != '0.0'
GROUP BY continent
ORDER BY PercentPopDeath DESC; 

-- Checking the continents with the highest infection rate: 
SELECT continent, population, MAX(total_cases), ROUND(MAX((total_cases/population)*100),3) AS PercentPopInfected
FROM covid_data
WHERE continent != '0.0'
GROUP BY continent
ORDER BY PercentPopInfected DESC;

-- Checking the global numbers:  
-- Daily:
SELECT location, new_date AS date , (new_cases) AS total_cases, (new_deaths) AS total_deaths
FROM covid_data
WHERE continent != '0.0'
GROUP BY location, date 
ORDER BY 1;

-- Total:
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, ROUND((SUM(new_deaths)/SUM(new_cases))*100,3) AS DeathPercent
FROM covid_data
WHERE continent != '0.0';

-- ----------------------------------------------------------------------------------------------
-- Adding the vaccinations table:
CREATE TABLE IF NOT EXISTS covid_vaccinations (
       iso_code VARCHAR(255),
       continent VARCHAR(255),
       location VARCHAR(255),
       date VARCHAR(255),
       total_vaccinations FLOAT,
       people_vaccinated FLOAT,
       people_fully_vaccinated FLOAT,
       total_boosters FLOAT, 
       new_vaccinations FLOAT,
       new_vaccinations_smoothed VARCHAR(255)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\covid_vaccintions.csv' INTO TABLE covid_vaccinations
FIELDS TERMINATED BY ';'
ESCAPED BY '\\'
IGNORE 1 LINES;

SELECT total_vaccinations FROM covid_vaccinations;
 
ALTER TABLE covid_vaccinations
ADD new_date DATE; 

SET SQL_SAFE_UPDATES = 0; -- To allow me to make updates in this session

UPDATE covid_vaccinations
SET new_date = DATE_FORMAT(
    FROM_UNIXTIME((date-25569)*86400),
    '%Y.%m-%d'
);

ALTER TABLE covid_vaccinations 
DROP COLUMN date; 

-- The new_vaccinations column have text values but I want to change it to INTEGER:
ALTER TABLE covid_vaccinations
MODIFY COLUMN new_vaccinations_smoothed INTEGER; 

-- ----------------------------------------------------------------------------------------------------------------------
-- Now I want to join the tables to understand the impact of the vaccination process:
-- Checking the number of vaccines administered by country:  
SELECT cd.location, cd.population, MAX(cv.total_vaccinations) AS Vaccines_administered
FROM covid_data cd
JOIN covid_vaccinations cv
ON cd.location = cv.location AND cd.new_date = cv.new_date
WHERE cd.continent != '0.0' 
GROUP BY location; 

-- Checking the number of vaccines administered by continent:
SELECT continent, MAX(total_vaccinations) AS Vaccines_administered
FROM covid_vaccinations
WHERE continent != '0.0'
GROUP BY continent; 

-- Checking the number of persons vaccinated with at least one dose:
SELECT cd.location, cd.population, MAX(cv.people_vaccinated)
FROM covid_data cd
JOIN covid_vaccinations cv
ON cd.location = cv.location AND cd.new_date = cv.new_date
WHERE cd.continent != '0.0' 
GROUP BY location; 

-- Checking the number of persons vaccinated fully vaccinated:
SELECT cd.location, cd.population, MAX(cv.people_fully_vaccinated)
FROM covid_data cd
JOIN covid_vaccinations cv
ON cd.location = cv.location AND cd.new_date = cv.new_date
WHERE cd.continent != '0.0' 
GROUP BY location; 

-- Checking the number of persons vaccinated with a booster vaccine:
SELECT cd.location, cd.population, MAX(cv.total_boosters)
FROM covid_data cd
JOIN covid_vaccinations cv
ON cd.location = cv.location AND cd.new_date = cv.new_date
WHERE cd.continent != '0.0' 
GROUP BY location; 


-- ---------------------------------------------------------------------------------
-- Checking the total vaccinations per day in Portugal:
SELECT cd.location, cd.population, cv.new_date, cv.total_vaccinations
FROM covid_data cd
JOIN covid_vaccinations cv
ON cd.location = cv.location AND cd.new_date = cv.new_date
WHERE cd.location LIKE 'Portugal'; 

-- ---------------------------------------------------------------------------------
-- Creating views with information that i will use then to create the dashbord: 

-- Checking the locations(COUNTRIES) with the highest infection rate:
CREATE VIEW Percent_Population_Infected AS
SELECT location, population, ROUND(MAX((total_cases/population)*100),2) AS Percent_Pop_Infected
FROM covid_data
GROUP BY location, population
ORDER BY Percent_Pop_Infected DESC;

-- Checking the percentage of population that got covid declared at Portugal:
CREATE VIEW Percent_Population_Infected_Portugal AS
SELECT location,  population, ROUND(MAX((total_cases/population)*100),2) AS Percent_Pop_Infected
FROM covid_data
WHERE location LIKE 'Portugal'
GROUP BY location, population;

-- Checking the locations(countries) with the highest death rate: 
CREATE VIEW Percent_Population_Death AS
SELECT location, population, ROUND(MAX((total_deaths/population)*100),2) AS Percent_Pop_Death
FROM covid_data
GROUP BY location, population
ORDER BY Percent_Pop_Death DESC;

-- Total cases in portugal:
CREATE VIEW confirmed_cases_Portugal AS
SELECT location, population, MAX(total_cases) AS confirmed_cases
FROM covid_data
WHERE location LIKE 'Portugal'
GROUP BY location, population; 

-- Total deaths in portugal: 
CREATE VIEW total_deaths_portugal AS
SELECT location, population, MAX(convert( total_deaths,SIGNED)) AS deaths
FROM covid_data
WHERE location LIKE 'Portugal'
GROUP BY location, population; 

-- Total cases, total deaths and death percentage in entire world: 
CREATE VIEW total_global AS
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, ROUND((SUM(new_deaths)/SUM(new_cases))*100,2) AS death_percentage
FROM covid_data
WHERE continent != '0.0';

-- Total cases and total deaths per continent:
CREATE VIEW total_continents AS
SELECT continent, SUM(new_cases) AS confirmed_cases, SUM(new_deaths) AS total_deaths
FROM covid_data
WHERE continent != '0.0' 
GROUP BY continent
ORDER BY confirmed_cases DESC;

-- Daily new cases and new deaths (continents) 
CREATE VIEW daily_cases_deaths AS
SELECT continent, new_date AS date, new_cases AS confirmed_cases, new_deaths AS total_deaths
FROM covid_data
WHERE continent != '0.0';

-- Daily new cases and new deaths (global) 
CREATE VIEW daily_cases_deaths_global AS
SELECT new_date AS date, new_cases AS confirmed_cases, new_deaths AS total_deaths
FROM covid_data
WHERE continent != '0.0';

-- Daily new cases and new deaths (portugal) 
CREATE VIEW daily_cases_deaths_portugal AS
SELECT new_date AS date, new_cases AS confirmed_cases, new_deaths AS total_deaths
FROM covid_data
WHERE continent != '0.0' AND location='Portugal';

-- Total cases by country: 
CREATE VIEW confirmed_cases_by_country AS
SELECT location, MAX(total_cases) AS confirmed_cases
FROM covid_data
WHERE continent != '0.0'
GROUP BY location, population
ORDER BY confirmed_cases DESC; 

-- % of deaths by country: 
CREATE VIEW deaths_by_country AS
SELECT location, ROUND((MAX(total_deaths)/population)*100,4) AS Percent_deaths
FROM covid_data
WHERE continent != '0.0'
GROUP BY location, population
ORDER BY Percent_deaths DESC; 

-- % of cases by country (incidence rate):
CREATE VIEW Pop_Infected_by_country AS
SELECT location, population, ROUND(MAX((total_cases/population)*100),2) AS Percent_Pop_Infected
FROM covid_data
WHERE continent != '0.0'
GROUP BY location, population
ORDER BY Percent_Pop_Infected DESC;

-- mortality rate by country:
CREATE VIEW mortality_rate_by_country AS
SELECT location, ROUND((MAX(total_deaths)/MAX(total_cases))*100,4) AS death_rate
FROM covid_data
WHERE continent != '0.0'
GROUP BY location, population
ORDER BY death_rate DESC; 

--
CREATE VIEW vaccinations_deaths_cases AS
SELECT cv.location, cv.total_vaccinations, cv.new_vaccinations, cv.new_vaccinations_smoothed, cd.new_cases, cd.total_deaths, cd.new_deaths, cd.new_date
FROM covid_vaccinations cv
JOIN covid_data cd ON cv.location = cd.location AND cv.new_date = cd.new_date
ORDER BY cv.location, cd.new_date;