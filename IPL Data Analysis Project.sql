create table matches (id int,city varchar, date varchar,player_of_match varchar,venue varchar,neutral_venue int,
					  team1 varchar,team2 varchar,toss_winner varchar,toss_decision varchar,winner varchar,
					  result varchar,result_margin int,	eliminator varchar,	method varchar,umpire1 varchar,	umpire2
varchar);
select * from matches;

create table deliveries (id int,inning int,	over int,ball int,batsman varchar,non_striker varchar,bowler varchar,
						 batsman_runs int,extra_runs int,total_runs int,is_wicket int,dismissal_kind varchar,
						 player_dismissed varchar,fielder varchar,extras_type varchar,batting_team varchar,	
						 bowling_team varchar);
select* from deliveries;

copy matches from 
'C:\Program Files\PostgreSQL\12\data\data copy\IPL_matches.csv' delimiter ',' csv header;
select* from matches;

copy deliveries from 
'C:\Program Files\PostgreSQL\12\data\data copy\IPL_Ball.csv' delimiter ',' csv header;
select * from deliveries;


select  distinct * from deliveries order by id,inning,over,ball asc limit 20;

select  distinct * from matches order by id asc limit 20;

select * from matches where date='02-05-2013';

select * from matches where result= 'runs' and result_margin >100;

select * from matches where result= '0' order by date desc;

select count(distinct city) from matches; 
 
create table deliveries_v02 as select *, 
 CASE WHEN total_runs >= 4 then 'boundary' 
 WHEN total_runs = 0 THEN 'dot'
else 'other'
 END as ball_result 
 FROM deliveries
select*from deliveries_v02;

select count(ball_result)from deliveries_v02 
where ball_result= 'boundary';
select count(ball_result) from deliveries_v02 
where ball_result= 'dot';

select batting_team, count(*) from deliveries_v02 where ball_result = 'boundary'
group by batting_team order by count desc;

select batting_team, count(*) from deliveries_v02 where ball_result = 'dot'
group by batting_team order by count desc;

select count(*) from deliveries_v02 where not dismissal_kind='NA';

select bowler, sum(extra_runs) as total_extra_runs from deliveries group by bowler 
order by total_extra_runs desc limit 5;

create table deliveries_v03 as select a.*, b.venue, b.date AS match_date 
from deliveries_v02 AS a 
left join matches AS b ON a.id=b.id;

select venue, sum(total_runs) as total_runs_scored from deliveries_v03 group by venue
order by total_runs_scored desc;
select* from deliveries_v03;

select extract('year' from  'date' ) as ipl_year,sum(total_runs) as total_runs_scored from deliveries_v03
where venue ='Eden Gardens' group by ipl_year order by total_runs_scored desc;


select 
extract(year from match_date) as IPL_year, sum(total_runs) as runs from deliveries_v03 
where venue = 'Eden Gardens' group by IPL_year order by runs desc;

----------20--------
create table matches_corrected as select * from matches
ALTER table matches_corrected
add column team1_corr varchar(255),
add column team2_corr varchar(255);
update matches_corrected
set team1_corr = replace (team1,'Rising Pune Supergaints','Rising Pune Supergiant'),
team2_corr = replace(team2, 'Rising Pune Supergiants', 'Rising Pune Supergiant');

select distinct team1 from matches;
create table matches_corrected as select *, replace(team1, 'Rising Pune Supergiants', 'Rising Pune 
Supergiant') as team1_corr
, replace(team2, 'Rising Pune Supergiants', 'Rising Pune Supergiant') as team2_corr from matches;
select distinct team1_corr from matches_corrected;
select distinct team2_corr from matches_corrected;

------21---------
CREATE TABLE deliveries_v04 AS
SELECT
    CONCAT(id, '-', inning, '-', over, '-', ball) AS ball_id,
    *  -- Select all columns from deliveries_v03
FROM deliveries_v03;
select * from deliveries_v04;

SELECT COUNT(*) AS total_rows FROM deliveries_v04;
SELECT COUNT(DISTINCT ball_id) AS distinct_ball_ids FROM deliveries_v04;


create table deliveries_v05 as select *, row_number() over (partition by ball_id) as r_num from 
deliveries_v04;
select * from deliveries_v05;

SELECT count(distinct ball_id) as total_balls_id FROM deliveries_v05 WHERE r_num = 2;
SELECT * FROM deliveries_v05 WHERE r_num = 2;


SELECT * FROM deliveries_v05
WHERE ball_id IN (
    SELECT ball_id FROM deliveries_v05 WHERE r_num = 2
);




