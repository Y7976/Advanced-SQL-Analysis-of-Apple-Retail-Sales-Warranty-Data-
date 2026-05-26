# Advanced-SQL-Analysis-of-Apple-Retail-Sales-Warranty-Data-
# ![Apple Logo](https://github.com/najirh/Apple-Retail-Sales-SQL-Project---Analyzing-Millions-of-Sales-Rows/blob/main/Apple_Changsha_RetailTeamMembers_09012021_big.jpg.slideshow-xlarge_2x.jpg) Apple Retail Sales SQL Project - Analyzing Millions of Sales Rows

## Project Overview

This project is designed to showcase advanced SQL querying techniques through the analysis of over 1 million rows of Apple retail sales data. The dataset includes information about products, stores, sales transactions, and warranty claims across various Apple retail locations globally. By tackling a variety of questions, from basic to complex, you'll demonstrate your ability to write sophisticated SQL queries that extract valuable insights from large datasets.

The project is ideal for data analysts looking to enhance their SQL skills by working with a large-scale dataset and solving real-world business questions.

## Entity Relationship Diagram (ERD)

![ERD](https://github.com/najirh/Apple-Retail-Sales-SQL-Project---Analyzing-Millions-of-Sales-Rows/blob/main/erd.png)


Here’s the shortened and improved version of the "What’s Included" and "Why Choose This Project" sections, along with the link:

---

### What’s Included:
- **100 SQL Practice Problems**: Extensive coverage of major SQL topics for mastering concepts with real-world data.
- **20 Advanced SQL Queries**: Step-by-step solutions for complex queries, enhancing your skills in performance tuning and optimization.
- **5 Detailed Tables**: Comprehensive datasets with over 1 million rows, including sales, stores, product categories, products, and warranties.
- **Query Performance Tuning**: Learn to optimize queries for real-world data handling.
- **Portfolio-Ready Project**: Showcase your SQL expertise through large-scale data analysis.

### Why Choose This Project?
- **Hands-on Learning**: Practical experience with complex datasets and advanced business problem-solving.
- **Comprehensive Coverage**: Each table provides new opportunities to explore SQL concepts.
- **Exceptional Value**: For just **$9**, access 100 SQL problems, 20 advanced query solutions, and a real-world project.
- **Limited Offer**: Special price available for the **first 100 students**!



## Database Schema

The project uses five main tables:

1. **stores**: Contains information about Apple retail stores.
   - `store_id`: Unique identifier for each store.
   - `store_name`: Name of the store.
   - `city`: City where the store is located.
   - `country`: Country of the store.

2. **category**: Holds product category information.
   - `category_id`: Unique identifier for each product category.
   - `category_name`: Name of the category.

3. **products**: Details about Apple products.
   - `product_id`: Unique identifier for each product.
   - `product_name`: Name of the product.
   - `category_id`: References the category table.
   - `launch_date`: Date when the product was launched.
   - `price`: Price of the product.

4. **sales**: Stores sales transactions.
   - `sale_id`: Unique identifier for each sale.
   - `sale_date`: Date of the sale.
   - `store_id`: References the store table.
   - `product_id`: References the product table.
   - `quantity`: Number of units sold.

5. **warranty**: Contains information about warranty claims.
   - `claim_id`: Unique identifier for each warranty claim.
   - `claim_date`: Date the claim was made.
   - `sale_id`: References the sales table.
   - `repair_status`: Status of the warranty claim (e.g., Paid Repaired, Warranty Void).

## Objectives

The project is split into three tiers of questions to test SQL skills of increasing complexity:

### Easy to Medium (10 Questions)

1. Find the number of stores in each country.
```sql
select country, count(store_id) as No_of_Stores
from stores
group by country
order by count(store_id) desc;
```
2. Calculate the total number of units sold by each store.
```sql
select s.store_id ,
       st.store_name, 
       sum(quantity) as Total_no_of_units_sold 
from sales as s
join 
stores as st
on st.store_id = s.store_id
group by 1,2 
order by sum(quantity) desc;
```
3. Identify how many sales occurred in December 2023.
```sql
select 
      count(sale_id) as total_sales
from sales
where TO_CHAR(sale_date,'MM-YYYY') = '12-2023';
```
4. Determine how many stores have never had a warranty claim filed.
```sql
select store_id from stores
where store_id not in
(select 
       distinct store_id
       from sales as s 
       right join warranty as w 
       on s.sale_id = w.sale_id);
```
5. Calculate the percentage of warranty claims marked as "Warranty Void".
```sql
select 
     count(claim_id)*100.0 / (select(count(claim_id)) from warranty )
     as percentage
	 from warranty
where repair_status = 'Warranty Void';
```
6. Identify which store had the highest total units sold in the last year.
```sql
select s.store_id, s.sale_date ,st.store_name,
      sum(s.quantity) as Total_sales
      from sales as s
	  join stores as st
	  on s.store_id = st.store_id
where sale_date >= (current_date - interval '1 year') 
group by 1,2,3
order by 4 desc
limit 1 ;
```
7. Count the number of unique products sold in the last year.
```sql
select count(distinct product_id) as Unique_product_sold from sales
  where sale_date >= current_date - interval '1 year' ;
```
8. Find the average price of products in each category.
```sql
select p.category_id ,c.category_name,
       cast(avg(p.price) as decimal(10,2)) as avg_price
from products as p
full join category as c
on p.category_id = c.category_id
group by 1,2
order by 3 desc ;
```
9. How many warranty claims were filed in 2020?
```sql
select count(*) as claims_filled_2020
	   from warranty
where  extract(year from claim_date)  = 2020 ;
```
10. For each store, identify the best-selling day based on highest quantity sold.
```sql
select * from
(select store_id,
       TO_CHAR(sale_date, 'Day')as days ,
	   sum(Quantity) as highest_quantity,
	   rank() over(Partition by store_id order by sum(Quantity) desc) as rank
	   from sales
group by 1,2
order by 1,3)
where rank = 1;
```
### Medium to Hard (5 Questions)

11. Identify the least selling product in each country for each year based on total units sold.
```sql
select * 
from
(select extract(year from s.sale_date) as year,
       st.country,
       p.product_name,
	   sum(s.quantity) as Total_qty_sold,
	   rank() over(partition by st.country order by  sum(s.quantity) ) as rk
from sales as s
join stores as st
on s.store_id = st.store_id
join products as p
on p.product_id = s.product_id
group by 1,2,3
order by 1,3,4)
where rk = 1;
```

12. Calculate how many warranty claims were filed within 180 days of a product sale.
```sql
select w.* ,
       s.sale_date,
      w.claim_date - s.sale_date  as within_180_day
	   
from warranty as w
left join sales as s
on w.sale_id = s.sale_id
where w.claim_date - s.sale_date <= 180 ;
```
13. Determine how many warranty claims were filed for products launched in the last two years.
```sql
select 
       p.product_name,
	   count(w.claim_id) as claim_filled,
	   count(s.sale_id) as Total_sales
	   from products as p
right join sales as s
on s.product_id = p.product_id
right join warranty as w
on s.sale_id = w.sale_id
where p.launch_date >= current_date - interval'2 year'
group by 1 ;
```
14. List the months in the last three years where sales exceeded 100 units in the Iran.
```sql
select * 
from
(select TO_Char(sale_date,'MM-YYYY') as month,
       sum(a.quantity) as Total_unit_sold
from sales as a
join stores as s
on a.store_id = s.store_id
where s.country = 'Iran'
AND a.sale_date >= current_date - interval'3 Years'
group by 1) as t1
where Total_unit_sold >= 100 ;
```
15. Identify the product category with the most warranty claims filed in the last two years.
```sql
select c.category_name, 
       count(w.claim_id) as most_warranty_claim

from warranty as w
left join sales as s
on w.sale_id = s.sale_id

join products as p
on p.product_id = s.product_id
join category as c
on p.category_id = c.category_id
where w.claim_date >= current_date - interval'3 years'
group by 1
order by 2 desc;
```
### Complex (5 Questions)

16. Determine the percentage chance of receiving warranty claims after each purchase for each country.
```sql
select country,
       total_claim,
       total_unit_sold,
	   total_claim::numeric/ total_unit_sold::numeric*100 as percentage

from
(select st.country,
       sum(s.quantity) as total_unit_sold,
	   count(claim_id) as total_claim,
	   count(w.claim_id)::numeric/sum(s.quantity)::numeric*100 as percentage
from sales as s
join stores as st
on s.store_id = st.store_id
left join
warranty as w
on w.sale_id = s.sale_id

group by 1) as t1
order by 4 desc ;
```

17. Analyze the year-by-year growth ratio for each store.
```sql
with yearly_sales
as
(select s.store_id,
       st.store_name,
       extract(year from sale_date) as year,
       sum(s.quantity * p.price) as total_sales
from sales as s
join products as p
on s.product_id = p.product_id
join stores as st
on st.store_id = s.store_id
group by 1,2,3
order by 2,3),
growth_ratio 
as
(select store_name,
       year,
	   LAG(total_sales,1) over(partition by store_name order by year desc) as last_year_sales ,
	   total_sales as current_year_sale 
from yearly_sales)

select store_name,
       year,
	   last_year_sales ,
	   current_year_sale ,
	   current_year_sale - last_year_sales :: numeric / last_year_sales:: numeric *100 growth_ratio
from growth_ratio
where last_year_sales is not null
      and
	  year <> extract(year from current_date);
```
18. Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range.
```sql
select 
       case 
	       when p.price < 1500  then 'less expensive product'
		   when p.price between 1500 AND 3000 then 'mid range product'
		   else 'Expensive'
		   end as price_segment ,   
       count(w.claim_id) as total_claim
from warranty as w
left join sales as s
on w.sale_id = s.sale_id
join products as p
on p.product_id = s.product_id
where claim_date >= current_date - interval '5 years'
group by 1;
```
19. Identify the store with the highest percentage of "Paid Repaired" claims relative to total claims filed.
```sql
with paid_repaired
as
(select  s.store_id ,
       count(w.claim_id) as paid_repaired
	   from sales as s
Right join warranty as w
on w.sale_id = s.sale_id
where w.repair_status = 'Paid Repaired'
group by 1),

total_repaired
as
(select  s.store_id ,
       count(w.claim_id) as total_repaired
	   from sales as s
Right join warranty as w
on w.sale_id = s.sale_id

group by 1)

select 
      tr.store_id,st.store_name,
	  pr.paid_repaired,
	  tr.total_repaired,
	  round(pr.paid_repaired ::numeric/ tr.total_repaired :: numeric * 100,2) as percentage_paid_repaired
from paid_repaired as pr
join total_repaired as tr
on pr.store_id = tr.store_id
join stores as st
on pr.store_id = st.store_id 
order by 5 desc ;
```
20. Write a query to calculate the monthly running total of sales for each store over the past four years and compare trends during this period.
```sql
with monthly_sale
as
(select 
      store_id,
	  extract(year from sale_date) as year,
	  extract(month from sale_date) as month,
	  sum(p.price* s.quantity) as total_revenue
from sales as s
join products as p
on s.product_id = p.product_id
group by 1,2,3
order by 1,2, 3)

select store_id,
       month,
	   year,
	   total_revenue,
	   sum(total_revenue) over(partition by store_id order by year,month) as running_total
from monthly_sale ;
```
### Bonus Question

- Analyze product sales trends over time, segmented into key periods: from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.
```sql
select 
      p.product_name,
	  case 
	     when s.sale_date between p.launch_date And p.launch_date + interval '6 month' then '0 - 6 month'
		 when s.sale_date between p.launch_date + interval '6 month' and p.launch_date + interval '12 month' then '6-12 month'
		 when s.sale_date between p.launch_date + interval '12 month' and p.launch_date + interval '18 month' then '12-18 month'
         else '18+' end as product_lifecycle,
		 sum(s.quantity) as total_qty_sale
from sales as s
join products as p
on s.product_id = p.product_id
group by 1,2
order by 1,3 desc
```
## Project Focus

This project primarily focuses on developing and showcasing the following SQL skills:

- **Complex Joins and Aggregations**: Demonstrating the ability to perform complex SQL joins and aggregate data meaningfully.
- **Window Functions**: Using advanced window functions for running totals, growth analysis, and time-based queries.
- **Data Segmentation**: Analyzing data across different time frames to gain insights into product performance.
- **Correlation Analysis**: Applying SQL functions to determine relationships between variables, such as product price and warranty claims.
- **Real-World Problem Solving**: Answering business-related questions that reflect real-world scenarios faced by data analysts.


## Dataset

- **Size**: 1 million+ rows of sales data.
- **Period Covered**: The data spans multiple years, allowing for long-term trend analysis.
- **Geographical Coverage**: Sales data from Apple stores across various countries.

## Conclusion

By completing this project, you will develop advanced SQL querying skills, improve your ability to handle large datasets, and gain practical experience in solving complex data analysis problems that are crucial for business decision-making. This project is an excellent addition to your portfolio and will demonstrate your expertise in SQL to potential employers.


