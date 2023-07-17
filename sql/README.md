# Introduction


In the RDBMS and SQL project, we are creating a database and tables
for a club. We perform various CRUD operations on the data to manipulate 
the results from the data. I started by setting up a git repository for version
control and created an instance of PSQL using a Docker container. 
I set up a SQL IDE pgAdmin for executing queries and viewing the results.
I created tables by writing the SQL DDL statements in the .sql file
and executing them. After successfully creating the tables, I added
sample data from the clubdata.sql file by uploading and executing 
the file. The operations performed in the data are stored in the 
queries.sql file. For the implementation of this project, I used Git,
Github, Docker, pgAdmin, and PSQL.

# SQL Queries

###### Table Setup (DDL)
```

CREATE TABLE cd.members
(
memid integer NOT NULL,
surname character varying(200) NOT NULL,
firstname character varying(200) NOT NULL,
address character varying(300) NOT NULL,
zipcode integer NOT NULL,
telephone character varying(20) NOT NULL,
recommendedby integer,
joindate timestamp NOT NULL,
CONSTRAINT members_pk PRIMARY KEY (memid),
CONSTRAINT fk_members_recommendedby FOREIGN KEY (recommendedby)
REFERENCES cd.members(memid) ON DELETE SET NULL
);

CREATE TABLE cd.facilities
(
facid integer NOT NULL,
name character varying(100) NOT NULL,
membercost numeric NOT NULL,
guestcost numeric NOT NULL,
initialoutlay numeric NOT NULL,
monthlymaintenance numeric NOT NULL,
CONSTRAINT facilities_pk PRIMARY KEY (facid)
);

CREATE TABLE cd.bookings
(
bookid integer NOT NULL,
facid integer NOT NULL,
memid integer NOT NULL,
starttime timestamp NOT NULL,
slots integer NOT NULL,
CONSTRAINT bookings_pk PRIMARY KEY (bookid),
CONSTRAINT fk_bookings_facid FOREIGN KEY (facid) REFERENCES cd.facilities(facid),
CONSTRAINT fk_bookings_memid FOREIGN KEY (memid) REFERENCES cd.members(memid)
);
```
###### Question 1: Insert some data into a table
```
insert into cd.facilities (
  facid, name, membercost, guestcost, 
  initialoutlay, monthlymaintenance
) 
values 
  (9, 'Spa', 20, 30, 100000, 800);
```


###### Questions 2: Insert calculated data into a table
```
insert into cd.facilities (
  facid, name, membercost, guestcost, 
  initialoutlay, monthlymaintenance
) 
select 
  (
    select 
      max(facid) 
    from 
      cd.facilities
  )+ 1, 
  'Spa', 
  20, 
  30, 
  100000, 
  800;
```

###### Questions 3: Update some existing data
```
Update 
  cd.facilities 
set 
  initialoutlay = 10000 
where 
  facid = 1;
```

###### Questions 4: Update a row based on the contents of another row
```
update cd.facilities facs
    set
        membercost = (select membercost * 1.1 from cd.facilities where facid = 0),
        guestcost = (select guestcost * 1.1 from cd.facilities where facid = 0)
    where facs.facid = 1;
```

###### Questions 5: Delete all bookings
```
delete from 
  cd.bookings;
```

###### Questions 6: Delete a member from the cd.members table
```
delete from 
  cd.members 
where 
  memid = 37;
```

###### Questions 7: Control which rows are retrieved - part 2
```
select facid, name, membercost, monthlymaintenance
	from cd.facilities
	where
		membercost > 0 and
		(membercost < monthlymaintenance/50.0);

```

###### Questions 8: Basic string searches
```
Select 
  * 
from 
  cd.facilities 
where 
  name Like '%Tennis%';
```

###### Questions 9: Matching against multiple possible values
```
Select 
  * 
from 
  cd.facilities 
where 
  facid in (1, 5);
```

###### Questions 10: Working with dates
```
Select
  memid,
  surname,
  firstname,
  joindate
from
  cd.members
where
  joindate >= '2012-09-01 00:00:00';
```

###### Questions 11: Combining results from multiple queries
```
select surname
	from cd.members
union
select name
	from cd.facilities;
```

###### Questions 12: Retrieve the start times of members' bookings
```
Select
  b.starttime
from
  cd.bookings as b
  inner join cd.members as m on b.memid = m.memid
where
  m.firstname = 'David'
  and m.surname = 'Farrell';
```

