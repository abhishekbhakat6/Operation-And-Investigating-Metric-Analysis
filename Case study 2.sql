/** ------------------------CASE STUDY 2--------------------**/
/*------------------Investigating Metric Spike---------------------*/

/*-----Creating The Tables And Importing the data into the tables------*/
use project_3;
/*----------------Table 1 Users----------------*/

CREATE TABLE users (
    user_id INT,
    created_at VARCHAR(100),
    company_id INT,
    language VARCHAR(50),
    activated_at VARCHAR(50),
    state VARCHAR(50)
);

show variables like 'secur_file_priv';

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users.csv"
into table users
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;


SELECT 
    *
FROM
    users;
alter table users add column temp datetime;
UPDATE users 
SET 
    temp = STR_TO_DATE(created_at, '%d-%m-%Y %H:%i');
alter table users drop column created_at;
alter table users change column temp created_at datetime;


/*------------------Table 2 events-----------------*/

CREATE TABLE events (
    user_id INT,
    occurred_at VARCHAR(100),
    event_type VARCHAR(100),
    event_name VARCHAR(100),
    location VARCHAR(100),
    device VARCHAR(100),
    user_type INT
);

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/events.csv"
into table events
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;


SELECT 
    *
FROM
    events;
alter table events add column temp datetime;
UPDATE events 
SET 
    temp = STR_TO_DATE(occurred_at, '%d-%m-%Y %H:%i');
alter table events drop column occurred_at;
alter table events change column temp occurred_at datetime;

/*-------------------Table 3 email_events-------------*/

CREATE TABLE email_events (
    user_id INT,
    occurred_at VARCHAR(100),
    action VARCHAR(100),
    user_type INT
);

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/email_events.csv"
into table email_events
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

SELECT 
    *
FROM
    email_events;
alter table email_events add column temp datetime;
UPDATE email_events 
SET 
    temp = STR_TO_DATE(occurred_at, '%d-%m-%Y %H:%i');
alter table email_events drop column occurred_at;
alter table email_events change column temp occurred_at datetime;


/*------------- Task-1 : Weekly User Engagement:-----------------
Objective: Measure the activeness of users on a weekly basis.
Write an SQL query to calculate the weekly user engagement.*/

SELECT 
    EXTRACT(WEEK FROM occurred_at) AS week_no,
    COUNT(DISTINCT user_id) AS no_of_users
FROM
    events
WHERE
    event_type = "engagement"
GROUP BY week_no
ORDER BY week_no;

/*------------------Task-2 : User Growth Analysis :---------------
Objective : Analyze the growth of users over time for a product.
Write an SQL query to calculate the user growth for the product.*/

    
SELECT
	year, week_no, no_of_users, SUM(no_of_users)
    OVER (order by year, week_no ) AS user_growth
FROM
   ( SELECT 
    EXTRACT(YEAR FROM created_at) AS year,
    EXTRACT(WEEK FROM created_at) AS week_no,
    COUNT(DISTINCT user_id) AS no_of_users
FROM
    users
GROUP BY year , week_no
ORDER BY year , week_no) as temp_table;

        
/*-----------------Task-3 : Weekely Retention Analysis------------
Objective: Analyze the retention of users on a weekly basis after signing up for a product.
Write an SQL query to calculate the weekly retention of users based on their sign-up cohort.*/


with cte1 as (
SELECT DISTINCT
    user_id, EXTRACT(WEEK FROM occurred_at) AS sign_up_week
FROM
    events
where event_type = 'signup_flow'
 and event_name = 'complete_signup'
 and extract(week from occurred_at) = 18),
cte2 as (SELECT DISTINCT
    user_id, EXTRACT(WEEK FROM occurred_at) AS engagement_week
FROM
    events
where event_type = 'engagement')
select count(user_id) as total_engaged_user,
sum(case when retention_week = 1 then 1 else 0 end) as retained_users
from (
SELECT 
    a.user_id,
    a.sign_up_week,
    b.engagement_week,
    b.engagement_week - a.sign_up_week AS retention_week
FROM
    cte1 a
left join cte2 b
on a.user_id = b.user_id
order by a.user_id) sub;


/*--------------------Task-4 : Weekly Engagement Per Device:---------------------
Objective: Measure the activeness of users on a weekly basis per device.
Write an SQL query to calculate the weekly engagement per device.*/

SELECT 
    EXTRACT(WEEK FROM occurred_at) AS week_no,
    device,
    COUNT(DISTINCT user_id) AS no_of_users
FROM
    events
GROUP BY week_no , device
ORDER BY week_no;



/*--------------------Task-5 : Email Engagement Analysis : ------------------
Objective: Analyze how users are engaging with the email service.
Write an SQL query to calculate the email engagement metrics.*/

SELECT 
    WEEK(occurred_at) AS Week_no,
    COUNT(DISTINCT (CASE
            WHEN action = 'sent_weekly_digest' THEN user_id
        END)) AS sent_weekely_digest,
    COUNT(DISTINCT (CASE
            WHEN action = 'email_open' THEN user_id
        END)) AS email_open,
    COUNT(DISTINCT (CASE
            WHEN action = 'email_clickthrough' THEN user_id
        END)) AS email_clickthrough,
    COUNT(DISTINCT (CASE
            WHEN action = 'sent_reengagement_email' THEN user_id
        END)) AS sent_reengagement_email
FROM
    email_events
GROUP BY Week_no
ORDER BY Week_no;



