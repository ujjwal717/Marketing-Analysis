-- 1) Data Cleaning and Transformation:

-- A) Removing thousand separators from columns

update email_campaign
set emails_delivered = replace(emails_delivered,',','') -- replaced separator from column "emails_delivered"

update email_campaign
set email_opens = replace(email_opens,',','')  -- replaced separator from column "email_opens"

update email_campaign
set email_clicks = replace(email_clicks,',','')  -- replaced separator from column "email_clicks"


-- B) Removed percentage sign from columns

update email_campaign
set delivery_rate = replace(delivery_rate,'%','')  -- replaced percentage icon from column "delivery_rate"

update email_campaign
set open_rate = replace(open_rate,'%','')  -- replaced percentage icon from column "open_rate"

update email_campaign
set click_through_rate = replace(click_through_rate,'%','')  -- replaced percentage icon from column "click_through_rate" 

update email_campaign
set click_to_open_rate = replace(click_to_open_rate,'%','')  -- replaced percentage icon from column "click_to_open_rate"

update email_campaign
set conversion_rate = replace(conversion_rate,'%','')  -- replaced percentage icon from column "conversion_rate"


-- C) Replaced campaign title for better understanding

update email_campaign
set campaign_title = replace(campaign_title,'WEEK31_31082023_SEPTEMBERVIPPREVIEW','week_31_september_preview')  -- replaced name for week 31 september preview

update email_campaign
set campaign_title = replace(campaign_title,'WEEK31_31082023_LAYERINGEDIT(ROB)','week_31_layering_edit')  -- replaced name for week 31 layering edit

update email_campaign
set campaign_title = replace(campaign_title,'WEEK31_29082023_TRANS-SEASONALKNITWEAR','week_31_september_trans_seasonal_knitwear')  -- replaced name for week 31 seasonal knitwear

update email_campaign
set campaign_title = replace(campaign_title,'WEEK30_27082023_WORKWEAR','week_30_workwear')  -- replaced name for week 30 work wear

update email_campaign
set campaign_title = replace(campaign_title,'WEEK30_26082023_TEXTURE','week_30_texture')  -- replaced name for week 30 texture wear

update email_campaign
set campaign_title = replace(campaign_title,'WEEK30_21082023_DENIMEDIT','week_30_denim')  -- replaced name for denim wear   

update email_campaign
set campaign_title = replace(campaign_title,'WEEK29_20082023_HOWTOBUILDAWORKCAPSULEWARDROBE','week_29_work_wadrobe_guide')  -- replaced name for work wardrobe guide

update email_campaign
set campaign_title = replace(campaign_title,'WEEK29_19082023_LABORDAYWEEKEND','week_29_laborday')  -- replaced name for laborday campaign

update email_campaign
set campaign_title = replace(campaign_title,'WEEK29_17082023_PRE-AUTUMNINVESTMENTCHECKLIST','week_29_pre_autumn_investment')  -- replaced name for pre autumn investment campaign

update email_campaign
set campaign_title = replace(campaign_title,'WEEK28_13082023_TRAVELTAILORING(PONTE)','week_28_travel_tailoring_pointe')  -- replaced name for travel tailoring campaign


-- D) Created new column "campaign_time" 

alter table email_campaign  -- performed alter table command to create new column "campaign_time"
add "campaign_time" varchar

update email_campaign
set campaign_time = coalesce(campaign_time, left(campaign_title,7))  -- used coalesce to fill null values in campaign_time with value from "campaign_title" column


-- E) Created new column "variant_country"

alter table email_campaign  -- performed alter table command to create column "sub_variant"
add "variant_country" varchar

update email_campaign
set variant_country = case when trim(split_part(variant,'>',2)) in ('CAN','AUS','Rest of ROW') then trim(split_part(variant,'>',2)) else split_part(variant,'>',1) end


-- F) Created new column "variant_type"

alter table email_campaign  -- performed alter table command to create column "sub_variant"
add "variant_type" varchar

update email_campaign
set variant_type = case when trim(split_part(variant,'>',3)) != '' then trim(split_part(variant,'>',3))
when trim(split_part(variant,'>',2)) not in ('AUS','CAN','Rest of ROW') then trim(split_part(variant,'>',2)) else 'Normal' end 


-- G) Removed unncessary characters from column "campaign title"

