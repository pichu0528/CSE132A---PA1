/*
 * Author: Pin Chu
 * Class : CSE132A
 * Due   : 3 Feburary
 * 
 * Description:
 * 
 * The boat reservations database has the following schema:
 * sailor: sname (string), rating (integer)
 * boat: bname (string), color (string), rating (integer)
 * reservation: sname (string), bname (string), day (string), start (integer),
 *              finish (integer)
 * The rating attribute for boats indicate the minimum rating required of a
 * sailor reserving the boat. The start and finish attributes indicate the starting
 * and ending times of each reservation (for simplicity, times are given as
 * integers from 0 to 24). A day can be any day of the week (including Saturday
 * and Sunday). In addition, the following hold:
 * 1. sname is the primary key of sailor (so every sailor has just one rating);
 * 2. bname is the primary key of boat (so every boat has just one color and
 *    one rating);
 * 3. {bname, day, start, finish} is the primary key of reservation (so there
 *    are no distinct reservations for the same boat on the same day for the
 *    same time period);
 * 4. bname is a non-null foreign key in the reservation relation, referencing
 *    relation boat (so every bname in reservation occurs in boat, but the
 *    converse need not be true)
 * 5. sname is a non-null foreign key in the reservation relation, referencing
 *    relation sailor (so every sname in reservation occurs in sailor, but the
 *    converse need not be true)
 * 6. the finish time for each reservation is strictly larger than the start * time;
 * 7. all reservations are for the current week.
 *
 */

 /* PART A 
 CREATE TABLE sailor(
 	sname	VARCHAR(15) 	NOT NULL,
 	rating  INTEGER 		,
 	PRIMARY KEY(sname)
 );

 CREATE TABLE boat(
 	bname	VARCHAR(20)		NOT NULL,
 	color	VARCHAR(20),
 	rating  INTERGER,
 	PRIMARY KEY(bname)
 );

CREATE TABLE reservation(
	sname	VARCHAR(20)		NOT NULL,
	bname	VARCHAR(20) 	NOT NULL,
	day     VARCHAR(10)		NOT NULL,
	start   INTEGER   		NOT NULL,
	finish	INTEGER 		NOT NULL,
	PRIMARY KEY(bname, day, start, finish),
	FOREIGN KEY (sname)REFERENCES sailor,
	FOREIGN KEY (bname)REFERENCES boat,
	CONSTRAINT chk_reservation CHECK(start < finish)
);

// Insert values into sailor
INSERT INTO sailor(sname, rating)VALUES('Brutus', 1);
INSERT INTO sailor(sname, rating)VALUES('Andy', 8);
INSERT INTO sailor(sname, rating)VALUES('Horatio', 7);
INSERT INTO sailor(sname, rating)VALUES('Rusty', 8);
INSERT INTO sailor(sname, rating)VALUES('Bob', 1);

// Insert values into boat
INSERT INTO boat(bname, color, rating)VALUES('SpeedQueen', 'white', 9);
INSERT INTO boat(bname, color, rating)VALUES('Interlake', 'red', 8);
INSERT INTO boat(bname, color, rating)VALUES('Marine', 'blue', 7);
INSERT INTO boat(bname, color, rating)VALUES('Bay', 'red', 3);

// Insert values into reservation
INSERT INTO reservation(sname, bname, day, start, finish)VALUES('Andy', 'Interlake', 'Monday', 10, 14);
INSERT INTO reservation(sname, bname, day, start, finish)VALUES('Andy', 'Marine', 'Saturday', 14, 16);
INSERT INTO reservation(sname, bname, day, start, finish)VALUES('Andy', 'Bay', 'Wednesday', 8, 12);
INSERT INTO reservation(sname, bname, day, start, finish)VALUES('Rusty', 'Bay', 'Sunday', 9, 12);
INSERT INTO reservation(sname, bname, day, start, finish)VALUES('Rusty', 'Interlake', 'Wednesday', 13, 20);
INSERT INTO reservation(sname, bname, day, start, finish)VALUES('Rusty', 'Interlake', 'Monday', 9, 11);
INSERT INTO reservation(sname, bname, day, start, finish)VALUES('Bob', 'Bay', 'Monday', 9, 12);
INSERT INTO reservation(sname, bname, day, start, finish)VALUES('Andy', 'Bay', 'Wednesday', 9, 10);
INSERT INTO reservation(sname, bname, day, start, finish)VALUES('Horatio', 'Marine', 'Tuesday', 15, 19);
*/
/* PART B - List the contents of relations sailor, boat, and reservation */

SELECT *
FROM sailor;

SELECT *
FROM boat;

SELECT *
FROM reservation;

