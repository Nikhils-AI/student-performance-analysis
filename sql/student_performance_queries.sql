-- create students habit performance table
CREATE TABLE student_habits_performance (
	student_id text,
	age smallint,
	gender text,
	study_hours real,
	social_media_hours real,
	netflix_hours real,
	part_time_job text,
	attendance_percentage real,
	sleep_hours real,
	diet_quality text, 
	exercise_frequency smallint,
	parental_education_level text,
	internet_quality text,
	mental_health_rating smallint, 
	extracurricular_participation text,
	exam_score real,
	CONSTRAINT primary_id PRIMARY KEY (student_id)
);

-- copy data from student_habits_performance.csv into table
COPY student_habits_performance 
FROM 'C:\Users\nikhi\code\projects\student-performance-analysis\data\student_habits_performance.csv'
WITH (FORMAT CSV, HEADER);

-- inspect data and check for inconsistencies 
SELECT * FROM student_habits_performance;

	-- check for values out-of-bounds
SELECT max(age) as age, min(age),
	   max(study_hours) as study, min(study_hours),
	   max(social_media_hours) as social_media, min(social_media_hours),
	   max(netflix_hours) as netflix, min(netflix_hours),
	   max(attendance_percentage) as attendance, min(attendance_percentage),
	   max(sleep_hours) as sleep, min(sleep_hours),
	   max(mental_health_rating) as mental_health, min(mental_health_rating),
	   max(exam_score) as exam, min(exam_score)
FROM student_habits_performance;

-- analyze head of data and devise questions
SELECT * FROM student_habits_performance LIMIT 5;

-- Question 1: What is the mean and median exam score?
SELECT round(avg(exam_score)::numeric, 2) AS mean,
	   percentile_cont(.5) WITHIN GROUP (ORDER BY exam_score) AS median
FROM student_habits_performance;

-- Question 2: What is the correlation between exam scores and screen time?
	-- Create new column titled screen_time (social_media_hours + netflix_hours)
ALTER TABLE student_habits_performance ADD COLUMN screen_time real;

	-- Fill screen_time column
UPDATE student_habits_performance
SET screen_time = ROUND((social_media_hours + netflix_hours)::numeric, 2);

	-- Calculate the average and median exam score in all four quartiles of screen_time
WITH percentiles AS (
	SELECT percentile_cont(.25) WITHIN GROUP (ORDER BY screen_time) AS p25,
		   percentile_cont(.5) WITHIN GROUP (ORDER BY screen_time) AS p50,
		   percentile_cont(.75) WITHIN GROUP (ORDER BY screen_time) AS p75
	FROM student_habits_performance
)
		-- Q1 (0 - 25th percentile)
SELECT 'Q1' AS quartile,
	   COUNT(*),
	   round(avg(exam_score)::numeric, 2) AS mean_score,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY exam_score))::numeric, 2) AS median_score
FROM student_habits_performance, percentiles
WHERE screen_time <= p25

UNION ALL
		-- Q2 (25th - 50th percentile)
SELECT 'Q2' AS quartile, 
	   COUNT(*),
	   round(avg(exam_score)::numeric, 2) AS mean_score,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY exam_score))::numeric, 2) AS median_score
FROM student_habits_performance, percentiles
WHERE screen_time > p25 AND screen_time <= p50

UNION ALL 
		-- Q3 (50th - 75th percentile)
SELECT 'Q3' AS quartile, 
	   COUNT(*),
	   round(avg(exam_score)::numeric, 2) AS mean_score,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY exam_score))::numeric, 2) AS median_score
FROM student_habits_performance, percentiles
WHERE screen_time > p50 AND screen_time <= p75

UNION ALL
		-- Q4 (75th - 100th percentile)
SELECT 'Q4' AS quartile, 
	   COUNT(*),
	   round(avg(exam_score)::numeric, 2) AS mean_score,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY exam_score))::numeric, 2) AS median_score
FROM student_habits_performance, percentiles
WHERE screen_time > p75;
	
-- Question 3: What is the correlation between exam scores and mental health ratings?
	-- Calculate the average and median exam score in all four quartiles of mental_health_rating
WITH percentiles AS (
	SELECT percentile_cont(.25) WITHIN GROUP (ORDER BY mental_health_rating) AS p25,
		   percentile_cont(.5) WITHIN GROUP (ORDER BY mental_health_rating) AS p50,
		   percentile_cont(.75) WITHIN GROUP (ORDER BY mental_health_rating) AS p75
	FROM student_habits_performance
)
		-- Q1 (0 - 25th percentile)
SELECT 'Q1' AS quartile, 
	   COUNT(*),
	   round(avg(exam_score)::numeric, 2) AS mean_score,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY exam_score))::numeric, 2) AS median_score
FROM student_habits_performance, percentiles
WHERE mental_health_rating <= p25