update email_campaign
set campaign_title = substring(campaign_title,9)  -- used substring to only store necessary data in "campaign_title" column


-- H) Created new column "country"

alter table email_campaign
add country varchar  -- created new column "country"

update email_campaign
set country = split_part(variant,' ',1)  -- updated data into column "country"


--I) Changing data type of required columns

alter table email_campaign
alter column emails_delivered type float using (emails_delivered::float)  -- changed data type of "emails_delivered" to float 

alter table email_campaign
alter column email_opens type float using (email_opens::float)  -- changed data type of "emails_opens" to float 

alter table email_campaign
alter column email_clicks type float using (email_clicks::float)  -- changed data type of "email_clicks" to float

alter table email_campaign
alter column delivery_rate type float using (delivery_rate::float)  -- changed data type of "delivery rate" to float

alter table email_campaign
alter column open_rate type float using (open_rate::float)  -- changed data type of "open_rate" to float

alter table email_campaign
alter column click_through_rate type float using (click_through_rate::float)  -- changed data type of "click_through_rate" to float

alter table email_campaign
alter column click_to_open_rate type float using (click_to_open_rate::float)  -- changed data type of "click_to_open_rate" to float

alter table email_campaign
alter column conversion_rate type float using (conversion_rate::float)  -- changed data type of "conversion_rate" to float

alter table email_campaign
alter column orders type float using (orders::float)  -- changed data type of "orders" to float

alter table email_campaign
alter column total_revenue type float using (total_revenue::float)  -- changed data type of "total_revenue" to float

alter table email_campaign
alter column average_order_value type float using (average_order_value::float)  -- changed data type of "average_order_value" to float

alter table email_campaign
alter column revenue_per_email type float using (revenue_per_email::float)  -- changed data type of "revenue_per_email" to float


-- 2) Performing EDA (Exploratory Data Analysis)

-- A) week 31 order performance for normal variant

select campaign_time, campaign_title, variant_country,variant_type, orders, 
dense_rank() over(order by orders desc) as order_ranking  -- required columns selected and dense_rank performed to get order ranking

from email_campaign

where campaign_time = 'week_31' and variant_type like '%Normal%'  -- filtered the result for week 31 and for normal variant


-- B) week 31 order performance for VIP customer variant

select campaign_time, campaign_title, variant_country, orders, 
dense_rank() over(order by orders desc) as order_ranking  -- required columns selected and dense_rank performed to get order ranking

from email_campaign

where campaign_time = 'week_31' and variant_country like '%VIP%'  -- filtered the result for week 31 and for VIP customer variant


-- C) Weekly total revenue with ranking

with revenue_in_week (campaign_time, weekly_revenue) as (  -- created CTE

select campaign_time, sum(total_revenue) as weekly_revenue  -- performed sum aggregation 
from email_campaign
group by campaign_time)  -- grouped by campaign time to get total revenue sum according to that


select *, dense_rank() over(order by weekly_revenue desc)  -- performed dense rank sccording to highest weekly revenue

from revenue_in_week


-- D) Maximum emails delivered among weeks

with most_emails (campaign_time, campaign_title, variant, emails_delivered, ranking) as (  -- created CTE

select distinct campaign_time, campaign_title, variant, emails_delivered, 
dense_rank() over(partition by campaign_time order by emails_delivered desc) as ranking  -- performed dense rank for most delivered email per week

from email_campaign)

select campaign_time, campaign_title, variant, emails_delivered  -- selected required columns

from most_emails

where ranking = 1  -- filtered to get result where ranking = 1 

order by emails_delivered desc  -- ordered according to emails delivered from the result in descending order


-- E) Average spend by country and country variant

select distinct country, variant_country, round(avg(average_order_value)::numeric,2) as average_spend

from email_campaign

group by country, variant_country

order by average_spend desc


-- F) Average spend and average order count by variant type 

select distinct variant_type, round(avg(average_order_value)::numeric,2) as average_spend,  --calculated average spend 
round(avg(orders::numeric),2) as avg_order_count  -- calculated average order count

from email_campaign

group by variant_type  -- Grouped data according to variant type

having variant_type not in ('Highly Engaged','Vip Non Highly Engaged')  -- filtering to not include VIP variant type

order by average_spend desc


-- G) Worst performing campaigns by profits

