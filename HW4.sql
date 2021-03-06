--NAME: Brandon Hahn
--ASSIGNMENT: CPTS 451 HW4

--1. 
    -- find the meeting recordings that took place before '2022-01-17'
SELECT users.user_id, users.firstname,meeting.meeting_id, meeting.title, meeting.meeting_time, meetingrecording.start_time, meetingrecording.recording_number
FROM (meetingrecording INNER JOIN meeting ON meetingrecording.meeting_id = meeting.meeting_id) INNER JOIN users ON meeting.instructor_id = users.user_id
where meetingrecording.start_time <= '2022-01-17'
ORDER BY users.user_id, meeting.meeting_id, meetingrecording.recording_number;

--2. 
    --find the instructors who are teaching courses with 4 or more students enrolled
SELECT users.firstname, users.lastname, enrolledin.course_id, course.title, COUNT(enrolledin.course_id) as count
FROM enrolledin INNER JOIN course ON enrolledin.course_id = course.course_id INNER JOIN teaches ON enrolledin.course_id = teaches.course_id INNER JOIN users ON teaches.instructor_id = users.user_id
GROUP BY enrolledin.course_id, course.title, teaches.instructor_id, users.firstname, users.lastname
HAVING COUNT(enrolledin.course_id) > 3
ORDER BY enrolledin.course_id;


--3
    -- find the pair of messages that are posted at the same time by different users	
SELECT table1.meeting_id, table1.message_time, concat(table1.message_text, CHR(13),CHR(10), table2.message_text) AS message, table1.user_id, table2.user_id
FROM message table1 INNER JOIN message table2 ON table1.message_time = table2.message_time
WHERE table1.message_time = table2.message_time AND table1.user_id < table2.user_id ;


--4
    -- find the distinct instructors that teach "Machine Learning" and "Artificial Intelligence" And teach more than two courses each
SELECT users.firstname, users.lastname
FROM (academicfields table1 INNER JOIN academicfields table2 ON table1.instructor_id = table2.instructor_id) INNER JOIN users ON table1. instructor_id = user_id
WHERE table1.instructor_id = table2.instructor_id AND table1.academicfield = 'Machine Learning' AND table2.academicfield = 'Artificial Intelligence';


--5a
    --Find the meetings whose durations are longer than the average duration of all meetings
SELECT *
FROM meeting
GROUP BY meeting_id
HAVING duration > ALL
	(SELECT AVG(duration)
	 FROM meeting
	)
ORDER BY meeting_id;


--5b
    --Find the meetings whose durations are longer than the average duration of the meetings for the course they belong to
SELECT *
FROM meeting table1
WHERE table1.duration > 
	(SELECT AVG(duration)
	 FROM meeting averageTable
	 WHERE table1.course_id = averageTable.course_id
	)
ORDER BY meeting_id;


--6
    --find the students who didn't attend any meetings of a course that they are enrolled in
SELECT distinct b1.student_id, b1.course_id
FROM 
(
select distinct e1.student_id, e1.course_id
FROM meeting m1 INNER JOIN enrolledin e1 ON m1.course_id = e1.course_id
EXCEPT
SELECT distinct e1.student_id, e1.course_id
FROM (enrolledin e1 INNER JOIN meeting m1 ON e1.course_id = m1.course_id) INNER JOIN attended a1 ON m1.meeting_id = a1.meeting_id
WHERE e1.student_id = a1.student_id) as b1
ORDER BY b1.student_id;


--7
    -- find the CPTS451 students that missed a class, but watched the lecture
SELECT z3.student_id, z4.meeting_id, z4.title, z3.recording_number
FROM(
SELECT distinct z1.student_id, z1.meeting_id, z2.recording_number
FROM(
SELECT b2.student_id, b1.meeting_id
FROM(
select *
FROM (
select student_id, meeting_id FROM watched
EXCEPT
(
SELECT a1.student_id, a1.meeting_id 
FROM attended as a1 INNER JOIN (SELECT meeting_id FROM meeting WHERE course_id = 'CptS451') as m1 ON a1.meeting_id = m1.meeting_id
where a1.meeting_id = m1.meeting_id)) as t1) as b1
INNER JOIN
(
select * from enrolledin where course_id = 'CptS451'
	) as b2
ON b1.student_id = b2.student_id
) as z1 INNER JOIN watched as z2 ON z1.student_id = z2.student_id) AS z3 INNER JOIN meeting as z4 ON z3.meeting_id = z4.meeting_id
ORDER BY z3.student_id;



--8
    --Find most recent message from CPTS courses
SELECT b1.user_id, u1.firstname, u1.lastname, b1.message_text, b1.meeting_id FROM (
select *
FROM(
SELECT MAX(m1.message_time)
FROM (
SELECT user_id, message_time, message_text, meeting_id
FROM message
) as m1 INNER JOIN (
SELECT meeting_id
FROM meeting
WHERE course_id LIKE 'CptS%'
) as meet1
ON m1.meeting_id = meet1.meeting_id
) as maxM INNER JOIN message mess
ON maxM.max = mess.message_time) as b1
INNER JOIN users u1 
ON b1.user_id = u1.user_id;


--9
    -- find when the number of messages posted by the instructors is greater than the number of messages from students
SELECT z.meeting_id, meet.title, z.instructorcount as icount, z.studentcount as scount
FROM (
SELECT stude.meeting_id, instruc.instructorcount, stude.studentcount FROM (
SELECT m1.meeting_id, SUM(m1.count) as instructorCount
FROM (
select meeting_id, user_id, COUNT(user_id)
FROM message
GROUP BY meeting_id, user_id
ORDER BY meeting_id) as m1 INNER JOIN instructor in1 ON m1.user_id = in1.instructor_id
GROUP BY m1.meeting_id
) as instruc
INNER JOIN 
(
SELECT m1.meeting_id, SUM(m1.count) as studentCount
FROM (
select meeting_id, user_id, COUNT(user_id)
FROM message
GROUP BY meeting_id, user_id
ORDER BY meeting_id) as m1 INNER JOIN student s1 ON m1.user_id = s1.student_id
GROUP BY m1.meeting_id
)
as stude
ON instruc.meeting_id = stude.meeting_id
) as z INNER JOIN meeting as meet ON z.meeting_id = meet.meeting_id
WHERE z.instructorcount > z.studentcount;




--10
SELECT tableRecord.meeting_id, tableRecord.title, tableUser.user_count, tableRecord.record_count, tableRecord.total_time
FROM
(
SELECT m1.meeting_id, m1.title, count(a1.student_id) as user_count
FROM (
SELECT meeting_id, title
FROM meeting
) as m1
INNER JOIN attended as a1
ON m1.meeting_id = a1.meeting_id
GROUP BY m1.meeting_id, m1.title
ORDER BY m1.meeting_id
) as tableUser 

INNER JOIN
(
SELECT m1.meeting_id, m1.title, count(a1.recording_number) as record_count, sum(extract (epoch from (end_time - start_time))) as total_time
FROM (
SELECT meeting_id, title
FROM meeting
) as m1
INNER JOIN meetingrecording as a1
ON m1.meeting_id = a1.meeting_id
GROUP BY m1.meeting_id,m1.title
ORDER BY m1.meeting_id
) as tableRecord
ON tableUser.meeting_id = tableRecord.meeting_id;