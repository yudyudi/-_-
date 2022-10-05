-- (1) youtube DB 생성
CREATE DATABASE youtube default CHARACTER SET UTF8; 
show databases;

-- (2) yutube DB 사용
-- use DB_NAME
use youtube;

-- (3) [final]db_insert를 사용하여 data 삽입 및 확인 pandas와 pmysql 사용.
select * from video_info;
select * from youtuber;
desc video_info;
desc youtuber;

-- (4) 질문 처리
-- 0. 크롤링한 총 비디오의 개수는?
select count(*) from video_info; -- 463개

-- 1.1 2020년 이후 가장 리뷰가 많았던 해는? 예)갤럭시의 경우
-- 검색어 갤럭시의 경우 2022년도에 가장 많은 리뷰 영상(214건)이 업로드 되어 있음.
select year(create_date), count(title) from video_info
where search_query in ('갤럭시', '갤럭시z플립 4', '갤럭시폴드4')
and year(create_date) >= 2020
group by 1 with rollup
order by 1;  -- 218

-- 1.2 2020년 이후 가장 리뷰가 많았던 해는? 예)아이폰의 경우
-- 검색어 아이폰의 경우 2022년도에 가장 많은 리뷰 영상(226건)이 업로드 되어 있음.
select year(create_date), count(title) from video_info
where search_query in ('아이폰', '아이폰14', 'iphone 14', 'iphone 14 pro')
and year(create_date) >= 2020
group by 1 with rollup
order by 1;  -- 243

-- 1.3 연도별, 검색어별 리뷰영상 개수 확인하기
select year(create_date) as years, search_query, count(id) as count_num
from video_info
group by 1,2 
order by 1,3 ;

select search_query, year(create_date), count(*) from video_info_v
where search_query like '%갤럭시%'
and year(create_date) in (2020,2021,2022)
group by 1,2 with rollup 

union all

select search_query, year(create_date), count(*) from video_info_v
where search_query like '%아이폰%'
and year(create_date) in (2020,2021,2022)
group by 1,2 with rollup
order by 1,2 desc;  

-- 2.1 애플과 삼성 조회수
with tmp as (
select year(create_date) as year_v , search_query, sum(view) as views
  from video_info
  group by 1,2
  order by 1
  )
select year_v '연도',
 sum(case when search_query in ('갤럭시','갤럭시z플립 4', '갤럭시폴드4') then round(views/10000,1) else 0 end) '삼성 (단위: 만 회)',
 sum(case when search_query in ('아이폰', '아이폰14', 'iphone 14', 'iphone 14 pro') then round(views/10000,1) else 0 end) '애플 (단위: 만 회)'
 from tmp
 group by year_v;
 
-- 2.2 2022년도 검색어별 조회수 확인하기
select year(create_date) , search_query, concat(sum(view),' 회')
  from video_info
  where year(create_date) = 2022
  group by 2,1 ;
  
-- 3 얼마나 많은 유튜버들이 (갤럭시 zflip4, 아이폰14등등 몇개의 컨텐츠를 만들었는지)?
select count(id) as "유투버 수 (단위: 명)" from youtuber;

-- 3.1 얼마나 많은 유튜버들이 아래와 같은 각각의 컨텐츠들을 만들었는지?
--      ex) 얼마나 많은 유튜버들이 "갤럭시z플립4"의 컨텐츠를 만들었는지?
-- serch_query는 "갤럭시z플립4" 대신 아래와 같이 바꾸면 된다.
-- 갤럭시, 갤럭시z플립 4, 갤럭시폴드4 /아이폰, 아이폰14, iphone 14, iphone 14 pro
select count(v.title) as "갤럭시z플립 4 컨텐츠"
from video_info v 
inner join youtuber y 
on v.youtuber_id = y.id
where v.search_query='갤럭시z플립 4';

-- 3.1.2 유튜버들이 쿼리별로 몇개의 컨텐츠를 만들었는지?
select y.youtuber_name, v.search_query, count(v.title) "동영상 수 (단위: 개)"
from video_info v
inner join youtuber y 
on v.youtuber_id = y.id 
group by 1,2 
order by 1,2;

-- 3.1.3 유튜버들이 회사별로 몇개의 컨텐츠를 만들었는지?
with tmp as (select y.youtuber_name as name, v.search_query as query, count(v.title) as title
from video_info v
inner join youtuber y 
on v.youtuber_id = y.id
group by 1 
order by 1,2)
select name,
sum(case when query in ('갤럭시','갤럭시z플립 4', '갤럭시폴드4') then title else 0 end) '삼성',
sum(case when query in ('아이폰', '아이폰14', 'iphone 14', 'iphone 14 pro') then title else 0 end) '애플' from tmp
group by name order by title desc;

select count(*) from video_info where youtuber_id=0;

-- 3.2 어떤 유튜버들이 "갤럭시z플립4"로 얼마나 많은 컨텐츠를 만들었는지
--         ex) ITSub잇섭은 "갤럭시z플립4"를 가지고 몇개의 컨텐츠를 만들었는지?
select y.youtuber_name, count(v.youtuber_id) as "동영상 수 (단위: 개)"
from video_info v 
inner join youtuber y 
on v.youtuber_id = y.id
where v.search_query='갤럭시z플립 4'
group by 1 order by 2 desc;

-- 3.2.1 아이폰14을 가지고도 테스트
select y.youtuber_name, count(v.youtuber_id) as "동영상 수 (단위: 개)"
from video_info v 
inner join youtuber y 
on v.youtuber_id = y.id
where v.search_query='아이폰14'
group by 1 order by 2 desc;

-- 3.3 갤럭시z플립 4의 유튜버별 동영상 갯수 ex) 
select y.youtuber_name, count(v.youtuber_id) as "동영상 수 (단위: 개)", v.search_query
from video_info v 
inner join youtuber y 
on v.youtuber_id = y.id
where v.search_query='갤럭시z플립 4'
group by 1 order by 1;

-- 3.4 갤럭시z플립 4의 유튜버별 동영상 갯수 ex) 
select y.youtuber_name, count(v.youtuber_id) as "동영상 수 (단위: 개)", v.search_query
from video_info v 
inner join youtuber y 
on v.youtuber_id = y.id
group by 1 order by 1 desc, 2 desc;

-- 3.5 구독자수 많은 유튜버 순
select youtuber_name, subscribers from youtuber order by 2 desc;

-- 3.6 영상 조회수가 많은 순
select y.youtuber_name, round(AVG(v.view)) as "평균 조회수 순"
from video_info v
inner join youtuber y 
on v.youtuber_id = y.id 
group by youtuber_name order by 2 desc;

-- 3.7 TOP 조회수 Title 추출
select title, contents, view, search_query 
from video_info 
order by 3 desc
limit 1;

-- 3.8 회사별 TOP 조회수 Title 추출
(select title, contents, view, search_query 
from video_info
where search_query in ('아이폰', '아이폰14', 'iphone 14', 'iphone 14 pro')
group by title
order by 3 desc
limit 3)
union all
(select title, contents, view, search_query  
from video_info
where search_query in ('갤럭시', '갤럭시z플립 4', '갤럭시폴드4')
group by title
order by 3 desc
limit 3);
