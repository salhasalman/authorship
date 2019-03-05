show databases;
use amazon;
#show tables;
#select * from amazon_reviews  limit 10;
#select customer_id from amazon_reviews group by customer_id having count(customer_id)>50;
#select customer_id, count(customer_id) from amazon_reviews group by customer_id order by count(customer_id) desc;
#select review_text from amazon_reviews where customer_id='AFVQZQ8PW0L';
##below get the satisfied dataset
#select review_text,customer_id from amazon_reviews where customer_id in (select customer_id from amazon_reviews group by customer_id having count(customer_id)>50) order by customer_id;
#drop table prolific_id;
drop table prolific_name_pre;
#this table record 1000 customer_id and name which is prolific
create table prolific_name_pre as 
	select customer_name as  pro_name, customer_id as pro_id
		from amazon_reviews 
			group by customer_name,customer_id  #customer name & equal customer_id equal at the same time
				having count(customer_name)>200 limit 1100;

drop table prolific_name;  
#choose unique id for the same customer_name              
create table prolific_name as 
	select pro_name, min(pro_id) as pro_id
    from prolific_name_pre group by pro_name limit 1000;

#select * from prolific_name;
#show tables;
#select * from prolific_name limit 10;

 
#drop table mytest;
#create table mytest as select review_text,review_title, customer_id,customer_name 
#from amazon_reviews 
#right join prolific_name on amazon_reviews.customer_name=prolific_name.pro_name limit 10;
# into outfile "/var/lib/mysql-files/test.csv";
#select * from mytest;
#show tables;

drop table amazon_review_ordered;
#order amazon_review by name
create table  amazon_review_ordered as select * from  amazon_reviews order by customer_id;  #order by name
select * from amazon_review_ordered limit 10;

#add index for the same id (same name seems work not right)
drop table amazon_review_ordered_combine_rownum;
set @num := 0, @customer_id := '';
create table amazon_review_ordered_combine_rownum as 
select review_text,review_title, customer_id,customer_name,
      @num := if(@customer_id = customer_id, @num + 1, 1) as row_number,
      @customer_id := customer_id as dummy
from amazon_review_ordered;
#select * from amazon_review_ordered_combine_rownum limit 2500;

drop table amazon_review_prolific_ordered_combine_rownum;
create table amazon_review_prolific_ordered_combine_rownum as 
select review_text,review_title, customer_id,customer_name, row_number
from amazon_review_ordered_combine_rownum
right join prolific_name on prolific_name.pro_id=amazon_review_ordered_combine_rownum.customer_id;
#select * from amazon_review_prolific_ordered_combine_rownum limit 2500;

#drop table final100;
create table final200 as select * from amazon_review_prolific_ordered_combine_rownum where row_number<=201 and row_number>1;
#select * from final into outfile  "/var/lib/mysql-files/final.csv";

#drop table final_train100;
create table final_train200 as 
	select * from final200 where row_number<=171 and row_number>1;

#drop table final_val100;
create table final_val200 as
	select * from final200 where row_number<=181 and row_number>171;

#drop table final_test100;    
create  table final_test200 as 
	select * from final200 where row_number<=201 and row_number>181;