UNION ALL
		-- Q2 (25th - 50th percentile)
SELECT 'Q2' AS quartile, 
	   COUNT(*),
	   round(avg(exam_score)::numeric, 2) AS mean_score,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY exam_score))::numeric, 2) AS median_score
FROM student_habits_performance, percentiles
WHERE mental_health_rating > p25 AND mental_health_rating <= p50

UNION ALL 
		-- Q3 (50th - 75th percentile)
SELECT 'Q3' AS quartile, 
	   COUNT(*),
	   round(avg(exam_score)::numeric, 2) AS mean_score,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY exam_score))::numeric, 2) AS median_score
FROM student_habits_performance, percentiles
WHERE mental_health_rating > p50 AND mental_health_rating <= p75

UNION ALL
		-- Q4 (75th - 100th percentile)
SELECT 'Q4' AS quartile, 
	   COUNT(*),
	   round(avg(exam_score)::numeric, 2) AS mean_score,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY exam_score))::numeric, 2) AS median_score
FROM student_habits_performance, percentiles
WHERE mental_health_rating > p75;

-- Question 4: Does parent education level correlate to improved student habits and, as a result, high exam scores?
	-- Check unique values in parental_education_level column
SELECT DISTINCT parental_education_level
FROM student_habits_performance;

	-- Check habits and exam scores throughout all parental education levels
SELECT parental_education_level,
       round(avg(study_hours)::numeric, 2) AS mean_study_hours,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY study_hours))::numeric, 2) AS median_study_hours,
       round(avg(screen_time)::numeric, 2) AS mean_screen_time,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY screen_time))::numeric, 2) AS median_screen_time,
       round(avg(attendance_percentage)::numeric, 2) AS mean_attendance_percentage,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY attendance_percentage))::numeric, 2) AS median_attendance_percentage,
       round(avg(sleep_hours)::numeric, 2) AS mean_sleep_hours,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY sleep_hours))::numeric, 2) AS median_sleep_hours,
       round(avg(exercise_frequency)::numeric, 2) AS mean_exercise_frequency,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY exercise_frequency))::numeric, 2) AS median_exercise_frequency,
       round(avg(exam_score)::numeric, 2) AS mean_exam_score,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY exam_score))::numeric, 2) AS median_exam_score
FROM student_habits_performance
GROUP BY parental_education_level
ORDER BY
	CASE parental_education_level
	WHEN 'None' THEN 1
	WHEN 'High School' THEN 2
	WHEN 'Bachelor' THEN 3
	WHEN 'Master' THEN 4
	ELSE 5
	END;

-- Question 5: What is the correlation between exam scores and sleep?
	-- Calculate the average and median exam score in all four quartiles of sleep_hours
WITH percentiles AS (
	SELECT percentile_cont(.25) WITHIN GROUP (ORDER BY sleep_hours) AS p25,
		   percentile_cont(.5) WITHIN GROUP (ORDER BY sleep_hours) AS p50,
		   percentile_cont(.75) WITHIN GROUP (ORDER BY sleep_hours) AS p75
	FROM student_habits_performance
)
		-- Q1 (0 - 25th percentile)
SELECT 'Q1' AS quartile, 
	   COUNT(*),
	   round(avg(exam_score)::numeric, 2) AS mean_score,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY exam_score))::numeric, 2) AS median_score
FROM student_habits_performance, percentiles
WHERE sleep_hours <= p25

UNION ALL
		-- Q2 (25th - 50th percentile)
SELECT 'Q2' AS quartile, 
	   COUNT(*),
 	   round(avg(exam_score)::numeric, 2) AS mean_score,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY exam_score))::numeric, 2) AS median_score
FROM student_habits_performance, percentiles
WHERE sleep_hours > p25 AND sleep_hours <= p50

UNION ALL 
		-- Q3 (50th - 75th percentile)
SELECT 'Q3' AS quartile, 
	   COUNT(*),
	   round(avg(exam_score)::numeric, 2) AS mean_score,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY exam_score))::numeric, 2) AS median_score
FROM student_habits_performance, percentiles
WHERE sleep_hours > p50 AND sleep_hours <= p75

UNION ALL
		-- Q4 (75th - 100th percentile)
SELECT 'Q4' AS quartile, 
	   COUNT(*),
	   round(avg(exam_score)::numeric, 2) AS mean_score,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY exam_score))::numeric, 2) AS median_score
FROM student_habits_performance, percentiles
WHERE sleep_hours > p75;

-- Question 6: Do students who exercise frequently (at least 3 times per week) have better overall habits and higher exam scores?
	-- Check habits and exam scores of students who exercise at least 3 times per week
