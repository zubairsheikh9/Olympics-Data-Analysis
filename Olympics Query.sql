-- CREATING OLYMPICS DATABASE 

CREATE DATABASE IF NOT EXISTS Olympics ;

-- SELECTING DATABASE

USE Olympics ;

-- CREATING  TABLES UNDER OLYMPICS DATABASE (Olympics_history)

CREATE TABLE IF NOT EXISTS Olympics_history
(
  Id 		INT,
  Name 		VARCHAR(50),
  Sex 		VARCHAR(50),
  Age 		VARCHAR(50),
  Height 	VARCHAR(50),
  Weight 	VARCHAR(50),
  Team 		VARCHAR(50),
  noc 		VARCHAR(50),
  games	 	VARCHAR(50),
  Year 		INT,
  Season 	VARCHAR(50),
  City 		VARCHAR(50),
  Sport 	VARCHAR(50),
  Event 	VARCHAR(100),
  Medal 	VARCHAR (50)
);
 
 -- CREATING  TABLES UNDER OLYMPICS DATABASE (noc_region)

 CREATE TABLE IF NOT EXISTS noc_region
 (
   noc		VARCHAR(50),
   region	VARCHAR(50),
   notes    VARCHAR(50)
) ;
 
 -- CHECKING TABLE CONTENTS
SELECT * FROM olympics_history LIMIT 10 ;
SELECT * FROM noc_region ;

-- 1. How many olympics games have been held?
-- Problem Statement: Write a SQL query to find the total no of Olympic Games held as per the dataset.

SELECT COUNT(DISTINCT(games)) AS Total_Olympics_Games
FROM olympics_history ;
 
-- 2. List down all Olympics games held so far.
-- Problem Statement: Write a SQL query to list down all the Olympic Games held so far.
 
 SELECT DISTINCT Year, games, City
 FROM olympics_history
 ORDER BY Year ;

-- 3. Mention the total no of nations who participated in each olympics game?
-- Problem Statement: SQL query to fetch total no of countries participated in each olympic games.

WITH all_countries AS
	( SELECT games, region
    FROM olympics_history oh JOIN noc_region nr
    ON oh.noc = nr.noc
    GROUP BY games, region)
SELECT games, COUNT(*) AS Total_Nations
FROM all_countries
GROUP BY games
ORDER BY games ;

-- 4. Which year saw the highest and lowest no of countries participating in olympics
-- Problem Statement: Write a SQL query to return the Olympic Games which had the highest participating countries and the lowest participating countries.

WITH all_countries AS
		(SELECT games, region
		FROM olympics_history oh JOIN noc_region nr
        ON oh.noc = nr.noc
        GROUP BY games, region),
	tot_countries AS 
		(SELECT games, COUNT(*) AS Total_Countries
        FROM all_countries
        GROUP BY games)
SELECT DISTINCT
CONCAT (first_value(games) OVER(ORDER BY Total_Countries),
'-' ,
first_value(Total_Countries) OVER(ORDER BY Total_Countries)) AS LOWEST_COUNTRIES,
CONCAT (first_value(games) OVER(ORDER BY Total_Countries DESC),
'-' ,
first_value(Total_Countries) OVER(ORDER BY Total_Countries DESC)) AS HIGHEST_COUNTRIES
FROM tot_countries
ORDER BY games;

-- 5. Which nation has participated in all of the olympic games
-- Problem Statement: SQL query to return the list of countries who have been part of every Olympics games.

WITH all_games AS
		( SELECT COUNT(DISTINCT(games)) AS Total_Games
        FROM Olympics_History ),
	countries AS
		( SELECT games, region 
        FROM olympics_history oh JOIN noc_region nr
        ON oh.noc = nr.noc
        GROUP BY games, region ),
	countries_participated AS
		( SELECT region AS country , COUNT(*) AS Total_Participation
        FROM countries
        GROUP BY country )
SELECT country, Total_Participation FROM
countries_participated cp JOIN all_games ag
ON cp.Total_Participation = ag.Total_Games 
ORDER BY country ;

-- 6. Identify the sport which was played in all summer olympics.
-- Problem Statement: SQL query to fetch the list of all sports which have been part of every olympics.

WITH t1 AS
		( SELECT COUNT(DISTINCT(games)) AS Total_summer_games
        FROM olympics_history
        WHERE season = 'Summer' ),
	t2 AS
		( SELECT DISTINCT sport, games
        FROM olympics_history 
        WHERE season = 'summer'
        ORDER BY games ),
	t3 AS 
		( SELECT sport, COUNT(games) AS no_of_games
        FROM t2 
        GROUP BY sport )
SELECT * 
FROM t3 JOIN t1
ON t3.no_of_games = t1.Total_summer_games ;

