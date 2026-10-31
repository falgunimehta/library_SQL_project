show databases;

use library;

show tables;

select * from books;
select * from branch;
select* from employees;
select * from issued_status;
select * from members;
select * from return_status;

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
insert into books(isbn, book_title, category, rental_price, status, author, publisher)
values
('978-1-60129-456-2', 'to kill a mockingbird', 'classic', 6.00, 'yes', 'harper lee', 'j.b. lippincott & co.');
select * from books;


-- task 2: update an existing member's address
update members
set member_address = '125 main st'
where member_id = 'c101';
select * from members;


-- task 3: delete a record from the issued status table 
-- objective: delete the record with issued_id = 'is121' from the issued_status table.
select * from issued_status
where issued_id = 'is121';

delete from issued_status
where issued_id = 'is121';


-- task 4: retrieve all books issued by a specific employee 
-- objective: select all books issued by the employee with emp_id = 'e101'.
select * from issued_status
where issued_emp_id = 'e101';


-- task 5: list members who have issued more than one book -- objective: use group by to find members who have issued more than one book.

select ist.issued_emp_id,e.emp_name,count(ist.issued_id)
from issued_status as ist
join
employees as e
on e.emp_id = ist.issued_emp_id
group by 1, 2
having count(ist.issued_id) > 1;

-- task 6: create summary tables: used ctas to generate new tables based on query results - each book and total book_issued_cnt**
create table book_cnts
as    
select 
    b.isbn,
    b.book_title,
    count(ist.issued_id) as no_issued
from books as b
join
issued_status as ist
on ist.issued_book_isbn = b.isbn
group by 1, 2;

select * from
book_cnts;


-- task 7. retrieve all books in a specific category:
select * from books
where category = 'classic';

    
-- task 8: find total rental income by category:
select
    b.category,
    sum(b.rental_price)
from books as b
join
issued_status as ist
on ist.issued_book_isbn = b.isbn
group by 1;


-- task 9 list members who registered in the last 180 days:
select * from members
where reg_date >= curdate() - interval 180 day ;  


-- task 10 list employees with their branch manager's name and their branch details:
select e.*, b.manager_id
from employees as e
join  
branch as b
on b.branch_id = e.branch_id;


-- task 11. create a table of books with rental price above a certain threshold 7usd:
create table books_price_greater_than_seven
as    
select * from books
where rental_price > 7;

select * from 
books_price_greater_than_seven;


-- task 12: retrieve the list of books not yet returned
select distinct ist.issued_book_name
from issued_status as ist
left join
return_status as rs
on ist.issued_id = rs.issued_id
where rs.return_id is null;

select * from return_status;

-- task 13: Identify Members with Overdue Books.Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.*/
select current_date

select 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    current_date - ist.issued_date as over_dues_days
from issued_status as ist
join 
members as m
    on m.member_id = ist.issued_member_id
join 
books as bk
on bk.isbn = ist.issued_book_isbn
left join 
return_status as rs
on rs.issued_id = ist.issued_id
where (current_date - ist.issued_date) > 30
order by 1;


-- task14: branch performance report
-- create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.*/

select * from branch;

select * from issued_status;

select * from employees;

select * from books;

select * from return_status;

create table branch_reports
as
select 
    b.branch_id,
    b.manager_id,
    count(ist.issued_id) as number_book_issued,
    count(rs.return_id) as number_of_book_return,
    sum(bk.rental_price) as total_revenue
from issued_status as ist
join 
employees as e
on e.emp_id = ist.issued_emp_id
join
branch as b
on e.branch_id = b.branch_id
left join
return_status as rs
on rs.issued_id = ist.issued_id
join 
books as bk
on ist.issued_book_isbn = bk.isbn
group by 1, 2;

select * from branch_reports;

-- task 15: ctas: create a table of active members
-- use the create table as (ctas) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
create table active_members
as
select * from members
where member_id in (select 
                        distinct issued_member_id   
                    from issued_status
                    where 
                        issued_date >= curdate() - interval 60 day);


select * from active_members;

-- task 16: find employees with the most book issues processed
-- write a query to find the top 3 employees who have processed the most book issues. display the employee name, number of books processed, and their branch.
select 
    e.emp_name,
    b.branch_id, b.branch_address,
    count(ist.issued_id) as no_book_issued
from issued_status as ist
join
employees as e
on e.emp_id = ist.issued_emp_id
join
branch as b
on e.branch_id = b.branch_id
group by 1,2,3;

    