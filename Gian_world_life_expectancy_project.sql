# Gian's MYSQL Project
	# You are a data analyst for a research company.
    # You are to clean the data and do Exploratory Data Analysis.

-- -------------------------------------------------------------

# Step 1. Creating world_life_expectancy schema, using Table Data Import Wizard to insert world_life_expectancy.csv
SELECT * FROM world_life_expectancy LIMIT 5;

-- ------------------------------------------------------------

# Step 2. Data Cleaning
	# A. Removing duplicates
	# the plan is to utilize country and year for this
    # as from observation each row is supposed to be country and year from 2007 - 2022. It is not supposed to be duplicated.

	# A.1 using subqueries, concat, groupby, where functions. Identified 3 duplicates (Ireland2022, Senegal2009, Zimbabwe2019)

SELECT *
FROM	(SELECT CONCAT(Country,Year) AS country_year, 
		COUNT(CONCAT(Country,Year)) AS count_country_year 
		FROM world_life_expectancy
		GROUP BY CONCAT(Country, Year)) AS country_year_table 
WHERE  count_country_year > 1;

	# A.2 Determine which ROW_ID the duplicates are so we can delete it

SELECT *
FROM 	(SELECT row_id,
		CONCAT(Country, Year),
		ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS row_num
        FROM world_life_expectancy) AS row_table
WHERE row_num > 1;

	#A.3 We will delete the rows now because we know row_id 1252, 2265, 2929 holds the duplicate

DELETE FROM world_life_expectancy
WHERE row_id IN (SELECT row_id
				 FROM 	(SELECT row_id,
						CONCAT(Country, Year),
						ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS row_num
						FROM world_life_expectancy) AS row_table
				 WHERE row_num > 1);

	# A.4 Try running code A.2, it will be empty as duplicates are deleted.

	# B. Identifying blanks (there are 18 columns)
SELECT * FROM world_life_expectancy;

	# To be safe, run blank checks on all 18 columns. 
    # Conclusion status and life expectancy each have 8 and 2 blanks. Others have 0 but not blanks.
SELECT * FROM world_life_expectancy WHERE Country = '';
SELECT * FROM world_life_expectancy WHERE Year = '';
SELECT * FROM world_life_expectancy WHERE Status = '';						-- 8 blanks
SELECT * FROM world_life_expectancy WHERE `Life Expectancy` = '';			-- 2 blanks
SELECT * FROM world_life_expectancy WHERE `Adult Mortality` = '';			-- 10 'zeroes'
SELECT * FROM world_life_expectancy WHERE `infant deaths` = '';				-- many 'zeroes'
SELECT * FROM world_life_expectancy WHERE `percentage expenditure` = ''; 	-- many 'zeroes'
SELECT * FROM world_life_expectancy WHERE Measles = '';						-- many 'zeroes'
SELECT * FROM world_life_expectancy WHERE BMI = '';							-- many 'zeroes'
SELECT * FROM world_life_expectancy WHERE `under-five deaths` = '';			-- many 'zeroes'			
SELECT * FROM world_life_expectancy WHERE Polio = '';						-- many 'zeroes'
SELECT * FROM world_life_expectancy WHERE Diphtheria = '';					-- some 'zeroes'
SELECT * FROM world_life_expectancy WHERE `HIV/AIDS` = '';					 -- many 'zeroes'
SELECT * FROM world_life_expectancy WHERE GDP = '';
SELECT * FROM world_life_expectancy WHERE `thinness  1-19 years` = '';		-- some 'zeroes'
SELECT * FROM world_life_expectancy WHERE `thinness 5-9 years` = '';		-- some 'zeroes'
SELECT * FROM world_life_expectancy WHERE Schooling = '';					-- some 'zeroes'
SELECT * FROM world_life_expectancy WHERE row_id = '';						

	# B.1 FIX STATUS. Let us update information in blank spaces.
    # Running the code below, we see 2 distinct (developing, developed) and 1 blank.
SELECT DISTINCT (status)
FROM world_life_expectancy;

	# B.2. determining developed countries based on existing data
SELECT DISTINCT (country)
FROM world_life_expectancy
WHERE status = 'Developing';

