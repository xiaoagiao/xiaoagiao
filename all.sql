set serveroutput on 
create   sequence myseq 
start with 3  
increment by 1 
cache 10;
Select qty from booktypeinfo where book_type_id =20200402;
select count(*) from borrow_order where status is not null;
select count(status),a.book_type_id from booktypeinfo a,books b,borrow_order c 
where  b.book_id=c.book_id and status is not null and a.book_type_id =b.book_type_id 
group by a.book_type_id  order by count(status) desc;
select book_id,c_id from borrow_order where status='borrowed';
declare
borroweda int;
book_name booktypeinfo.book_name%type;
qty booktypeinfo.qty%type;
begin
  select count(*) into borroweda from borrow_order where status <>  'returned';
  select book_name,qty into book_name,qty from booktypeinfo order by qty asc;
  qty:=qty+borroweda; 
dbms_output.put_line('book_name:' || book_name  ||  '  qty:' || qty);
end;
/
set serveroutput on
declare
borroweda int;
book_name booktypeinfo.book_name%type;
qty booktypeinfo.qty%type;
begin
  select count(*) into borroweda from borrow_order where status <>  'returned';
  select book_name,qty into book_name,qty from booktypeinfo order by qty asc;
  qty:=qty+borroweda; 
dbms_output.put_line('书名:' || book_name  ||  '    收录数量:' || qty);
end;
/
create or replace procedure p1
(cid   in int,
bookid in int
)
is
store booktypeinfo.qty%type;   --储存库存数量
no_return int;    --储存借阅状态
orderid int;            
c1 int;                                    --c=0则没有此用户 c<>0则存在此用户         
out_time varchar2(20);         --借出时间
due varchar2(20);                --过期时间
q1 exception;                    --库存为零异常
q exception;                      --有未归还书本异常
begin
orderid:=myseq.nextval;      --借阅id根据myseq序列自动生成
select sysdate into out_time from dual;            --插入系统时间
select add_months(sysdate,+1) into due from dual;   --插入归还时间
select   count(*) into c1 from borrow_order where c_id=cid;     --c1=0为不存在c1<>0为存在
select qty into store from booktypeinfo a,books b where
book_id=bookid and a.book_type_id =b.book_type_id;    --检查库存数量
select count(status)  into no_return from borrow_order 
where status='borrowed' and c_id=cid;    --检查用户借阅状态 
if  (c1 <>0) then
if (store=0)  then
raise q1;
elsif  (no_return = 1) then
raise q;
else
insert into borrow_order  (order_id,c_id,book_id,chekout_date,due_date,return_date,status)
values(orderid,cid,bookid,out_time,due,null,'borrowed');
commit;
dbms_output.put_line('借阅成功!√');
end if;
end if;
if (c1=0) then
if (store = 0) then
raise q1;
else
insert into borrow_order  (order_id,c_id,book_id,chekout_date,due_date,return_date,status)
values(orderid,cid,bookid,out_time,due,null,'borrowed');
commit;
dbms_output.put_line('借阅成功!√');
end if;
end if;
exception
when q then 
dbms_output.put_line('一次只能借阅一本图书!');
when q1 then
dbms_output.put_line('可借数量为0!');
end p1;
/