SELECT exercise_frequency, 
	   round(avg(study_hours)::numeric, 2) AS mean_study_hours,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY study_hours))::numeric, 2) AS median_study_hours,
       round(avg(screen_time)::numeric, 2) AS mean_screen_time,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY screen_time))::numeric, 2) AS median_screen_time,
       round(avg(attendance_percentage)::numeric, 2) AS mean_attendance_percentage,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY attendance_percentage))::numeric, 2) AS median_attendance_percentage,
       round(avg(sleep_hours)::numeric, 2) AS mean_sleep_hours,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY sleep_hours))::numeric, 2) AS median_sleep_hours,
       round(avg(exam_score)::numeric, 2) AS mean_exam_score,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY exam_score))::numeric, 2) AS median_exam_score
FROM student_habits_performance
WHERE exercise_frequency >= 3
GROUP BY exercise_frequency
ORDER BY exercise_frequency ASC;

-- Question 7: Do students with part-time jobs and/or extracurricular activities have generally better or worse habits? Are they able to study as much as students without jobs or extracurriculars? 
	-- Check habits of students with part-time jobs 
SELECT part_time_job,
	   extracurricular_participation,
	   round(avg(study_hours)::numeric, 2) AS mean_study_hours,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY study_hours))::numeric, 2) AS median_study_hours,
       round(avg(screen_time)::numeric, 2) AS mean_screen_time,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY screen_time))::numeric, 2) AS median_screen_time,
       round(avg(attendance_percentage)::numeric, 2) AS mean_attendance_percentage,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY attendance_percentage))::numeric, 2) AS median_attendance_percentage,
       round(avg(sleep_hours)::numeric, 2) AS mean_sleep_hours,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY sleep_hours))::numeric, 2) AS median_sleep_hours,
	   round(avg(exercise_frequency)::numeric, 2) AS mean_exercise_frequency,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY exercise_frequency))::numeric, 2) AS median_exercise_frequency,
       round(avg(exam_score)::numeric, 2) AS mean_exam_score,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY exam_score))::numeric, 2) AS median_exam_score
FROM student_habits_performance
GROUP BY part_time_job, extracurricular_participation
ORDER BY 
	CASE 
		WHEN part_time_job = 'Yes' AND extracurricular_participation = 'Yes' THEN 1
		WHEN part_time_job = 'Yes' AND extracurricular_participation = 'No' THEN 2
		WHEN part_time_job = 'No' AND extracurricular_participation = 'Yes' THEN 3
		WHEN part_time_job = 'No' AND extracurricular_participation = 'No' THEN 4
		ELSE 5
		END;

-- Question 8: Which gender experiences worse mental health?
	-- Group mean and median mental health ratings by gender
SELECT gender,
	   round(avg(mental_health_rating)::numeric, 2) AS mean_mental_health_rating,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY mental_health_rating))::numeric, 2) AS median_mental_health_rating
FROM student_habits_performance
GROUP BY gender;

-- Question 9: What is the correlation between screen time and sleep hours? Can excessive screen time lead to less sleep?
	-- Calculate the average and median exam score in all four quartiles of sleep_hours
WITH percentiles AS (
	SELECT percentile_cont(.25) WITHIN GROUP (ORDER BY screen_time) AS p25,
		   percentile_cont(.5) WITHIN GROUP (ORDER BY screen_time) AS p50,
		   percentile_cont(.75) WITHIN GROUP (ORDER BY screen_time) AS p75
	FROM student_habits_performance
)
		-- Q1 (0 - 25th percentile)
SELECT 'Q1' AS quartile, 
	   COUNT(*),
	   round(avg(sleep_hours)::numeric, 2) AS mean_sleep,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY sleep_hours))::numeric, 2) AS median_sleep
FROM student_habits_performance, percentiles
WHERE screen_time <= p25

UNION ALL
		-- Q2 (25th - 50th percentile)
SELECT 'Q2' AS quartile, 
	   COUNT(*),
 	   round(avg(sleep_hours)::numeric, 2) AS mean_sleep,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY sleep_hours))::numeric, 2) AS median_sleep
FROM student_habits_performance, percentiles
WHERE screen_time > p25 AND screen_time <= p50

UNION ALL 
		-- Q3 (50th - 75th percentile)
SELECT 'Q3' AS quartile, 
	   COUNT(*),
	   round(avg(sleep_hours)::numeric, 2) AS mean_sleep,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY sleep_hours))::numeric, 2) AS median_sleep
FROM student_habits_performance, percentiles
WHERE screen_time > p50 AND screen_time <= p75

UNION ALL
		-- Q4 (75th - 100th percentile)
SELECT 'Q4' AS quartile, 
	   COUNT(*),
	   round(avg(sleep_hours)::numeric, 2) AS mean_sleep,
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY sleep_hours))::numeric, 2) AS median_sleep
FROM student_habits_performance, percentiles
WHERE screen_time > p75;

