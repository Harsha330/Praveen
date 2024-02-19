USE telangana_db ;

select * from dim_date ;
select * from dim_districts ;
select * from fact_stamps;
select * from fact_transport;
select * from fact_ts_ipass;

-- open Data Telangana Government Insights 

/* 1. How does the revenue generated from document registration vary
across districts in Telangana? List down the top 5 districts that showed
the highest document registration revenue growth between FY 2019
and 2022.*/

-- document reg , rev 
-- district 
select * from fact_stamps ; 


select max(district)'Top_5_districts' , total_doc_reg_bsd_dis , fiscal_year'year'  from 
(select  sum(a.documents_registered_rev) as total_doc_reg_bsd_dis , c.fiscal_year
, b.district  from 
fact_stamps a 
inner join dim_districts b 
 on a.dist_code = b.dist_code
 inner join dim_date c
 on a.month = c.month
 group by 2,3 
 order by 2 )t
 where fiscal_year >= 2019 AND fiscal_year <= 2022
 group by 2,3
 limit 5;
 
 SELECT district AS 'Top_5_districts', total_doc_reg_bsd_dis, fiscal_year AS 'year'
FROM (
    SELECT district, total_doc_reg_bsd_dis, fiscal_year,
        RANK() OVER (PARTITION BY fiscal_year ORDER BY total_doc_reg_bsd_dis DESC) AS district_rank
    FROM (
        SELECT b.district, SUM(a.documents_registered_rev) AS total_doc_reg_bsd_dis, c.fiscal_year
        FROM fact_stamps a
        INNER JOIN dim_districts b ON a.dist_code = b.dist_code
        INNER JOIN dim_date c ON a.month = c.month
        GROUP BY b.district, c.fiscal_year
    ) t
    WHERE fiscal_year BETWEEN 2019 AND 2022
) ranked_districts
WHERE district_rank <= 5 limit 5;

SELECT district AS 'Top_5_districts', total_doc_reg_bsd_dis, fiscal_year AS 'year'
FROM (
    SELECT district, total_doc_reg_bsd_dis, fiscal_year,
        ROW_NUMBER() OVER (PARTITION BY fiscal_year ORDER BY total_doc_reg_bsd_dis DESC) AS district_row_number
    FROM (
        SELECT b.district, SUM(a.documents_registered_rev) AS total_doc_reg_bsd_dis, c.fiscal_year
        FROM fact_stamps a
        INNER JOIN dim_districts b ON a.dist_code = b.dist_code
        INNER JOIN dim_date c ON a.month = c.month
        GROUP BY b.district, c.fiscal_year
    ) t
    WHERE fiscal_year = 2019 
) ranked_districts
WHERE district_row_number <= 5;

SELECT district AS 'Top_5_districts', total_doc_reg_bsd_dis, fiscal_year AS 'year'
FROM (
    SELECT district, total_doc_reg_bsd_dis, fiscal_year,
        ROW_NUMBER() OVER (PARTITION BY fiscal_year ORDER BY total_doc_reg_bsd_dis DESC) AS district_row_number
    FROM (
        SELECT b.district, SUM(a.documents_registered_rev) AS total_doc_reg_bsd_dis, c.fiscal_year
        FROM fact_stamps a
        INNER JOIN dim_districts b ON a.dist_code = b.dist_code
        INNER JOIN dim_date c ON a.month = c.month
        GROUP BY b.district, c.fiscal_year
    ) t
    WHERE fiscal_year = 2022
) ranked_districts
WHERE district_row_number <= 5;


/* 2.How does the revenue generated from document registration compare
to the revenue generated from e-stamp challans across districts? List
down the top 5 districts where e-stamps revenue contributes
significantly more to the revenue than the documents in FY 2022?.*/



-- reg docs 
-- rev e-challans 
-- districts 
-- top 5 districts
-- in fy 2022 






 
 

 
 
 

 
 
 select a.documents_registered_rev, b.district, sum(a.documents_registered_rev) over(partition by b.district ) as total_doc_reg_bsd_dis
 from 
fact_stamps a 
inner join dim_districts b 
on a.dist_code = b.dist_code 


