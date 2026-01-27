
*/1.List the top 3 and bottom 3 makers for the fiscal years 2023 and 2024
 in terms of the number of 2-wheelers sold. /* 

*/Top*/
select sum(m.`electric_vehicles_sold`) as top3 , m.maker from maker m join dim_date d on  
d.order_date =m.order_date  
where m.vehicle_category ='2-Wheelers' and d.`fiscal_year` in (2023,2024) 
group by m.maker  
order by top3 desc limit 3;
*/Bottom*/
select sum(m.`electric_vehicles_sold`) as bottom3 , m.maker from maker m join dim_date d on  
d.order_date =m.order_date  
where m.vehicle_category ='2-Wheelers' and d.`fiscal_year` in (2023,2024) 
group by m.maker  
order by bottom3  limit 3;

*/ 2.Identify the top 5 states with the highest penetration rate in 2-wheeler and 4-wheeler 
EV sales in FY 2024./*
/*2-Wheelers*/
select s.state,(sum(s.`electric_vehicles_sold`)/sum(s.`total_vehicles_sold`))*100 as penetration_rate  
from state s join dim_date d on d.order_date = s.order_date  
where d.`fiscal_year`=2024 and s.vehicle_category ='2-Wheelers' 
group by s.state  
order by penetration_rate  desc limit 5 

/*4-Wheelers*/
select s.state,(sum(s.`electric_vehicles_sold`)/sum(s.`total_vehicles_sold`))*100 as penetration_rate  
from state s join dim_date d on d.order_date = s.order_date  
where d.`fiscal_year`=2024 and s.vehicle_category ='4-Wheelers' 
group by s.state  
order by penetration_rate  desc limit 5  

*/3.List the states with negative penetration (decline) in EV sales from 2022 to 2024*/

select x.state from (select s.state,(sum(s.`electric_vehicles_sold`)/sum(s.`total_vehicles_sold`))*100 as penetration_rate  
from state s join dim_date d on d.order_date = s.order_date  
where d.`fiscal_year` between 2022 and 2024  
group by s.state )x  
where penetration_rate <0 

*/4.4.What are the quarterly trends based on sales volume for the top 5 EV makers 
(4-wheelers) from 2022 to 2024?*/

with cte as ( select m.maker,d.`quarter`,sum(m.`electric_vehicles_sold`) as EV_sold, 
rank() over(partition by d.quarter order by sum(m.`electric_vehicles_sold`) desc) as rnk  
from maker m join dim_date d on m.order_date = d.order_date  
where d.`fiscal_year` between 2022 and 2024 and m.`vehicle_category`= '4-Wheelers'  
group by m.maker,d.`quarter`) 
select maker,quarter,EV_sold from cte  
where rnk <=5  

*/5.How do the EV sales and penetration rates in Delhi compare to Karnataka for 2024? */
 
select s.state,sum(s.`electric_vehicles_sold`) as tot_ev_sold, 
round(sum(s.`electric_vehicles_sold`)/sum(s.`total_vehicles_sold`) * 100,2) as penetration_rate  
from state s join dim_date d on s.order_date = d.order_date  
where d.`fiscal_year`=2024 and s.state in('Delhi','Karnataka') 
group by s.state  
order by s.state 

*/6. List down the compounded annual growth rate (CAGR) in 4-wheeler units for 
the top 5 makers from 2022 to 2024.*/

with ev_2022 as (select m.maker,sum(m.`electric_vehicles_sold`) as EV_sold_2022 from maker m 
join dim_date d on  m.order_date = d.order_date  
where m.`vehicle_category`= '4-Wheelers' and d.`fiscal_year`=2022  
group by  m.maker  
order by EV_sold_2022 desc ), 

ev_2024 as (select m.maker,sum(m.`electric_vehicles_sold`) as EV_sold_2024 from maker m 
join dim_date d on  m.order_date = d.order_date  
where m.`vehicle_category`= '4-Wheelers' and d.`fiscal_year`=2024  
group by  m.maker  
order by EV_sold_2024 desc ) 

select f.maker,f.EV_sold_2024,b.EV_sold_2022, 
round 
((power(f.EV_sold_2024/b.EV_sold_2022,1.0/2)-1) * 100, 2)   as CAGR from  
ev_2022 b join ev_2024 f on b.maker=f.maker 
where  b.EV_sold_2022 > 0   
order by CAGR desc limit 5 

/*7. List down the top 10 states that had the highest compounded annual growth rate (CAGR) 
from 2022 to 2024 in total vehicles sold. */

with ev_2022 as (select s.state,sum(s.`total_vehicles_sold`) as EV_sold_2022 from state s   join dim_date d on  s.order_date = d.order_date   
 where s.`vehicle_category`= '4-Wheelers' and d.`fiscal_year`=2022   
 group by  s.state   
 order by EV_sold_2022 desc ),  