select campaign_time, campaign_title, variant_country, total_profit

from email_campaign
where total_profit < 0

order by total_profit 




-- 3) Performing in-depth analysis

-- A) In which country, each campaign generated maximum orders

with max_order_per_campaign  as (  -- created CTE

select distinct campaign_time, country,campaign_title,orders,  --selected required columns
dense_rank() over(partition by campaign_title order by orders desc) as order_ranking  -- performed dense rank to get ranking according to orders
from email_campaign)

select campaign_time,campaign_title,country, orders  --selected required columns
from max_order_per_campaign
where order_ranking = 1  -- filtered data where order ranking is equal to 1 
order by orders desc


-- B) In which country, each campaign generated maximum total revenue

with max_revenue_per_campaign  as (  -- created CTE 

select distinct campaign_time, country,campaign_title,total_revenue,  --selected required columns
dense_rank() over(partition by campaign_title order by total_revenue desc) as revenue_ranking  -- performed dense rank to get ranking according to revenue
from email_campaign)

select campaign_time,campaign_title,country, total_revenue  --selected required columns
from max_revenue_per_campaign
where revenue_ranking = 1  -- filtered data where revenue ranking is equal to 1 
order by total_revenue desc


-- C) Which campaign has best conversion rate for each week

with best_conversion_rate as (  -- created CTE that ranks campaign among weeks according to conversion rate

select distinct campaign_time, campaign_title, conversion_rate,  -- selected required columns
dense_rank() over (partition by campaign_time order by conversion_rate desc) as conversion_ranking  -- performed dense rank to rank campaign by conversion rate
from email_campaign)

select campaign_time, campaign_title, conversion_rate  -- selected required columns from CTE 
from best_conversion_rate 

where conversion_ranking = 1  -- filtered result for only those campaign that have best conversion rate each week

order by conversion_rate desc  -- ordered according to conversion rate in descending order


-- D) Which variant type among campaigns generated maximum orders

with variant_type_max_orders as (  -- created CTE 

SELECt campaign_time, campaign_title, country, variant_type, orders,  
dense_rank() over(partition by campaign_title, variant_type order by orders desc) as order_ranking  -- ranked variant type according to orders
from email_campaign
where variant_country not like '%VIP%')  -- excluded VIP variant

select campaign_time, campaign_title, country, variant_type, orders  -- selected required columns from CTE
from variant_type_max_orders

where order_ranking = 1  -- filtered data to show only those variant that have best order ranking per campaign title

order by campaign_time desc  -- ordered according to campaign time


-- E) Which variant type among campaigns generated maximum revenue

with variant_type_max_revenue as (  -- created CTE 

SELECt campaign_time, campaign_title, country, variant_type, total_revenue,  
dense_rank() over(partition by campaign_title, variant_type order by total_revenue desc) as revenue_ranking  -- ranked variant type according to revenue
from email_campaign
where variant_country not like '%VIP%')  -- excluded VIP variant

select campaign_time, campaign_title, country, variant_type, total_revenue  -- selected required columns from CTE
from variant_type_max_revenue

where revenue_ranking = 1  -- filtered data to show only those variant that have best revenue ranking per campaign title

order by campaign_time desc  -- ordered according to campaign time


-- F) Which campaign has best email click to order rate for each week

with ranked_click_to_order_rate as (  -- created CTE

SELECT campaign_time, campaign_title, country, variant_type, email_clicks, orders
round(((orders*100)/email_clicks)::numeric,2) as click_to_order_rate,  -- created click_to_order_rate
dense_rank() over(partition by campaign_time order by round(((orders*100)/email_clicks)::numeric,2) desc) as cto_ranking  -- created ranking for click to order rate

from email_campaign)

select campaign_time, campaign_title, country, variant_type, email_clicks, orders, click_to_order_rate  -- selected required columns for CTE
from ranked_click_to_order_rate

where cto_ranking = 1  -- filtered data for best performing campaigns by click to order rate


-- G) Running cost, running revenue and running profit for each week

SELECT distinct campaign_time,
sum(cost_per_mail * emails_delivered) over(order by campaign_time) as running_cost,  -- calculated running cost
sum(revenue_per_email * emails_delivered) over (order by campaign_time) as running_revenue,  -- calculated running revenue
sum(profit_per_mail * emails_delivered) over(order by campaign_time) as running_profit  -- -- calculated running profit by week  

