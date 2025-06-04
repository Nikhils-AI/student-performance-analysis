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
SET screen_time = round((social_media_hours + netflix_hours)::numeric, 2);

	-- 25th, 50th, and 75th percentiles of screen_time compared to exam_scores
WITH percentile ()
SELECT round((percentile_cont(.25) WITHIN GROUP (ORDER BY screen_time))::numeric, 2) AS percentile_25,
	   round(avg(exam_score)::numeric, 2) AS mean_exam, 
	   round((percentile_cont(.5) WITHIN GROUP (ORDER BY exam_score))::numeric, 2) AS median_exam
FROM student_habits_performance
WHERE screen_time >= percentile_25;

round((percentile_cont(.5) WITHIN GROUP (ORDER BY screen_time))::numeric, 2) AS percentile_50,
	   round((percentile_cont(.75) WITHIN GROUP (ORDER BY screen_time))::numeric, 2) AS percentile_75