SELECT DISTINCT (country)
FROM world_life_expectancy
WHERE status = 'Developed';

	# B.3. Updating developing and developed country list
    # it looks confusing but I just copied the result from B.2.
UPDATE world_life_expectancy
SET status = 'Developing'
WHERE country IN (
    'Afghanistan', 'Albania', 'Algeria', 'Angola', 'Antigua and Barbuda', 'Argentina', 
    'Armenia', 'Azerbaijan', 'Bahamas', 'Bahrain', 'Bangladesh', 'Barbados', 
    'Belarus', 'Belize', 'Benin', 'Bhutan', 'Bolivia (Plurinational State of)', 
    'Bosnia and Herzegovina', 'Botswana', 'Brazil', 'Brunei Darussalam', 
    'Burkina Faso', 'Burundi', 'Cabo Verde', 'Cambodia', 'Cameroon', 'Canada', 
    'Central African Republic', 'Chad', 'Chile', 'China', 'Colombia', 'Comoros', 
    'Congo', 'Cook Islands', 'Costa Rica', 'Cuba', 'Côte d\'Ivoire', 
    'Democratic People\'s Republic of Korea', 'Democratic Republic of the Congo', 
    'Djibouti', 'Dominica', 'Dominican Republic', 'Ecuador', 'Egypt', 'El Salvador', 
    'Equatorial Guinea', 'Eritrea', 'Estonia', 'Ethiopia', 'Fiji', 'Finland', 
    'France', 'Gabon', 'Gambia', 'Georgia', 'Ghana', 'Greece', 'Grenada', 
    'Guatemala', 'Guinea', 'Guinea-Bissau', 'Guyana', 'Haiti', 'Honduras', 'India', 
    'Indonesia', 'Iran (Islamic Republic of)', 'Iraq', 'Israel', 'Jamaica', 'Jordan', 
    'Kazakhstan', 'Kenya', 'Kiribati', 'Kuwait', 'Kyrgyzstan', 'Lao People\'s Democratic Republic', 
    'Lebanon', 'Lesotho', 'Liberia', 'Libya', 'Madagascar', 'Malawi', 'Malaysia', 
    'Maldives', 'Mali', 'Marshall Islands', 'Mauritania', 'Mauritius', 'Mexico', 
    'Micronesia (Federated States of)', 'Monaco', 'Mongolia', 'Montenegro', 
    'Morocco', 'Mozambique', 'Myanmar', 'Namibia', 'Nauru', 'Nepal', 'Nicaragua', 
    'Niger', 'Nigeria', 'Niue', 'Oman', 'Pakistan', 'Palau', 'Panama', 'Papua New Guinea', 
    'Paraguay', 'Peru', 'Philippines', 'Qatar', 'Republic of Korea', 'Republic of Moldova', 
    'Russian Federation', 'Rwanda', 'Saint Kitts and Nevis', 'Saint Lucia', 
    'Saint Vincent and the Grenadines', 'Samoa', 'San Marino', 'Sao Tome and Principe', 
    'Saudi Arabia', 'Senegal', 'Serbia', 'Seychelles', 'Sierra Leone', 'Solomon Islands', 
    'Somalia', 'South Africa', 'South Sudan', 'Sri Lanka', 'Sudan', 'Suriname', 
    'Swaziland', 'Syrian Arab Republic', 'Tajikistan', 'Thailand', 
    'The former Yugoslav republic of Macedonia', 'Timor-Leste', 'Togo', 'Tonga', 
    'Trinidad and Tobago', 'Tunisia', 'Turkey', 'Turkmenistan', 'Tuvalu', 
    'Uganda', 'Ukraine', 'United Arab Emirates', 'United Republic of Tanzania', 
    'Uruguay', 'Uzbekistan', 'Vanuatu', 'Venezuela (Bolivarian Republic of)', 
    'Viet Nam', 'Yemen', 'Zambia', 'Zimbabwe'
);

UPDATE world_life_expectancy
SET status = 'Developed'
WHERE country IN ('Australia' ,'Austria', 'Belgium', 'Bulgaria', 'Croatia'
, 'Cyprus', 'Czechia', 'Denmark', 'Germany', 'Hungary', 'Iceland', 'Ireland', 'Italy', 'Japan'
, 'Latvia', 'Lithuania', 'Luxembourg', 'Malta', 'Netherlands', 'New Zealand', 'Norway', 'Poland'
, 'Portugal', 'Romania', 'Singapore', 'Slovakia', 'Slovenia', 'Spain', 'Sweden', 'Switzerland'
, 'United Kingdom of Great Britain and Northern Ireland', 'United States of America');

	# To check run the code below. 
    # It is empty now. Previously 8 blanks
