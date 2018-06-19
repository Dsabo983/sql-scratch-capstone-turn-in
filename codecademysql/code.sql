--understanding the quiz table
SELECT *
FROM quiz
LIMIT 10;

--counting how many users complete each question in quiz
SELECT question, COUNT(DISTINCT user_id)
FROM survey
GROUP BY question;

--converting users who complete each question into a completion percentage
WITH quiz_funnel AS (
SELECT question, COUNT(DISTINCT user_id) AS 'user_id'
FROM survey
GROUP BY question)

SELECT question, user_id,
	 user_id*1.0 / (SELECT max(user_id)
                 FROM quiz_funnel) 
  AS 'completion %'
FROM quiz_funnel
GROUP BY question;

--understanding the three tables for the home try on funnel
SELECT * FROM quiz LIMIT 5;
SELECT * FROM home_try_on LIMIT 5;
SELECT * FROM purchase LIMIT 5;


--totaling up the total users who complete each step i.e the home try on funnel
WITH funnels AS (
 SELECT DISTINCT q.user_id,
   h.user_id IS NOT NULL AS 'is_home_try_on',
   p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz q
LEFT JOIN home_try_on h
   ON q.user_id = h.user_id
LEFT JOIN purchase p
   ON p.user_id = q.user_id
  )

SELECT COUNT(*) AS 'quiz_users',
	COUNT (CASE
  	WHEN is_home_try_on = 1 THEN user_id
        ELSE NULL
        END) AS 'num_home_try_on',
  COUNT (CASE
        WHEN is_purchase = 1 THEN user_id
        ELSE NULL
        END) AS 'num_purchased'
  FROM funnels;


--creating new table view for AB analysis 
SELECT DISTINCT q.user_id,
   h.user_id IS NOT NULL AS 'is_home_try_on',
   h.number_of_pairs,
   p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz q
LEFT JOIN home_try_on h
   ON q.user_id = h.user_id
LEFT JOIN purchase p
   ON p.user_id = q.user_id
LIMIT 10;

--identifying how many users purchased who recieved 3 pairs vs 5 pairs
WITH AB_analysis AS (
  SELECT DISTINCT q.user_id,
   h.user_id IS NOT NULL AS 'is_home_try_on',
   h.number_of_pairs,
   p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz q
LEFT JOIN home_try_on h
   ON q.user_id = h.user_id
LEFT JOIN purchase p
   ON p.user_id = q.user_id
) 
SELECT number_of_pairs, 
	COUNT(CASE
        WHEN is_purchase = 1 THEN user_id
       END) AS 'purchased'
FROM AB_analysis
GROUP BY number_of_pairs;

--adding percentages to AB analysis 
WITH AB_analysis AS (
  SELECT DISTINCT q.user_id,
   h.user_id IS NOT NULL AS 'is_home_try_on',
   h.number_of_pairs,
   p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz q
LEFT JOIN home_try_on h
   ON q.user_id = h.user_id
LEFT JOIN purchase p
   ON p.user_id = q.user_id
) 
SELECT number_of_pairs, 
	COUNT(CASE
        WHEN is_purchase = 1 THEN user_id
       END) AS 'purchased',
  COUNT(CASE
        WHEN is_purchase = 1 THEN user_id
       END) *1.0 /
 ((SELECT COUNT(DISTINCT user_id) FROM home_try_on)*.50) AS '% who purchased'
FROM AB_analysis
GROUP BY number_of_pairs;

