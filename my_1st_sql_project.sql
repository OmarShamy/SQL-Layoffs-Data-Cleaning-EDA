## full project data cleaning

select *
from layoffs;

## 1.remove duplicates
## 2.standrize the data
## 3.null values
## 4.remove unwanted column

create table layoffs_staging
like layoffs;

select *
from layoffs_staging;

insert layoffs_staging
select *
from layoffs;

##1.remove duplicates 

## add one more column row_num
select *,
row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions
 ) as row_num
from layoffs_staging;

## create CTE for filter duplicates 
with duplicates_CTE as 
(
select *,
row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions
 ) as row_num
from layoffs_staging
)
select *
from duplicates_CTE
where row_num > 1; 

## now delete duplicates 

with duplicates_CTE as 
(
select *,
row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions
 ) as row_num
from layoffs_staging
)
Delete 
from duplicates_CTE
where row_num > 1;


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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



insert into layoffs_staging2
select *,
row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,'date',
stage,country,funds_raised_millions) as row_num
from layoffs_staging;

set sql_safe_updates = 0;

select * 
from layoffs_staging2
where row_num > 1;

delete
from layoffs_staging2
where row_num > 1;

## 2.standarizing data 
select distinct(TRIM(industry))
from layoffs_staging2;

UPdate layoffs_staging2
set company = TRIM(company);

UPdate layoffs_staging2
set industry = TRIM(industry);

select distinct(TRIM(industry))
from layoffs_staging2
order by 1 ;

select *
from layoffs_staging2
where industry like 'crypto%';

update layoffs_staging2 
set industry = 'crypto'
where industry like 'crypto%';

## scan location
select distinct(location)
from layoffs_staging2
order by 1 ;

## scan country 
select distinct(country)
from layoffs_staging2
order by 1 ;

## it must be 'United States' not 'United States.'
select *
from layoffs_staging2
where country like 'United States%';

## lets fix it 
select distinct country , trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';


## change the format of the date from text to date 
select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date` , '%m/%d/%Y');

select `date`
from layoffs_staging2;

## lets change the data type 
alter table layoffs_staging2
modify column `date` date ;

select *
from layoffs_staging2;

##3.removing nulls

##  total_laid_of and percentage_laid_of have nulls 
select *
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;


delete 
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;

## industry has blank cells 
select *
from layoffs_staging2
where industry is null or industry = ''; 
 
 update layoffs_staging2
 set industry = null
 where industry = '';
 
 select t1.industry,t2.industry
 from layoffs_staging2 t1 
 join layoffs_staging2 t2
     on t1.company = t2.company 
where t1.industry is null 
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
    on t1.company = t2.company 
set t1.industry = t2.industry 
where t1.industry is null 
and t2.industry is not null; 

## lets check 
select *
from layoffs_staging2
where company = 'Airbnb';


## 4.drop row_num column 
select *
from layoffs_staging2;

alter table layoffs_staging2
drop column row_num;

## data cleaning finished 

select *
from layoffs_staging2;

## EDA 

##1.maximum total laid off
select max(total_laid_off),max(percentage_laid_off)
from layoffs_staging2;

select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;

## lets discover the biggest total_laid_off
select company,sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

select max(`date`),min(`date`)
from layoffs_staging2;

## industry 
select industry,sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

## country 
select country,sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

## year 
select year(`date`),sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;

## stage 
select stage,sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;

## rolling sum accordung to month
select substring(`date`,1,7) as `month` ,sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc;	


## CTE is used to discover where's the anomaly 
with rolling_total as 
(
select substring(`date`,1,7) as `month` ,sum(total_laid_off) as total_off 
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
)
select `month`,total_off,
sum(total_off) over(order by `month`) as rolling_total
from rolling_total;

## now lets correlate it the company 
select company,year(`date`),sum(total_laid_off)
from layoffs_staging2
group by company,year(`date`)
order by 3 desc;

## lets make CTE and window_function to rank the total_laid_off of a company according to the year 
with Company_year ( company,years,total_laid_off) as 
(
select company,year(`date`),sum(total_laid_off)
from layoffs_staging2
group by company,year(`date`)
), Company_Year_Rank as 
(
select *, dense_rank() over(partition by years order by total_laid_off desc) as ranking
from Compant_year
where years is not null
)
select *
from Company_Year_Rank
where ranking <= 5;






 













