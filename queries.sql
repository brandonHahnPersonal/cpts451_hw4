-- find the meeting recordings that took place before '2022-01-17'
SELECT users.user_id, users.firstname,meeting.meeting_id, meeting.title, meeting.meeting_time, meetingrecording.start_time, meetingrecording.recording_number
FROM (meetingrecording INNER JOIN meeting ON meetingrecording.meeting_id = meeting.meeting_id) INNER JOIN users ON meeting.instructor_id = users.user_id
where meetingrecording.start_time <= '2022-01-17'
ORDER BY users.user_id, meeting.meeting_id, meetingrecording.recording_number


--find the instructors who are teaching courses with 4 or more students enrolled
SELECT users.firstname, users.lastname, enrolledin.course_id, course.title, COUNT(enrolledin.course_id) as count
FROM enrolledin INNER JOIN course ON enrolledin.course_id = course.course_id INNER JOIN teaches ON enrolledin.course_id = teaches.course_id INNER JOIN users ON teaches.instructor_id = users.user_id
GROUP BY enrolledin.course_id, course.title, teaches.instructor_id, users.firstname, users.lastname
HAVING COUNT(enrolledin.course_id) > 3
ORDER BY enrolledin.course_id