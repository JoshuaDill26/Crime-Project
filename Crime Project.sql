CREATE DATABASE if NOT EXISTS crime;
USE crime;

-- Checking data imported correctly
SELECT * FROM crimeprop;
SELECT * FROM crimevio;

-- Total Violent Crime per State over all Years
SELECT State, SUM(`Violent Crime Total`) as TotVioCri
FROM crimevio
GROUP BY State;

-- Total Violent Crime per Year over all States
SELECT Year, SUM(`Violent Crime Total`) as TotVioCri
FROM crimevio
GROUP BY Year;

-- Temp table to check calculations later
DROP TABLE SumofVio;
CREATE TEMPORARY TABLE SumOfVio
(
		State TEXT,
        VioPerc FLOAT
);

-- General sense of which States had the highest crime overall
INSERT INTO SumOfVio
SELECT State,
(SUM(`Violent Crime Total`) / (SELECT SUM(`Violent Crime Total`) FROM crimevio)) * 100 
as VioPerc
FROM crimevio
GROUP BY state
ORDER BY 2 DESC;

SELECT *
FROM SumOfVio
ORDER BY 2 DESC;

-- Checking calculations
SELECT ROUND((SUM(VioPerc)))
FROM SumOfVio;

-- Ranking the States with the most dangerous at the top
SELECT State, VioPerc, RANK() OVER(ORDER BY VioPerc) as `Violent Crime Rank`
FROM SumOfVio;

-- Reference for Violent Crime per Population
SELECT State, Year, SUM(`Violent Crime Total`) / SUM(`State Population`) * 100
as PercVioPerPop
FROM crimevio
GROUP BY State, Year
ORDER BY 1;

SELECT State, SUM(`Violent Crime Total`) / SUM(`State Population`) * 100
as PercVioPerPop
FROM crimevio
GROUP BY State
ORDER BY 2 DESC;

-- Ratio of Violent Crime to Property Crime
SELECT cv.State, SUM(`Violent Crime Total`)/SUM(`Property Crime Total`) as VioPropRatio
FROM crimevio cv JOIN crimeprop cp
ON cv.State = cp.State
AND cv.Year = cp.Year
GROUP BY State
ORDER BY 2 DESC;

-- State with the hightest Violent:Property Crime ratio (with year displayed)
WITH VioPropCrim (State, Year, VioPropTot)
as
(
SELECT cv.State, cv.Year, (`Violent Crime Total`)/(`Property Crime Total`) as VioPropTot
FROM crimevio cv JOIN crimeprop cp
ON cv.State = cp.State
AND cv.Year = cp.Year
ORDER BY 3 DESC
)
SELECT
State, Year, VioPropTot
FROM (SELECT State, Year, VioPropTot,
               ROW_NUMBER() OVER (ORDER BY VioPropTot DESC) as ranked_order
          FROM VioPropCrim) a
          WHERE a.ranked_order = 1;

-- Total Violent Crime
SELECT
SUM(`Murder Manslaughter`) as TotMan, SUM(`Rape`) as TotRape, 
SUM(`Robbery`) as TotRob, SUM(`Agg Assault`) as TotAgg
FROM crimevio