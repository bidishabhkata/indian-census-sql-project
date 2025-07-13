use project_census;
select * from dataset1;
select * from dataset2 ;
-- number of rows into the dataset

select count(*) from dataset1;
select count(*) from dataset2;

-- dataset for Jharkhan and Bihar

select * from dataset1 where state in ("Jharkhand","Bihar");

-- population of India

select sum(population) as total_population from dataset2;

-- average growth 

select state, round(avg(growth),2) as avg_growth from dataset1 group by state;

-- average sex-ratio

select state, round(avg(sex_ratio),0) as avg_sex_ratio from dataset1 
group by state
order by avg_sex_ratio desc;

-- average literacy rate 

select state, round(avg(literacy),2) as avg_literacy_rate from dataset1 
group by state
 having avg_literacy_rate>90
 order by avg_literacy_rate desc;
 
 -- top 3 states highest growth%
 
 select state, concat(round(avg(growth),2),"%") as avg_growth from dataset1 
 group by state 
 order by avg(growth) desc limit 3 ;
 
 -- bottom 3 states with lowest sex ratio
 
 select state, round(avg(sex_ratio),0) as avg_sex_ratio from dataset1 
group by state
order by avg_sex_ratio 
limit 3;
 
 -- top and bottom 3 states in literacy rate
 
 with top3 as(
select state, round(avg(literacy),2) as avg_literacy_rate,"top" as category from dataset1 
group by state
 order by avg_literacy_rate desc
 limit 3 ),
 bottom3 as(
 select state, round(avg(literacy),2) as avg_literacy_rate,"Bottom" as category from dataset1 
group by state
order by avg_literacy_rate
limit 3 )
select * from bottom3
union 
select * from top3;

-- states starting with letter a 

select distinct state from dataset1 where state like "a%" or state like "b%" order by state;

select distinct state from dataset1 where state like "a%" and state like "%m" ;

-- joing both tables
-- total males and females

select c.state,sum(c.male) as total_male,sum(c.female) as total_female from
(select gn.district,gn.state, round(gn.population/(gn.sex_ratio+1),0) as male , round(((gn.population*gn.sex_ratio)/(gn.sex_ratio+1)),0) as female from
(select a.district,a.state,a.sex_ratio/1000 as sex_ratio,cast(replace(b.population,",","")as unsigned) as population from dataset1 as a inner join dataset2 as b on a.district=b.district ) gn) c
group by state;

-- total literate people

select c.state, sum(c.literate_people) as total_literate, sum(c.illiterate_people) as total_illiterate from
(select d.district,d.state, round((d.population*d.literacy),0) as literate_people, round((1-d.literacy)*d.population,0) as illiterate_people from
(select a.district,a.state,a.literacy/100 as literacy,cast(replace(b.population,",","")as unsigned) as population from dataset1 as a inner join dataset2 as b on a.district=b.district ) d)c
group by state;

-- population in previous census

select sum(m.total_prev_census) as total_prev_census , sum(m.total_current_census) as total_current_census from
(select c.state, sum(c.prev_pop) as total_prev_census, sum(c.population) as total_current_census from
(select d.district,d.state, round((d.population/(1+d.growth)),0) as prev_pop, d.population from
(select a.district,a.state,a.growth/100 as growth ,cast(replace(b.population,",","")as unsigned) as population from dataset1 as a inner join dataset2 as b on a.district=b.district ) d)c
group by state)m;

-- population vs area

select (g.total_area/g.total_prev_census) as prev_census_vs_area , (g.total_area/g.total_current_census) as current_census_vs_area from

(select q.*,r.total_area from
(select "1" as keyy,n.* from
(select sum(m.total_prev_census) as total_prev_census , sum(m.total_current_census) as total_current_census from
(select c.state, sum(c.prev_pop) as total_prev_census, sum(c.population) as total_current_census from
(select d.district,d.state, round((d.population/(1+d.growth)),0) as prev_pop, d.population from
(select a.district,a.state,a.growth/100 as growth ,cast(replace(b.population,",","")as unsigned) as population from dataset1 as a inner join dataset2 as b on a.district=b.district ) d)c
group by state)m)n) q inner join 
(select "1" as keyy,z.* from
(select sum(area_km2) as total_area from dataset2) z) r on q.keyy=r.keyy) g;

-- top 3 districts from each states which have highest literacy rate

select a.* from
(select district,state,literacy,rank() over (partition by state order by literacy desc) as rankk from dataset1) a
 where rankk in(1,2,3) order by state;
 





