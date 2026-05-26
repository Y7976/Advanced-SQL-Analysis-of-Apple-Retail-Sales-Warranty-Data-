-- --------------------------
-- Apple Store Analysis -----
-- --------------------------

-- Easy level ----------------
 
-- 1. find the no. of stores in each company
select country, count(store_id) as No_of_Stores
from stores
group by country
order by count(store_id) desc;

-- 2. calculate the total number of units sold by each store
select s.store_id ,
       st.store_name, 
       sum(quantity) as Total_no_of_units_sold 
from sales as s
join 
stores as st
on st.store_id = s.store_id
group by 1,2 
order by sum(quantity) desc;

-- 3. Identify how many sales occured in december 2023
select 
      count(sale_id) as total_sales
from sales
where TO_CHAR(sale_date,'MM-YYYY') = '12-2023';

-- 4. determine how many stores have never had a warranty claim field
select store_id from stores
where store_id not in
(select 
       distinct store_id
       from sales as s 
       right join warranty as w 
       on s.sale_id = w.sale_id);

-- 5.calculate the percentage of warranty claims marked as "warranty void"
select 
     count(claim_id)*100.0 / (select(count(claim_id)) from warranty )
     as percentage
	 from warranty
where repair_status = 'Warranty Void';

-- 6. Identify which store had the highest total units sold in the last year.
select s.store_id, s.sale_date ,st.store_name,
      sum(s.quantity) as Total_sales
      from sales as s
	  join stores as st
	  on s.store_id = st.store_id
where sale_date >= (current_date - interval '1 year') 
group by 1,2,3
order by 4 desc
limit 1 ;

-- 7. count the number of unique products sold in the last year.
select count(distinct product_id) as Unique_product_sold from sales
  where sale_date >= current_date - interval '1 year';

-- 8. Find the average price of products in each category.
select p.category_id ,c.category_name,
       cast(avg(p.price) as decimal(10,2)) as avg_price
from products as p
full join category as c
on p.category_id = c.category_id
group by 1,2
order by 3 desc ;

-- 9. how many warranty claims are filled in 2020.
select count(*) as claims_filled_2020
	   from warranty
where  extract(year from claim_date)  = 2020 ;

-- 10. For each store ,identify the best-selling day based on highest quantity sold.
select * from
(select store_id,
       TO_CHAR(sale_date, 'Day')as days ,
	   sum(Quantity) as highest_quantity,
	   rank() over(Partition by store_id order by sum(Quantity) desc) as rank
	   from sales
group by 1,2
order by 1,3)
where rank = 1;

-- Medium to Hard Question -----------------

-- 1. Identify the least selling product in each country for each year based on total units sold.
      -- least selling price ,
	  -- each country ,for each year
	  -- based on total unit sold
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

-- 2.Calculate how many warranty claims were filled within 180 days of a product sale.
select w.* ,
       s.sale_date,
      w.claim_date - s.sale_date  as within_180_day
	   
from warranty as w
left join sales as s
on w.sale_id = s.sale_id
where w.claim_date - s.sale_date <= 180 ;

-- 3.Calculate how many warranty claims were filled for product launched in last 2 years
-- each product
-- no. claim
-- no. salee
-- each must be launched in last 2 years

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

-- 4. list the month in the last three years where sales exceeded 100 units in iran.
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

-- 5. Identify the product category with the most warranty claims filled in the last two years.

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

-- Complex problems -------------

-- 1. determine the percentage chance of receiving warranty claims after 
--    each purchase for each country.
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

-- 2. Analyze the year by year growth ratiofor each store.
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

-- 3. calculate the corerelation between product price and warranty claims for products sold in the last five years segmented by price range .
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

-- 4. Identify the store with the highest percentage of "Paid Repaired" claims for products sold in the last five years segmented by price range.
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

-- 5.Write a query to calculate the monthly running total of sales for each store over the past four years and compare trends during this period.
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

-- 6. Analyze product sales trends over time , segmented into key periods: from launch to 6 month,6-12 months, 12-18 months,and beyond 18 months.
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