###### Questions 13: Work out the start times of bookings for tennis courts
```
Select
  b.starttime,
  f.name
from
  cd.bookings as b
  inner join cd.facilities as f on b.facid = f.facid
where
  b.starttime > '2012-09-21 00:00:00'
  and b.starttime < '2012-09-21 23:59:59'
  and f.name like 'Tennis%';
```

###### Questions 14: Produce a list of all members, along with their recommender
```
select
  m1.firstname as memfname,
  m1.surname as memsname,
  m2.firstname as recfname,
  m2.surname as recsname
from
  cd.members m1
  left join cd.members m2 on m2.memid = m1.recommendedby
order by
  memsname,
  memfname;
```

###### Questions 15: Produce a list of all members who have recommended another member
```
select
  Distinct m1.firstname as firstname,
  m1.surname as surname
from
  cd.members as m1
  inner join cd.members as m2 on m1.memid = m2.recommendedby
order by
  m1.surname,
  m1.firstname;
```

###### Questions 16: Produce a list of all members, along with their recommender, using no joins.
```
select
  distinct mems.firstname || ' ' || mems.surname as member,
  (
    select
      recs.firstname || ' ' || recs.surname as recommender
    from
      cd.members recs
    where
      mems.recommendedby = recs.memid
  )
from
  cd.members mems
order by
  member;
```

###### Questions 17: Count the number of recommendations each member makes
```
Select
  recommendedby,
  Count(*)
from
  cd.members
where
  recommendedby is not null
group by
  recommendedby
order by
  recommendedby asc;
```

###### Questions 18: List the total slots booked per facility
```
select
  f.facid,
  SUM(b.slots) as "Total Slots"
from
  cd.facilities as f
  inner join cd.bookings as b on f.facid = b.facid
group by
  f.facid
order by
  f.facid asc;
```

###### Questions 19: List the total slots booked per facility in a given month
```
Select
  f.facid,
  Sum(b.slots) as "Total Slots"
from
  cd.facilities as f
  inner join cd.bookings as b on f.facid = b.facid
where
  b.starttime >= '2012-09-01 00:00:00'
  and b.starttime <= '2012-09-30 23:59:59'
group by
  f.facid
order by
  "Total Slots";
```

###### Questions 20: List the total slots booked per facility per month
```
Select
  f.facid,
  Extract(
    Month
    from
      b.starttime
  ) as month,
  SUM(b.slots) as "Total Slots"
from
  cd.facilities as f
  inner join cd.bookings as b on f.facid = b.facid
where
  Extract(
    Year
    from
      b.starttime
  ) = '2012'
group by
  f.facid,
  month
order by
  f.facid,
  month;
```

###### Questions 21: Find the count of members who have made at least one booking
```
Select
  count(distinct memid)
from
  cd.bookings;
```

###### Questions 22: List each member's first booking after September 1st 2012
```
Select
  m.surname,
  m.firstname,
  m.memid,
  min(b.starttime)
from
  cd.members as m
  inner join cd.bookings as b on m.memid = b.memid
where
  b.starttime >= '2012-09-01 00:00:00'
group by
  m.surname,
  m.firstname,
  m.memid
order by
  m.memid;
```

###### Questions 23: Produce a list of member names, with each row containing the total member count
```
Select
  (
    Select
      count(distinct memid)
    from
      cd.members
  ),
  firstname,
  surname
from
  cd.members;
```

###### Questions 24: Produce a numbered list of members
```
Select
  row_number() over () as row_number,
  firstname,
  surname
from
  cd.members
order by
  joindate;
```

###### Questions 25: Output the facility id that has the highest number of slots booked, again
```
select
  facid,
  sum(slots) as totalslots
from
  cd.bookings
group by
  facid
having
  sum(slots) = (
    select
      max(sum2.totalslots)
    from
      (
        select
          sum(slots) as totalslots
        from
          cd.bookings
        group by
          facid
      ) as sum2
  );
```

###### Questions 26: Format the names of members
```
Select
  surname || ', ' || firstname as name
from
  cd.members;
```

###### Questions 27: Find telephone numbers with parentheses
```
Select
  memid,
  telephone
from
  cd.members
where
  telephone ~ '[()]';
```

###### Questions 28: Count the number of members whose surname starts with each letter of the alphabet
```
Select
  substring(surname, 1, 1) as letter,
  count(memid)
from
  cd.members
group by
  letter
order by
  letter;
```