-- 7. Which Sports were just played only once in the olympics.
-- Problem Statement: Using SQL query, Identify the sport which were just played once in all of olympics.

WITH t1 as 
		( SELECT DISTINCT games, sport
        FROM olympics_history ),
	t2 as 
		( SELECT sport, COUNT(*) AS no_of_games
        FROM t1
        GROUP BY sport )
SELECT t2.*, t1.games
FROM t2 JOIN t1
ON t2.sport = t1.sport
WHERE t2.no_of_games = 1
ORDER BY t1.sport ;

-- 8. Fetch the total no of sports played in each olympic games.
-- Problem Statement: Write SQL query to fetch the total no of sports played in each olympics.

WITH t1 as
		( SELECT DISTINCT games, sport
        FROM olympics_history ),
	t2 as 
		( SELECT games, COUNT(*) AS no_of_sports
        FROM t1
        GROUP BY games )
SELECT * 
FROM t2
ORDER BY no_of_sports DESC ;

-- 9. Fetch oldest athletes to win a gold medal.
-- Problem Statement: SQL Query to fetch the details of the oldest athletes to win a gold medal at the olympics.

WITH t1 AS
		( SELECT name, sex, CAST(CASE WHEN age = 'NA' THEN '0' ELSE age END AS UNSIGNED) AS age,
        team, games, city, sport, event, medal
        FROM olympics_history ),
	ranking AS
		( SELECT *,
        RANK() OVER(ORDER BY age desc) AS rnk
        FROM t1 
        WHERE medal = 'Gold' )
SELECT * 
FROM ranking
WHERE rnk = 1 ;

-- 10. Find the Ratio of male and female athletes participated in all olympic games.
-- Problem Statement: Write a SQL query to get the ratio of male and female participants

WITH t1 AS
		( SELECT sex, COUNT(*) AS CNT
        FROM olympics_history
        GROUP BY sex ),
	t2 AS
		( SELECT *, ROW_NUMBER() OVER(ORDER BY CNT) AS rn
        FROM t1 ),
	min_cnt AS
		( SELECT CNT FROM t2 WHERE rn = 1 ),
	max_cnt AS
		(SELECT CNT FROM t2 WHERE rn = 2 )
SELECT CONCAT('1 : ', round(max_cnt.CNT/min_cnt.CNT,2)) AS ratio
FROM min_cnt, max_cnt ;
	
-- 11. Fetch the top 5 athletes who have won the most gold medals.
-- Problem Statement: SQL query to fetch the top 5 athletes who have won the most gold medals.

SELECT Name, Team, COUNT(*) AS no_of_medals
FROM olympics_history
WHERE medal = 'gold'
GROUP BY Name
ORDER BY no_of_medals DESC
LIMIT 5 ;

-- 12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
-- Problem Statement: SQL Query to fetch the top 5 athletes who have won the most medals (Medals include gold, silver and bronze).

SELECT Name, Team, COUNT(*) AS total_no_medals
FROM olympics_history
WHERE medal in ('Gold','Silver','bronze')
GROUP BY name
ORDER BY total_no_medals DESC
LIMIT 5 ;

-- 13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
-- Problem Statement: Write a SQL query to fetch the top 5 most successful countries in olympics. (Success is defined by no of medals won).

WITH t1 AS 
		( SELECT nr.region, COUNT(*) AS Total_medals
        FROM olympics_history oh JOIN noc_region nr
        ON oh.noc = nr.noc
        WHERE medal <> 'NA'
        GROUP BY nr.region
        ORDER BY Total_medals DESC ),
	t2 AS
		( SELECT *,
        DENSE_RANK() OVER( ORDER BY Total_Medals DESC ) AS rn
        FROM t1 )
SELECT * FROM t2
WHERE rn <=5 ;


-- 14. Break down all olympic games where India won medal for Hockey and how many medals in each olympic games
-- Problem Statement: Write an SQL Query to fetch details of all Olympic Games where India won medal(s) in hockey. 

SELECT nr.region, sport, games, COUNT(*) AS Total_Medals
        FROM olympics_history oh JOIN noc_region nr
        ON oh.noc = nr.noc
        WHERE nr.region = 'India' AND sport = 'hockey'AND medal <> 'NA'
        GROUP BY nr.region, sport, games
        ORDER BY total_medals DESC;
		
-- 15. In which Sport/event, India has won highest medals.
-- Problem Statement: Write SQL Query to return the sport which has won India the highest no of medals. 

SELECT sport, COUNT(*) AS Total_Medals 
FROM olympics_history Oh JOIN noc_region nr
ON oh.noc = nr.noc
WHERE nr.region = 'India' AND medal <> 'NA'
GROUP BY sport
ORDER BY total_medals DESC
LIMIT 1 ;

-- -- -- -- --








