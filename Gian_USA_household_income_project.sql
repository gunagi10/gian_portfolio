# Gian's MYSQL project US Household Income

-- ----------------------------------------------------------------------

# STEP 1. Create New Schema 'USA_income_proj', use Table Data Import Wizard to import 2 CSV files
			# a. USA Household Income file
			# b. USA Household Income Statistics file

SELECT * FROM us_house_inc LIMIT 5;

SELECT * FROM us_house_inc_stats LIMIT 5;
# us_house_inc_stats has some symbols on first column title, let us alter it.

ALTER TABLE us_house_inc_stats RENAME COLUMN `ï»¿id` TO `id`;

# Saw some errors when importing, let us check through count

SELECT COUNT(id)
FROM us_house_inc;

SELECT COUNT(id)
FROM us_house_inc_stats;

# On a first glance household income have about 250 less observations than household income stats
# miniscule amount, thus, we will focus on what we have

-- ------------------------------------------------------------

# STEP 2. DATA CLEANING (2.A. for one table, 2.B. for another table)
	
    # 2.A. us_house_inc TABLE
SELECT * FROM us_house_inc;
		# 2.A.1 Deleting duplicates (if id > 1)
		# We found 6 duplicate ids
SELECT id, COUNT(id)
FROM us_house_inc
GROUP BY id
HAVING COUNT(id) > 1;

		# Use row number to identify which row_id (to delete afterwards)
SELECT *
FROM 	(SELECT row_id,
		id,
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
		FROM us_house_inc) AS row_table
WHERE row_num > 1;

		# Let us update it by deleting the duplicates below
DELETE FROM us_house_inc
WHERE row_id IN (
	SELECT row_id             -- this changed because we want to delete this not *
	FROM 	(SELECT row_id,
			id,
			ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
			FROM us_house_inc) AS row_table
	WHERE row_num > 1);

	# Run previous code to check again, the duplicate id's are gone.
  
	# 2.A.2 Standardizing State_Name as upon a glance I see non capital a
		# 1. The result does not show lower case alabama. 
        # 2. Found georia instead of Georgia
        
SELECT DISTINCT state_name
FROM us_house_inc;
  
  # Let us attempt to fix georia with UPDATE function
  
UPDATE us_house_inc
SET state_name = 'Georgia' 
WHERE state_name = 'georia';
  
  # Run previous code to check. georia is gone, changed to Georgia.
  
# Now, alabama does not seem to make data unusable because it is still grouped with Alabama
# But for best practice purposes, since I found it, let us update alabama to Alabama.

UPDATE us_house_inc
SET state_name = 'Alabama' 
WHERE state_name = 'alabama';

# fixed alabama to Alabama.

  	# 2.A.3 Checking state abbreviation column
SELECT DISTINCT state_ab
FROM us_house_inc;
	# It looks fine
    
    # 2.A.4 Checking county column
		# from observation, 'county' and 'municipio' are redundant. lets update it.
SELECT DISTINCT county
FROM us_house_inc;

# updating the column

UPDATE us_house_inc
SET county = REPLACE(REPLACE(county, 'County', ''), 'Municipio', '');

# After checking it again it looks great.

    # 2.A.5 Checking city column
SELECT DISTINCT city
FROM us_house_inc;
	# It looks fine

    # 2.A.6 Checking place column
SELECT DISTINCT place
FROM us_house_inc
ORDER BY 1;

# Identified a blank.

# let us pull it up.
SELECT * 
FROM us_house_inc
WHERE place = '';
# it is from Alabama. Let us pull up all Alabama data and see if we can populate the place correctly.

SELECT row_id, State_Name, County, City, Place, Zip_code
FROM us_house_inc
WHERE State_name = 'Alabama'
ORDER BY city;
# identified a column that has exactly the same state_name, county, city, zipcode.alter
# Presumed it is safe to insert 'Autaugaville' inside the blank place.alter

# Let us update it, inserting 'Autaugaville to row 32

UPDATE us_house_inc
SET Place = 'Autaugaville' 
WHERE Place = '';

# Let us check it

SELECT * 
FROM us_house_inc
WHERE row_id = 32;

# It is populated nicely

	# 2.A.7 Checking type column
SELECT type, COUNT(type)
FROM us_house_inc
GROUP BY type;
	# 1. CPD looks like a type that should be within CDP as count is 2 (could be mistake but will not edit as not an expert in this area)
    # 2. Boroughs should be inside Borough as there is only 1, likely a mistake. -> fix this
    
UPDATE us_house_inc
SET type = 'Borough'
WHERE type = 'Boroughs';

# After checking, both are merged in Borough.

	# 2.A.8 Checking zip code, area code column
SELECT DISTINCT zip_code
FROM us_house_inc
ORDER BY 1;

