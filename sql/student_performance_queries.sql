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


