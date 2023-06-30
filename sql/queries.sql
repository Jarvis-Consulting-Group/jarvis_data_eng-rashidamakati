-- Query 1: Insert some data into a table
insert into cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
    values (9, 'Spa', 20, 30, 100000, 800);

-- Query 2: Let's try adding the spa to the facilities table again. This time, though, we want to automatically generate the value for the next facid, rather than specifying it as a constant. Use the following values for everything else:
-- Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.

insert into cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
    select (select max(facid) from cd.facilities)+1, 'Spa', 20, 30, 100000, 800;

-- Query 3: We made a mistake when entering the data for the second tennis court. The initial outlay was 10000 rather than 8000: you need to alter the data to fix the error.
Update cd.facilities set initialoutlay = 10000 where facid = 1;

-- Query 4: We want to alter the price of the second tennis court so that it costs 10% more than the first one. Try to do this without using constant values for the prices, so that we can reuse the statement if we want to.
update cd.facilities facs
    set
        membercost = (select membercost * 1.1 from cd.facilities where facid = 0),
        guestcost = (select guestcost * 1.1 from cd.facilities where facid = 0)
    where facs.facid = 1;

-- Query 5: As part of a clearout of our database, we want to delete all bookings from the cd.bookings table. How can we accomplish this?
delete from cd.bookings;

-- Query 6: We want to remove member 37, who has never made a booking, from our database. How can we achieve that?
delete from cd.members where memid = 37;

-- Query 7 How can you produce a list of facilities that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost? Return the facid, facility name, member cost, and monthly maintenance of the facilities in question.
select facid, name, membercost, monthlymaintenance
	from cd.facilities
	where
		membercost > 0 and
		(membercost < monthlymaintenance/50.0);

-- Query 8: How can you produce a list of all facilities with the word 'Tennis' in their name?
Select * from cd.facilities where name Like '%Tennis%';

-- Query 9: How can you retrieve the details of facilities with ID 1 and 5? Try to do it without using the OR operator.
Select * from cd.facilities where facid in (1,5);

-- Query 10: How can you produce a list of members who joined after the start of September 2012? Return the memid, surname, firstname, and joindate of the members in question.
Select
  memid,
  surname,
  firstname,
  joindate
from
  cd.members
where
  joindate >= '2012-09-01 00:00:00';


-- Query 11: How can you produce a list of members who joined after the start of September 2012? Return the memid, surname, firstname, and joindate of the members in question.
select surname
	from cd.members
union
select name
	from cd.facilities;

-- Query 12: How can you produce a list of the start times for bookings by members named 'David Farrell'?
Select
  b.starttime
from
  cd.bookings as b
  inner join cd.members as m on b.memid = m.memid
where
  m.firstname = 'David'
  and m.surname = 'Farrell';

-- Query 13: How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'? Return a list of start time and facility name pairings, ordered by the time.
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

-- Query 14: How can you output a list of all members, including the individual who recommended them (if any)? Ensure that results are ordered by (surname, firstname).
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

-- Query 15: How can you output a list of all members who have recommended another member? Ensure that there are no duplicates in the list, and that results are ordered by (surname, firstname).
select
  Distinct m1.firstname as firstname,
  m1.surname as surname
from
  cd.members as m1
  inner join cd.members as m2 on m1.memid = m2.recommendedby
order by
  m1.surname,
  m1.firstname;

-- Query 16: How can you output a list of all members, including the individual who recommended them (if any), without using any joins? Ensure that there are no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered.
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

-- Query 17: Count the number of recommendations each member makes.
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

-- Query 18: List the total slots booked per facility
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


-- Query 19: List the total slots booked per facility in a given month
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

-- Query 20:  List the total slots booked per facility per month
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