SELECT DISTINCT area_code
FROM us_house_inc
ORDER BY 1;
# Looks good no blanks

	# 2.A.9 Aland and Awater (Area of Land and Water) check
		# Let us see if there are both land and water that are 0, since it will prove to be data quality issue
        
SELECT Aland, Awater
FROM us_house_inc
WHERE (Aland = '' OR 0 OR NULL) AND (Awater = '' OR 0 OR NULL);

# No there are none of them that have both empty values at the same time. No fixing needed.

-- ------------------------------------------------------------------------- -- 

	# 2.B. us_house_inc_stats table
		# 2.B.1 Delete duplicate ID rows if exists

# After checking, there are no duplicates.

SELECT id, COUNT(id)
FROM us_house_inc_stats
GROUP BY id
HAVING COUNT(id) > 1;

SELECT * FROM us_house_inc_stats;
SELECT * FROM us_house_inc_stats WHERE state_name = '';
SELECT * FROM us_house_inc_stats WHERE Mean = '';
SELECT * FROM us_house_inc_stats WHERE Median = '';
SELECT * FROM us_house_inc_stats WHERE stdev = '';
SELECT * FROM us_house_inc_stats WHERE sum_w = '';
# All the result sometimes gives area with mean, median, stdev, and sum_w of 0 not null.
# I am assuming that these places are not reporting instead of data quality issues.
# So no fixing needed, but I might filter data that has 0 mean in future calculations in EDA
-- ----------------------------------------------------------------------

# STEP 3. Exploratory Data Analyhsis (EDA)
	#3.A Area of Land and Water of the States in the US

SELECT State_name, County, City, Aland, Awater
FROM us_house_inc
ORDER BY Aland DESC;

# In a short glance we see that this data has area of land and water per city.alter
# It is too detailed, so let us just see Area of land and water per state!

SELECT State_name, SUM(Aland), SUM(Awater)
FROM us_house_inc
GROUP BY State_name
ORDER BY SUM(Aland) DESC
LIMIT 3;

SELECT State_name, SUM(Aland), SUM(Awater)
FROM us_house_inc
GROUP BY State_name
ORDER BY SUM(Aland) ASC
LIMIT 3;

# Top 3 largest area of land are Texas, California, and Missouri.
# Bottom 3 are District of Columbia, Rhode Island, and Delaware.

# How about largest Area of water
SELECT State_name, SUM(Aland), SUM(Awater)
FROM us_house_inc
GROUP BY State_name
ORDER BY SUM(Awater) DESC
LIMIT 3;

SELECT State_name, SUM(Aland), SUM(Awater)
FROM us_house_inc
GROUP BY State_name
ORDER BY SUM(Awater) ASC
LIMIT 3;
# Top three are Michigan - have many lakes such as Houghton lake or Torch lake, Texas (again), and Florida
# Bottom three are DIstrict of Columbia (again), Wyoming, and New Mexico.

	# 3.B. Joining the two tables with id as connector (since second table has median mean income but no state name, only id)
    SELECT * FROM us_house_inc_stats;
    SELECT * FROM us_house_inc;
SELECT *
FROM us_house_inc u
JOIN us_house_inc_stats us
	ON u.id = us.id
WHERE mean != 0; 			-- There are few rows from each state that has no data on mean, median std dev. 
							-- Not sure whether to delete, since there are possibilities that its just unreported instead of mistake
                            -- but for now let us just filter it out.

# It works, now let us use it for further analysis

    # 3.C. Drilling down state, mean to obtain information of income_mean
SELECT state_name, ROUND(AVG(mean),1) AS income_mean, ROUND(AVG(median),1) AS income_median	
FROM us_house_inc u
JOIN us_house_inc_stats us
	ON u.id = us.id
WHERE mean != 0
GROUP BY state_name
ORDER BY income_mean ASC
LIMIT 10;

	# Other than Puerto RIco (not continentally US)
    # Mississipi, Arkanasas, West Virginia, Alabama household income average are about USD 50k.alter
    # When considering it is household (could be husband and wife), these numbers are pretty low

		# Top 10 income_mean
SELECT state_name, ROUND(AVG(mean),1) AS income_mean, ROUND(AVG(median),1) AS income_median
FROM us_house_inc u
JOIN us_house_inc_stats us
	ON u.id = us.id
WHERE mean != 0
GROUP BY state_name
ORDER BY income_mean DESC
LIMIT 10;

	# District of Columbia have almost twice of Mississipi which is the lowest. 
    # I would have thought California and New York to be higher but at least they are top 10 from 52 states that are here in the dataset
    # Higher cost of living places such as Connecticut and New York (Upper East side) mentioned here is no surprise.
    # Very interesting is Hawaii, it's a small, secluded island but apparently high household income. 
    # Perhaps with only 1.4 million people population its a little skewed.

    # 3.D. Drilling down state, median to obtain information of the exact middle point of income
