-- Data Cleaning  
-- 1. Remove Duplicates
-- 2. Standardizing Data
-- 3. Null and Blank Values
-- 4. Removing Row/Column if needed
 
-- Create Database if not Exists World_Layoffs;
select *
 from layoffs_base;
 
 -- Creating a Staging/ Backup in the sense that the original DB isnt distrubed
 
--  Create Table layoffs_staging
--  Like layoffs_base;

select *
 from layoffs_staging;
 
 -- Inserting Data from the layoffBase Table 
 insert layoffs_staging
 select * from layoffs_base;
 
 select *
 from layoffs_staging;
 
 -- REMOVING DUPLICATES(WITH ROW NUMBER FUNCTION UNIQUE ROWS WILL BE NUMBERED AS 1, NON-UNIQUE/DUPLICATES WILL BE NUMBERED AS >1)
 select *, ROW_NUMBER() OVER(PARTITION BY COMPANY,INDUSTRY,TOTAL_LAID_OFF, PERCENTAGE_LAID_OFF, 'DATE') AS ROW_NUM
 from layoffs_staging; -- BY THIS TIME I HAVE MYSELF CREATED MULTIPLE  DUPLICATES AND HENCE THESE WILL BE SEEN AND AS I GO THROUGH THE PROCESS THIS SHOULD DECREASE THE ORIGINAL ROWS WERE SOME AROUND 2361,NOW THESE ARE 21249, AFTER REMOVAL IF THERE WERE OTHERS IN ORIGINAL DATA THIS SHOULD DECREASE TO LESS THAN 2361.
 
 -- USING A CTE(COMMON TABLE EXPRESSION, ONE CAN USE A SUBQUERY, CTE STARTS WITH "WITH", CLEANER CODE PRESENTING A SUBQUERY AS CTE, CHANGING THE CTE TO PARTITION OVER EVERYTHING
 WITH DUPLICATE_CTE AS 
 (
 select *, ROW_NUMBER() OVER(PARTITION BY LOCATION,COMPANY,INDUSTRY,TOTAL_LAID_OFF, PERCENTAGE_LAID_OFF, 'DATE', STAGE, funds_raised_millions) AS ROW_NUM
 from layoffs_staging
 )
 SELECT * FROM DUPLICATE_CTE WHERE ROW_NUM > 1;
 --  * FROM DUPLICATE_CTE WHERE ROW_NUM > 1;
 -- cHECKING FOR DUPLICATES
 
 SELECT * FROM layoffs_staging WHERE company ="CASPER" ;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `ROW_NUM` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
 
 
 insert into layoffs_staging2
 select *, ROW_NUMBER() OVER(PARTITION BY LOCATION,COMPANY,INDUSTRY,TOTAL_LAID_OFF, PERCENTAGE_LAID_OFF, 'DATE', STAGE, funds_raised_millions) AS ROW_NUM
 from layoffs_staging;
 
-- since i made multiple duplicates i am reducing them to one duplicate each of those that exist but i wil delete them in the next line
  DELETE 
 from layoffs_staging2
 where ROW_NUM > 2;
 
 -- setting the safe update temporarily off and  permanently on as without that its not possible to delete due to safe update and disabling it completely might not be a good idea
Set SQL_safe_updates =0;
   -- setting the safe update  on
 Set SQL_safe_updates =1;
  
 select * from layoffs_staging2;
 
 -- Now repeating the same thing for the remaining duplicates lets begin
 select * from layoffs_staging2
 where ROW_NUM > 1;
 
  -- calculate the duplicate as the difference between 4678 and 2339 as 2339 rows which will be duplicates free
  Set SQL_SAfe_updates =0;
  
 --  removing duplicates
 delete from layoffs_staging2
 where ROW_NUM > 1;
-- safe updates on
 Set SQL_safe_updates =1;
 
 select * from layoffs_staging2;
  -- Now we are duplicate free
  
  -- STANDARDIZING DATA 
  SELECT COMPANY ,TRIM(COMPANY) FROM layoffs_staging2
  ORDER BY 1;
  -- TO UPDATE I CAN ALSO DISABLE IT FROM PREFERENCE BUT I AM NOT DOING THAT 
  SET SQL_SAFE_UPDATES = 0;
  UPDATE layoffs_staging2 
  SET COMPANY = TRIM(COMPANY)
  ;
  SELECT COMPANY ,TRIM(COMPANY) FROM layoffs_staging2
  ORDER BY 1;
  SELECT DISTINCT(iNDUSTRY) FROM layoffs_staging2 order by 1;
  
  SELECT * 
  FROM layoffs_staging2
  WHERE industry LIKE "CRYPT%";
  
  
  UPDATE layoffs_staging2
  SET INDUSTRY = "Crypto"
  where industry like "Crypt%";
  -- a location correction required 
  set sql_safe_updates =0;
  
  select distinct location from layoffs_staging2
  where location like '%seldorf%';
  
  update layoffs_staging2
  set location = 'Dusseldorf'
  where location like '%seldorf%';
-- safe updates set on 
  set sql_safe_updates =1;
   -- Checked the correction there were two Dusseldorf, without disctinct, with distinct itll return one 
   select  location from layoffs_staging2
  where location like '%seldorf%';
  
  -- skimming country
  select distinct(country),trim(trailing '.' from  Country) from layoffs_staging2
  order by 1;
  
set sql_safe_updates = 0;

update layoffs_staging2
set country = trim(trailing '.' from  Country)
where country like 'United States%';

select distinct country from layoffs_staging2;
-- theres a difference of one that makes it clear that 
 
-- changing the date FORMAT
 
 select date,
 str_to_date(date, '%m/%d/%Y') -- this format only works you can try others to just get the feel of it
 from layoffs_staging2;
  
  update layoffs_staging2
  set date = str_to_date(date, '%m/%d/%Y');
  
  select date from layoffs_staging2;
  
  Alter table layoffs_staging2
  modify column date date;
  
  select date from layoffs_staging2;
  
  --  REMOVING NULLS
  
  SELECT*FROM layoffs_staging2
  WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL
  AND funds_raised_millions IS NULL
  AND INDUSTRY IS NULL;
  
 --  SELECT*FROM layoffs_staging2
  -- WHERE INDUSTRY IS NULL;

  
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    industry IS NULL
    OR industry = "";
    
SELECT * FROM layoffs_staging2
WHERE company = "AIRBNB";

-- POPULLATING DATA THAT CAN BE POPULATED  
SET SQL_SAFE_UPDATES = 0;
update layoffs_staging2 
SET INDUSTRY = "Travel"
WHERE COMPANY = "Airbnb";
 -- check 
 SELECT * FROM layoffs_staging2
WHERE company = "AIRBNB";

SELECT * FROM layoffs_staging2 WHERE INDUSTRY ="" OR industry IS NULL;

-- CHECKING INDUSTRY FOR EACH OF THOSE BUSINESS WHICH CAN BE POPULLATED
 SELECT * FROM layoffs_staging2
WHERE company = "Carvana"; --  CARVANA'S INDUTRY IS "Transportation"
 SELECT * FROM layoffs_staging2
WHERE company = "Bally's Interactive"; -- THE COMPANY HERE IS NOT DEFINED AS ITS ONLY ONE DATA ENTRY
 SELECT * FROM layoffs_staging2
WHERE company = "Juul"; -- THE INDUSTRY IS Consumer
-- UPDATIONS
update layoffs_staging2 
SET INDUSTRY = "Transportation"
WHERE COMPANY = "Carvana";

update layoffs_staging2 
SET INDUSTRY = "Consumer"
WHERE COMPANY = "Juul";
SET SQL_SAFE_UPDATES= 1;
-- DATA FOR INDUSTRY POPULATED
 -- ALTERNATIVELY ONE CAN ALSO DO IT THIS WAY BUT IF YOU HAVE TRIED THE ABOVE ONE THIS WONT WORK CAUSE CHANGES MIGHT ALREADY HAVE BEEN MADE
 
 SELECT * 
 FROM layoffs_staging2 T1
 JOIN layoffs_staging2 T2
  ON T1.company = T2.company
  AND T1.location= T2.location
 WHERE (T1.industry IS NULL OR T1.industry ="")
 AND T2.industry IS NOT NULL;
 

 UPDATE layoffs_staging2 T1
 JOIN layoffs_staging2 T2
   ON T1.company = T2.company
  SET  T1.INDUSTRY = T2.INDUSTRY
WHERE (T1.industry IS NULL OR T1.industry ="")
 AND T2.industry IS NOT NULL; 
 
 -- FOR THE ABOVE TO WORK IT HAS TO BE MADE NULL FIRST
 UPDATE layoffs_staging2
 SET INDUSTRY =null
 WHERE INDUSTRY = "";  -- NOW UPDATE AS ABOVE
 
 -- DELETING UNWANTED DATA
  SELECT*FROM layoffs_staging2
  WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;
 
 SET SQL_SAFE_UPDATES=0;
   DELETE FROM layoffs_staging2
  WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;
    -- DONE DELETION 
 
SELECT *  from layoffs_staging2;
 -- NOW DROPPING THE ROW NUM COLUMN WE DID FOR UNIQUE ID
 alter TABLE layoffs_staging2
 DROP column ROW_NUM;
