# PROJECT automated data cleaning with schedule
# us_house_inc_2 is the raw data for project 2.

# Create procedure of copying original uncleaned data
# and pasting it in a new table, added with timestamp column.

DELIMITER $$ 
DROP PROCEDURE IF EXISTS copy_and_clean_data;
CREATE PROCEDURE copy_and_clean_data()
BEGIN
-- Creating the table
	CREATE TABLE IF NOT EXISTS `us_house_inc_2_cleaned` (
		  `row_id` int DEFAULT NULL,
		  `id` int DEFAULT NULL,
		  `State_Code` int DEFAULT NULL,
		  `State_Name` text,
		  `State_ab` text,
		  `County` text,
		  `City` text,
		  `Place` text,
		  `Type` text,
		  `Primary` text,
		  `Zip_Code` int DEFAULT NULL,
		  `Area_Code` int DEFAULT NULL,
		  `ALand` int DEFAULT NULL,
		  `AWater` int DEFAULT NULL,
		  `Lat` double DEFAULT NULL,
		  `Lon` double DEFAULT NULL,
		  `TimeStamp` TIMESTAMP DEFAULT NULL
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copying the data in us_house_inc_2 to new table
		INSERT INTO us_house_inc_2_cleaned
		SELECT *, CURRENT_TIMESTAMP
		FROM us_house_inc_2;

-- Insert data cleaning steps
-- Removing Duplicates, and other data quality issues (All of below data cleaning steps were explained in depth in the first project)
	DELETE FROM us_house_inc_2_cleaned 
	WHERE 
		row_id IN (
		SELECT row_id
	FROM (
		SELECT row_id, id,
			ROW_NUMBER() OVER (
				PARTITION BY id, `TimeStamp`
				ORDER BY id, `TimeStamp`) AS row_num
		FROM 
			us_house_inc_2_cleaned
	) duplicates
	WHERE 
		row_num > 1
	);

	UPDATE us_house_inc_2_cleaned
	SET state_name = 'Georgia' 
	WHERE state_name = 'georia';

	UPDATE us_house_inc_2_cleaned
	SET state_name = 'Alabama' 
	WHERE state_name = 'alabama';

	UPDATE us_house_inc_2_cleaned
	SET county = REPLACE(REPLACE(county, 'County', ''), 'Municipio', '');

	UPDATE us_house_inc_2_cleaned
	SET Place = 'Autaugaville' 
	WHERE Place = '';

	UPDATE us_house_inc_2_cleaned
	SET type = 'Borough'
	WHERE type = 'Boroughs';

END $$
DELIMITER ;

# function to call (Run it to create the new table)
CALL copy_and_clean_data();

# New table that has timestamp had been created through copy_and_clean_data() function.
SELECT * FROM us_house_inc_2_cleaned;

-- ---------------------------------------------------
# DEBUGGING - 3 queries to check before after data cleaning PROCEDURE (this is BEFORE table)

-- Query 1
		SELECT row_id, id, row_num
	FROM (
		SELECT row_id, id,
			ROW_NUMBER() OVER (
				PARTITION BY id
				ORDER BY id) AS row_num
		FROM 
			us_house_inc_2
	) duplicates
	WHERE 
		row_num > 1;
-- Query 2
SELECT COUNT(row_id)
FROM us_house_inc_2;

-- Query 3
SELECT state_name, COUNT(state_name)
FROM us_house_inc_2
GROUP BY state_name;

# Redo Query 1, 2, 3 on us_house_inc_2_cleaned after PROCEDURE was done (this is AFTER table)

-- Query 1
		SELECT row_id, id, row_num
	FROM (
		SELECT row_id, id,
			ROW_NUMBER() OVER (
				PARTITION BY id
				ORDER BY id) AS row_num
		FROM 
			us_house_inc_2_cleaned
	) duplicates
	WHERE 
		row_num > 1;
-- Query 2
SELECT COUNT(row_id)
FROM us_house_inc_2_cleaned;

-- Query 3
SELECT state_name, COUNT(state_name)
FROM us_house_inc_2_cleaned
GROUP BY state_name;

# It works, now to the next step
-- --------------------------------------------
# Create the EVENT SCHEDULE (the automated process)

CREATE EVENT run_auto_clean
	ON SCHEDULE EVERY 30 SECOND
    DO CALL copy_and_clean_data();

# This is the code to stop the event from running in loop.
DROP EVENT IF EXISTS run_auto_clean; 
    
-- -----------------
# To check if the code works

SELECT DISTINCT TIMESTAMP  # to check if dataset is updated every certain time
FROM us_house_inc_2_cleaned;

# Below we will see if the table is appended (new time over the time before)
SELECT COUNT(*) from us_house_inc_2_cleaned;

SELECT COUNT(*) FROM us_house_inc;

# Below we will see what are exactly in the columns that have the same row_id (just duplicates with different time stamp)
SELECT *
FROM us_house_inc_2_cleaned where row_id = '1';