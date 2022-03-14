-- find the meeting recordings that took place before '2022-01-17'
SELECT users.user_id, users.firstname,meeting.meeting_id, meeting.title, meeting.meeting_time, meetingrecording.start_time, meetingrecording.recording_number
FROM (meetingrecording INNER JOIN meeting ON meetingrecording.meeting_id = meeting.meeting_id) INNER JOIN users ON meeting.instructor_id = users.user_id
where meetingrecording.start_time <= '2022-01-17'
ORDER BY users.user_id, meeting.meeting_id, meetingrecording.recording_number;


--find the instructors who are teaching courses with 4 or more students enrolled
SELECT users.firstname, users.lastname, enrolledin.course_id, course.title, COUNT(enrolledin.course_id) as count
FROM enrolledin INNER JOIN course ON enrolledin.course_id = course.course_id INNER JOIN teaches ON enrolledin.course_id = teaches.course_id INNER JOIN users ON teaches.instructor_id = users.user_id
GROUP BY enrolledin.course_id, course.title, teaches.instructor_id, users.firstname, users.lastname
HAVING COUNT(enrolledin.course_id) > 3
ORDER BY enrolledin.course_id;


-- find the pair of messages that are posted at the same time by different users	
SELECT table1.meeting_id, table1.message_time, concat(table1.message_text, CHR(13), table2.message_text) AS message, table1.user_id, table2.user_id
FROM message table1 INNER JOIN message table2 ON table1.message_time = table2.message_time
WHERE table1.message_time = table2.message_time AND table1.user_id < table2.user_id ;


-- find the distinct instructors that teach "Machine Learning" and "Artificial Intelligence" And teach more than two courses each
SELECT users.firstname, users.lastname
FROM (academicfields table1 INNER JOIN academicfields table2 ON table1.instructor_id = table2.instructor_id) INNER JOIN users ON table1. instructor_id = user_id
WHERE table1.instructor_id = table2.instructor_id AND table1.academicfield = 'Machine Learning' AND table2.academicfield = 'Artificial Intelligence';


--Find the meetings whose durations are longer than the average duration of all meetings
SELECT *
FROM meeting
GROUP BY meeting_id
HAVING duration > ALL
	(SELECT AVG(duration)
	 FROM meeting
	)
ORDER BY meeting_id;


--Find the meetings whose durations are longer than the average duration of the meetings for the course they belong to
SELECT *
FROM meeting table1
WHERE table1.duration > 
	(SELECT AVG(duration)
	 FROM meeting averageTable
	 WHERE table1.course_id = averageTable.course_id
	)
ORDER BY meeting_id;




SELECT distinct e1.student_id, e1.course_id
FROM (enrolledin e1 INNER JOIN meeting m1 ON e1.course_id = m1.course_id) INNER JOIN attended a1 ON m1.meeting_id = a1.meeting_id
WHERE e1.student_id = a1.student_id