SELECT * FROM world_life_expectancy WHERE Status = '';

	# C.1. Fix Life_expectancy that has 2 blanks.
	# From query above, we know Afghanistan 2018, Albania 2018 is empty
    # Analyze it further by pulling all Afghanistan and Albania data and ordering it by country, year
    # Interestingly Life expectancy have a pattern of gradual increase.alter
    # Will attempt to insert middle number to life expectancy

SELECT * 
FROM world_life_expectancy
WHERE Country IN ('Afghanistan', 'Albania')
ORDER BY country, year DESC;

	# C.2. Average-ing Afghanistan's 2017, 2019 for afg_life_expectancy_2018 
SELECT AVG(`Life expectancy`) as afg_life_expectancy_2018
FROM world_life_expectancy
WHERE Country = 'Afghanistan' AND Year IN (2017, 2019);

	# C.3 Average-ing Albania's 2017, 2019 for its 2018 life expectancy
SELECT AVG(`Life expectancy`) as alb_life_expectancy_2018
FROM world_life_expectancy
WHERE Country = 'Albania' AND Year IN (2017, 2019);

	# C.4 Update Afghanistan 2018 life expectancy
UPDATE world_life_expectancy
SET `Life expectancy` = 
	(SELECT AVG(`Life expectancy`) AS afg_life_expectancy_2018
	FROM world_life_expectancy
	WHERE Country = 'Afghanistan' AND Year IN (2017, 2019))
WHERE Country = 'Afghanistan' AND Year = 2018;

	# I hit error 1093: MYSQL doesnt allow updating the same table that is used in the select statement in same query
    # Attempt workaround with temporary table

CREATE TEMPORARY TABLE temp_afg_life_expectancy_2018 AS
	SELECT AVG(`Life expectancy`) AS afg_life_expectancy_2018
	FROM world_life_expectancy
	WHERE Country = 'Afghanistan' AND Year IN (2017, 2019);

	# Now - retry C.4 to update afghanistan 2018 life expectancy with temporary table number

UPDATE world_life_expectancy
SET `Life expectancy` = ROUND((SELECT afg_life_expectancy_2018 FROM temp_afg_life_expectancy_2018),1)
WHERE Country = 'Afghanistan' AND Year = 2018;

DROP TEMPORARY TABLE temp_afg_life_expectancy_2018;

	# Checking with C.1. code. It works! Now repeat for Albania
SELECT * 
FROM world_life_expectancy
WHERE Country IN ('Afghanistan', 'Albania')
ORDER BY country, year DESC;

	# C.5 Update Albania life_expectancy 2018

CREATE TEMPORARY TABLE temp_alb_life_expectancy_2018 AS
SELECT AVG(`Life expectancy`) AS alb_life_expectancy_2018
FROM world_life_expectancy
WHERE Country = 'Albania' AND Year IN (2017, 2019);

UPDATE world_life_expectancy
SET `Life expectancy` = ROUND((SELECT alb_life_expectancy_2018 FROM temp_alb_life_expectancy_2018),1)
WHERE Country = 'Albania' AND Year = 2018;

DROP TEMPORARY TABLE temp_alb_life_expectancy_2018;

# Upon current observation in general the data looks to be good. No need for standarization, no more blanks
# However if problems are found when doing EDA, will fix it there.

-- --------------------------------------------------------------------

# Step 3. Exploratory Data Analysis (EDA)

SELECT * FROM world_life_expectancy;

	# A. observing how much life expectancy increases/ decreases for each country
    # In the process, determined Dominica, Marshall Islands, Monaco, Nauru, Niue, Palau
	# Saint Kitts and Nevis, San Marino, Tuval data do not exists for life expectancy.

SELECT * FROM world_life_expectancy WHERE `Life expectancy` = 0;

