use project_3;
select * from job_data;

# ---------------------A. Job reviewed over time:-----------------
#--------- Calculate the number of jobs reviewed per hour for each day in November 2020.-----------

SELECT 
    ds AS date,
    COUNT(job_id) AS no_job_id,
    sum(time_spent)/3600 as hours
FROM
    job_data
WHERE
    ds >= '2020-11-01'
        AND ds <= '2020-11-30'
GROUP BY ds
ORDER BY ds;

#-------------------- B. Throughput Analysis:----------------------------
#------------ Calculate the 7-day rolling average of throughput (number of events per second).--------------

SELECT 
    ds AS date,
    ROUND(COUNT(event) / SUM(time_spent), 2) AS daily_throughput,
    (SELECT 
            ROUND(COUNT(event) / SUM(time_spent), 2)
        FROM
            job_data) AS 7_day_rolling_avg
FROM
    job_data
GROUP BY ds
ORDER BY ds;
    
#----------------- C. Language Share Analysis:--------------------
#--------- Calculate the percentage share of each language in the last 30 days.-----------   
 
SELECT 
    language,
    SUM(time_spent) / (SELECT 
            SUM(time_spent)
        FROM
            job_data) * 100 AS percentage
FROM
    job_data
GROUP BY language
ORDER BY percentage DESC;

#------------ D. Duplicate Rows Detection:------------
# -----------Identify duplicate rows in the data.-------------

SELECT 
    actor_id, COUNT(actor_id) AS No_of_Duplicates
FROM
    job_data
GROUP BY actor_id
HAVING No_of_Duplicates > 1;



    