ev_2024 as (select s.state,sum(s.`total_vehicles_sold`) as EV_sold_2024 from state s   
 join dim_date d on  s.order_date = d.order_date   
 where s.`vehicle_category`= '4-Wheelers' and d.`fiscal_year`=2024   
 group by  s.state   
 order by EV_sold_2024 desc )  

 select f.state,f.EV_sold_2024,b.EV_sold_2022,  
 round  
((power(f.EV_sold_2024/b.EV_sold_2022,1.0/2)-1) * 100, 2)   as CAGR from   
ev_2022 b join ev_2024 f on b.state=f.state 
where  b.EV_sold_2022 > 0    
order by CAGR desc limit 10 

*/8. What are the peak and low season months for EV sales based on the data 
from 2022 to 2024?*/ 

with peak_season as (select monthname(m.`order_date`) as monthsales,
sum(m.`electric_vehicles_sold`) as EV_sold from maker m join dim_date d 
on d.`order_date`=m.`order_date`
where d.`fiscal_year` between 2022 and 2024  
group by monthsales 
order by EV_sold desc limit 1), 

low_season as  (select monthname(m.`order_date`) as monthsales,sum(m.`electric_vehicles_sold`) as EV_sold from 
maker m join dim_date d on d.`order_date`=m.`order_date` 
where d.`fiscal_year` between 2022 and 2024  
group by monthsales 
order by EV_sold limit 1) 

select 'peak_season' as season ,p.monthsales,p.EV_sold from peak_season p 
union  
select 'low_season' as season,l.monthsales,l.EV_sold from low_season l 

*/9.What is the projected number of EV sales (including 2-wheelers and 4-wheelers)
 for the top 10 states by penetration rate in 2030, based on the compounded annual growth rate
 (CAGR) from previous years? */

WITH EV_2024 AS ( 
    SELECT  
        s.state,  
        SUM(s.electric_vehicles_sold) AS ev_2024 
    FROM state s 
    JOIN dim_date d ON d.order_date = s.order_date 
    WHERE d.fiscal_year = 2024 
    GROUP BY s.state ), 

EV_2022 AS ( 
    SELECT s.state,  
	SUM(s.electric_vehicles_sold) AS ev_2022 
    FROM state s 
    JOIN dim_date d ON d.order_date = s.order_date 
    WHERE d.fiscal_year = 2022 
    GROUP BY s.state ), 

cagr AS ( SELECT  
        f.state, 
        POWER(f.ev_2024 / b.ev_2022, 1.0/2) - 1 AS cagr 
    FROM EV_2024 f 
    JOIN EV_2022 b ON f.state = b.state 
    WHERE b.ev_2022 > 0 ) 

SELECT  
    c.state, 
    ROUND(c.cagr * 100, 2) AS CAGR_percent, 
    e.ev_2024, 
    ROUND(e.ev_2024 * POWER(1 + c.cagr, 6)) AS projected_ev_2030 
FROM cagr c 
JOIN EV_2024 e ON e.state = c.state 
ORDER BY projected_ev_2030 DESC 
LIMIT 10; 

*/10.Estimate the revenue growth rate of 4-wheeler and 2-wheelers EVs in India for
 2022 vs 2024 and 2023 vs 2024, assuming an average unit price. H */

with unit_sales as (select d.`fiscal_year`,m.`vehicle_category`,
sum(m.`electric_vehicles_sold`) as EV_sold
from maker m join dim_date d on d.`order_date`=m.`order_date`
where d.`fiscal_year` in(2022,2023,2024)
group by d.`fiscal_year`,m.`vehicle_category`
order by d.`fiscal_year`),
revenue as (select  `fiscal_year`,`vehicle_category`,
 CASE WHEN vehicle_category = '2-Wheelers' THEN EV_sold * 85000 
	WHEN vehicle_category = '4-Wheelers' THEN EV_sold * 1500000 end  as revenue 
    from unit_sales),
    growth_rate_2022_2024 as (select r24.vehicle_category, 
   round(((r24.revenue-r22.revenue)/r22.revenue) * 100 , 2) as growth_22_24 from revenue r24
   join revenue r22 on r22.vehicle_category = r24.vehicle_category
   where r24.fiscal_year = 2024 and r22.fiscal_year = 2022),
   growth_rate_2023_2024 as (select r24.vehicle_category, 
   round(((r24.revenue-r23.revenue)/r23.revenue) * 100 , 2) as growth_23_24 from revenue r24 join 
   revenue r23 on r23.vehicle_category = r24.vehicle_category
   where r24.fiscal_year = 2024 and r23.fiscal_year = 2023) 
   select 22r.vehicle_category,22r.growth_22_24,23r.growth_23_24 from 
   growth_rate_2022_2024 22r join   growth_rate_2023_2024  23r 
   on 22r.vehicle_category=23r.vehicle_category
   