SELECT Country, 
Status,
MIN(`Life expectancy`) AS lowest_life_expectancy, 
MAX(`Life expectancy`) AS highest_life_expectancy, 
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),2) AS years_life_expectancy_growth, 
ROUND((MAX(`Life expectancy`) - MIN(`Life expectancy`))*100,2) AS percent_life_expectancy_growth 
FROM world_life_expectancy
GROUP BY Country, Status
HAVING MIN(`Life expectancy`) != 0 AND MAX(`Life expectancy`) != 0
ORDER BY percent_life_expectancy_growth ASC;

	# Obtained interesting information: Haiti had the highest % life expectancy growth of 2870% for the past 15 years.
    # Followed by Zimbabwe, Eritrea, Uganda, Botswana (all developing countries)
    # The lowest % life expectancy growth is Guyana of 130% in 15 years,
    # followed by Seychelles, Kuwait, Venezuela, and Philippines (all also developing).
   
	# Worth to note least growth country's lowest life expectancy was already high (65 above).
	# Meanwhile haiti, zimbabwe etc started from 36 expectectancy or 40. So it makes sense.
    
    # B. World average how much increase in 15 years?
    SELECT Year,
    ROUND(AVG(`Life expectancy`),2) AS avg_life_expectancy
    FROM world_life_expectancy
    WHERE `Life expectancy` != 0 	-- just in case
    GROUP BY Year
    ORDER BY avg_life_expectancy DESC;
    
    # The world 2007 average was 66.75, 2022 average was 71.62. About 5% growth.
    # The trend every year is always increasing. Never decreasing. 
    # 2 interesting thing to note: in a glance 2008-2010, 2021-2022 increase was quite low (0.2 or less)
    # Perhaps could be attributed to global economic recession and COVID-19 pandemic
    
    # C.1 Finding Correlation between avg_life_expectancy and GDP

SELECT Country,
ROUND(AVG(`Life expectancy`),2) AS avg_life_exp,
ROUND(AVG(GDP),2) AS avg_GDP
FROM world_life_expectancy
GROUP BY Country
HAVING avg_life_exp != 0 AND avg_GDP != 0
ORDER BY avg_GDP ASC;

	# On a glance, 10 lowest average GDP's life expectancy are only about 50 in average
    # Meanwhile 10 highest average GDP's life expectancy are about 80 in average.
    # Definitely seemed like there is correlation, but should be visualized with POWER BI, Excel, Tableau to see it clearly

	# C.2 Dig a little deeper with GDP and world life expectancy
    # Now let's try to divide GDP into 2 groups (high and low) by about half. Around 1200 as GDP

SELECT
SUM(CASE WHEN GDP >= 1200 THEN 1 ELSE 0 END) AS high_GDP_count,
AVG(CASE WHEN GDP >= 1200 THEN `Life expectancy` ELSE NULL END) AS high_GDP_life_exp,
SUM(CASE WHEN GDP <= 1200 THEN 1 ELSE 0 END) AS low_GDP_count,
AVG(CASE WHEN GDP <= 1200 THEN `Life expectancy` ELSE NULL END) AS low_GDP_life_exp
FROM world_life_expectancy;

	# We can see that high GDP life expectancy is around 73.7 meanwhile low GDP life expectancy around 64.4
    # Stark difference!

	# D. Correlation between Status and average_life_expectancy
SELECT Status, 
ROUND(AVG(`life expectancy`),2) AS average_life_exp,
COUNT(DISTINCT Country) AS count_countries
FROM world_life_expectancy
GROUP BY Status;
	# Developing has 67 years average, Developed has 79.2 average. 12.2 years difference between 
    # developed and developing countries. However developed only 32, developing 161.
    # This makes developed easier to maintain higher average (skewed).alter
SELECT * FROM world_life_expectancy;
	# E. Correlation between BMI and average_life_expectancy
    # E.1 Observe BMI of each country and their life expectancy