/* PART C - write the following queries in SQL. */
/* 1. List all pairs of sailors and boats they are qualified to sail. */

SELECT s.sname, b.bname FROM   sailor s, boat b WHERE  s.rating >= b.rating;

/* 2. List, for each sailor, the number of boats they are qualified to sail. */

SELECT s.sname, SUM(CASE WHEN s.rating >=b.rating THEN 1 ELSE 0 END) FROM   sailor s, boat b GROUP BY s.sname;

/* 3. List the sailors with the lowest rating. Provide two queries:
 *    - one using the MIN aggregate function, and
 *    - another without using MIN.
 */

// With MIN aggregation function
SELECT s.sname FROM   sailor s WHERE  s.rating = (SELECT MIN(s1.rating) FROM   sailor s1);

// Without MIN aggregation function
SELECT DISTINCT s1.sname FROM   sailor s1 WHERE  s1.rating <= (SELECT DISTINCT s2.rating FROM   sailor s2 WHERE  s1.sname <> s2.sname);

/* 4. List the sailors who have at least one reservation and reserved only
 *	  red boats.
 */

SELECT s.sname FROM   sailor s WHERE  NOT EXISTS(SELECT b.color FROM   boat b, reservation r WHERE  b.bname = r.bname AND    s.sname = r.sname AND b.color <> 'red') AND (SELECT b.color FROM boat b, reservation r WHERE b.bname = r.bname AND s.sname = r.sname) = 'red';



 /* 5. List the sailors who reserved no red boat. */

SELECT DISTINCT s.sname FROM   sailor s WHERE  NOT EXISTS(SELECT * FROM boat b, reservation r WHERE s.sname = r.sname AND b.bname = r.bname AND b.color = 'red');

 /* 6. List the sailors who reserved every red boat. Provide three SQL queries,
  *    using nested sub-queries in different ways:
  *	   - with NOT IN tests;
  *    - with NOT EXISTS tests;
  *    - with COUNT aggregate functions.
  */

// With NOT IN
SELECT DISTINCT s.sname
FROM   sailor s
WHERE  s.sname NOT IN(
		SELECT s1.sname
		FROM   sailor s1, boat b, reservation r
		WHERE  s1.sname = r.sname
		  AND  b.bname = r.bname
		  AND  b.color <> 'red'
		);

// With NOT EXISTS
SELECT DISTINCT s.sname FROM   sailor s WHERE  NOT EXISTS( SELECT * FROM   boat b WHERE  b.color = 'red' AND NOT EXISTS( SELECT * FROM   reservation r WHERE  s.sname = r.sname AND  b.bname = r.bname));

// With COUNT
SELECT DISTINCT s.sname FROM   sailor s WHERE  (SELECT COUNT(DISTINCT b.bname) FROM   boat b, reservation r WHERE  s.sname = r.sname AND  b.bname = r.bname AND  b.color = 'red')=(SELECT COUNT(b.bname) FROM   boat b WHERE  b.color = 'red');

 /* 7. For each reserved boat, list the average rating of sailors having 
  *    reserved that boat.
  */

SELECT DISTINCT r.bname, AVG(s.rating) FROM   sailor s, reservation r WHERE  s.sname = r.sname GROUP BY r.bname;


/* PART D - Formulate an SQL query to verify that there are no conflicting
 *			reservations.
 */
SELECT r1.bname, r1.day, r1.sname, r1.start, r1.finish, r2.sname, r2.start, r2.finish 
FROM   reservation r1, reservation r2
WHERE  r1.sname <> r2.sname AND r1.bname = r2.bname AND r1.day = r2.day 
AND r1.start < r2.finish AND r1.finish > r2.start
GROUP BY r1.bname;

/* PART E - Formulate the following updates in SQL:
 *        1. Change all red boats to blue and all blue boats to red, 
 *			 without explicitly naming the boats involved.
 *		  2. Delete all sailors who are not qualified to sail any boat,
 *			 together with their reservations(this has to be done carefully,
 *			 to avoid violations of the referential integrity constraint from
 *			 reservation to sailor)
 */
/* 1 */
UPDATE boat SET color = 'blue' WHERE  color = 'red';

UPDATE boat SET color = 'red' WHERE  color = 'blue';

/* 2 */
DELETE FROM sailor WHERE (SELECT s.sname FROM sailor s, boat b WHERE  s.rating <= b.rating);
DELETE FROM reservation WHERE (SELECT s.sname, b.bname FROM   sailor s, boat b WHERE  s.rating <= b.rating);

 /* PART F - List again the contents of relations boat, sailor, and 
  *          reservation
  */

  SELECT *
  FROM   sailor;

  SELECT *
  FROM   boat;

  SELECT *
  FROM   reservation;			 