SELECT state_name, ROUND(AVG(mean),1) AS income_mean, ROUND(AVG(median),1) AS income_median
FROM us_house_inc u
JOIN us_house_inc_stats us
	ON u.id = us.id
WHERE mean != 0
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

	# Apparently the median is much higher than the mean in New Jersey, Wyoming, Alaska, Connecticut!
    # So it is likely they have many many cities that makes low income, as median is the 50 percentile of the data.
    # Interesting information. Let us see the bottom median next.
    
SELECT state_name, ROUND(AVG(mean),1) AS income_mean, ROUND(AVG(median),1) AS income_median
FROM us_house_inc u
JOIN us_house_inc_stats us
	ON u.id = us.id
WHERE mean != 0
GROUP BY 1
ORDER BY 3 ASC
LIMIT 10;

# Arkansas, Mississippi, Louisiana, Oklahoma, Alabama has lowest income median, and numbers much closer to mean.
# Unlike the high median states of which the gap between median and mean is quite high.

    # 3.E. Drilling down the type, mean to obtain information of mean of income by the administrative types of areas in USA

SELECT type, COUNT(type), ROUND(AVG(mean),1) AS income_mean, ROUND(AVG(median),1) AS income_median
FROM us_house_inc u
JOIN us_house_inc_stats us
	ON u.id = us.id
WHERE mean != 0
GROUP BY 1
ORDER BY 3 ASC;

# Municipality could be the highest because there is only 1 counted, so its not averaged. Could be the reason its quite high.
# Community and urban have very low household income mean of around USD 23k when combined.
# County, TOwn are also considered as one of the lowest as well but the numbers are going up fast
# Borough to Town seems like to have quite averaged healthy amount (excluding only municpiality, county, urban, community that have big differences)

# For the median, interestingly enough CDP Has the highest income median of 116.4k USD which is huge, considering it has 962 counts.
# Track is also quite high especially having averaged 29k of them.
# Lowest medians can be spotted in urban, community which is very-very low (18.7k and 14.2k) possibly these areas have low cost of living as well.

# For further checking, what are the urban and community states?

SELECT *
FROM us_house_inc
WHERE type = 'community' OR 'urban';

# Answer will show all are from Puerto Rico state
# That answers it. As mentioned before, Puerto Rico is not continental US, they are seperated from the mainland.
# High possibility of why their numbers are very low. Perhaps we can even take them out from dataset next time if we only want to analyze mainland US.
# But for now it is good that we dug it and found certain answer.

	# 3.F. Only get the data that have count(types) above 100 
		# Some types such as municipality, CPD, County, Urban, Community are very low and cant be compared with other types that have hundreds to tens of thousands
        # In this case we will filter it out with 'HAVING' clause. 
        # More of a MYSQL skill showcase rather than analyzing. Not an expert in housing data matters so will not attempt to analyze further
        
SELECT type, COUNT(type), ROUND(AVG(mean),1) AS income_mean, ROUND(AVG(median),1) AS income_median
FROM us_house_inc u
JOIN us_house_inc_stats us
	ON u.id = us.id
WHERE mean != 0
GROUP BY 1
HAVING COUNT(type) > 100	-- new line of code
ORDER BY 3 DESC;

    # 3.G. Drilling down the cities and their mean salary
		# Having satiated from the knowledge from state level. Let us see the city level
        # Assumption is that Manhattan would have high income mean (based on my bias from media)

SELECT state_name, city, ROUND(AVG(mean),1) AS income_mean, ROUND(AVG(median),1) AS income_median
FROM us_house_inc u
JOIN us_house_inc_stats us
	ON u.id = us.id
WHERE mean != 0
GROUP BY 1, 2
ORDER BY 3 ASC;

# Well, I do not see any familiar city names. Only Bronxville though which is also within New York area, very high!
# And that Delta Junction is actually in Alaska, they have the highest income mean. Congratulations!
# I can also see many New York & Virginia state areas, as well as some California and Pennsylvania having high income mean
# I do not see Manhattan but I am curious though (because of the movies), so let's take a look below

SELECT city, ROUND(AVG(mean),1) AS income_mean
FROM us_house_inc u
JOIN us_house_inc_stats us
	ON u.id = us.id
WHERE city LIKE 'Manha%n'
GROUP BY 1;

# Apparently Manhattan's income mean is only 67.8k which is pretty low than what I expected, especially when compared to top city like
# Delta Junction that has 242.8k or even Bronxville that still has 188k despite being in the same New York area.
# That is why, trust the data instead of bias!