SELECT Country, 
ROUND(AVG(BMI),1) AS avg_BMI, 
ROUND(AVG(`Life expectancy`),1) AS avg_life_expectancy
FROM world_life_expectancy
GROUP BY Country
HAVING avg_BMI != 0 AND avg_life_expectancy != 0
ORDER BY avg_life_expectancy ASC;
	# The number kind of surprised me I am not gonna lie.
    # My hypotheses is that higher BMI = unhealthy since it may lead to easier heart attacks, higher cholesterol, etc
    # But Looking at many of the highest avg_life_expectancy have 50+ BMI, can make sense because food are accessible
    # Meanwhile looking at lowest avg_life expectancy group. Many have BMI below 20. This makes me hypothesize 
    # that possible the low avg life expectancy because many deaths came from hunger.
	# It seems like for perhaps hunger > potential illnesses from high BMI in terms of taking life.
    
    # E.2 Observing BMI against life expectancy
SELECT
SUM(CASE WHEN BMI >= 43 THEN 1 ELSE 0 END) AS high_BMI_count,
AVG(CASE WHEN BMI >= 43 THEN `Life expectancy` ELSE NULL END) AS high_BMI_life_exp,
SUM(CASE WHEN BMI <= 43 THEN 1 ELSE 0 END) AS low_BMI_count,
AVG(CASE WHEN BMI <= 43 THEN `Life expectancy` ELSE NULL END) AS low_BMI_life_exp
FROM world_life_expectancy;

	# This reconfirms E.1 analysis. High avg BMI has much higher life expectancy
    # Low avg BMI has much lower life expectancy.

	# F. Adult Mortality & Life expectancy correlation
SELECT Country,
Year,
Status,
`Life expectancy`,
`Adult mortality`
FROM world_life_expectancy
WHERE `Life expectancy` AND `Adult mortality` != 0
;

SELECT
SUM(CASE WHEN `Adult mortality` >= 143 THEN 1 ELSE 0 END) AS high_adultmort_count,
AVG(CASE WHEN `Adult mortality` >= 143 THEN `Life expectancy` ELSE NULL END) AS high_adultmort_life_exp,
SUM(CASE WHEN `Adult mortality` <= 143 THEN 1 ELSE 0 END) AS low_adultmort_count,
AVG(CASE WHEN `Adult mortality` <= 143 THEN `Life expectancy` ELSE NULL END) AS low_adultmort_life_exp
FROM world_life_expectancy;

	# Glancing through the data
    # until quite recently. Very curious of 2010-2012 in Zimbabwe as they had the highest adult mortality rate in the world
    # amongst all countries and all period.
    # All high adult mortality rate countries are all developing (at least bottom 100 from the row)alter
    # Meanwhile many developed countries are among lowest adult mortality rate and rolling total.
    
SELECT Country,
AVG(`Life expectancy`),
AVG(`Adult mortality`)
FROM world_life_expectancy
WHERE `Life expectancy` AND `Adult mortality` != 0
GROUP BY Country
ORDER BY AVG(`Adult mortality`) ASC
;

SELECT
SUM(CASE WHEN `Adult mortality` >= 143 THEN 1 ELSE 0 END) AS high_adultmort_count,
AVG(CASE WHEN `Adult mortality` >= 143 THEN `Life expectancy` ELSE NULL END) AS high_adultmort_life_exp,
SUM(CASE WHEN `Adult mortality` <= 143 THEN 1 ELSE 0 END) AS low_adultmort_count,
AVG(CASE WHEN `Adult mortality` <= 143 THEN `Life expectancy` ELSE NULL END) AS low_adultmort_life_exp
FROM world_life_expectancy;

	#G. Schooling years and life expectancy
SELECT Country,
AVG(`Life expectancy`),
AVG(schooling)
FROM world_life_expectancy
WHERE `Life expectancy` AND schooling != 0
GROUP BY country
ORDER BY AVG(schooling) DESC;

SELECT
SUM(CASE WHEN schooling >= 12.1 THEN 1 ELSE 0 END) AS high_school_count,
AVG(CASE WHEN schooling >= 12.1 THEN `Life expectancy` ELSE NULL END) AS high_school_life_exp,
SUM(CASE WHEN schooling <= 12.1 THEN 1 ELSE 0 END) AS low_school_count,
AVG(CASE WHEN schooling <= 12.1 THEN `Life expectancy` ELSE NULL END) AS low_school_life_exp
FROM world_life_expectancy;

# The result is surprising. I think this might be the factor that impacted the most when compared to other variables I checked.
# Apparently number of years of schooling impacts life expectancy a lot. by 12.1 years!