from email_campaign

order by campaign_time


-- H) Countries where each campaign generated maximum profit

with profit_campaign_country as (  -- created CTE for profit ranking by campaign title

select campaign_time, campaign_title, country, (profit_per_mail * emails_delivered) as profit  -- calculated profit per campaign, 
dense_rank() over (partition by campaign_title order by (profit_per_mail * emails_delivered) desc) profit_ranking  -- ranked campaigns by profit
from email_campaign)

select campaign_time, campaign_title, country, profit  -- selected required columns from CTE
from profit_campaign_country

where profit_ranking = 1  -- filtered result to have best profit ranking per campaign
order by campaign_time


-- I) Top 10 campaigns by email open rate

with best_campaign_open_rate as (  -- created CTE to rank campaigns by email open rates

SELECT campaign_time, campaign_title,variant_country, variant_type,open_rate as email_open_rate, 
dense_rank() over(order by open_rate desc) as email_open_rate_rank  -- ranked campaigns by open rate

from email_campaign)

select campaign_time, campaign_title, variant_country, variant_type, email_open_rate  -- select required columns from CTE

from best_campaign_open_rate 

where email_open_rate_rank < 11  -- filtered 10 campaigns having hightest email open rates


-- J) Campaign that performed best in each country by profit

with country_profit as (  -- created CTE to rank profit by country

SELECT campaign_time, country, campaign_title, variant_type, 
(profit_per_mail * emails_delivered) as profit,  -- calculated profit per campaign
dense_rank() over(partition by country order by profit_per_mail * emails_delivered desc) as profit_rank  -- ranked campaign by country

from email_campaign) 

select campaign_time, country, campaign_title, variant_type, profit  -- selected required columns from CTE
from country_profit

where profit_rank = 1  -- filtered result to display best profit rank for each country
order by profit desc


-- K) Campaigns with best click to order rate for each week

with ranked_click_to_orders as (  -- created CTE to rank campaigns by click to order rate

SELECT campaign_time, campaign_title, email_clicks, orders, click_to_order_rate,
dense_rank() over(partition by campaign_time order by click_to_order_rate desc) as ranked_cto  -- ranked campaign by click to order date

from email_campaign)

select campaign_time, campaign_title, email_clicks, orders, click_to_order_rate  -- selected required columns

from ranked_click_to_orders

where ranked_cto = 1  -- filtered result to get campaigns with best click to order rate each week

order by click_to_order_rate desc


-- L) Best performing campaigns for ROW (Rest of World) by profit


with profit_row as ( -- created CTE to rank campaigns by profit and filter only ROW (Rest of World)

SELECT campaign_time, campaign_title, country, variant_country, (profit_per_mail * emails_delivered) as profit, 
dense_rank() over(partition by country, variant_country order by (profit_per_mail * emails_delivered) desc) AS ranking  -- ranked by profit

from email_campaign

where country = 'ROW' and variant_country not like '%VIP%')  -- filtered to consider only ROW and to exclude VIP variants

select campaign_time, campaign_title, country, variant_country, profit  -- selected required columns
from profit_row 

where ranking = 1  -- filtered the result to get best performing campaigns by profit
order by profit desc



-- M) Which campaign performed best for each variant country by profits

WITH profit_country_variant as (  -- created CTE to rank the profits

select campaign_time,campaign_title, variant_country, (profit_per_mail * emails_delivered) as total_profit,
rank() over( partition by trim(variant_country) order by (profit_per_mail * emails_delivered) desc) as profit_rank  -- ranked profits
from email_campaign
where variant_country not like '%VIP%')

select campaign_time, campaign_title, variant_country, total_profit  -- selected required columns from CTE
from profit_country_variant

where profit_rank = 1  -- filtered to display only best performing campaigns for each variant country

order by total_profit desc


-- N) Profit cost percentage for each week

select campaign_time, sum(emails_delivered * profit_per_mail) as total_profit, 
sum(cost_per_mail * emails_delivered) as total_cost, 

round((sum(emails_delivered * profit_per_mail)::numeric/sum(cost_per_mail * emails_delivered)::numeric) * 100,2) as profit_cost_percentage 

from email_campaign

group by campaign_time

order by campaign_time 


