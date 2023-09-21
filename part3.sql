--CREATE TABLE present_transferred_points AS 
--WITH tb AS (SELECT * FROM transferredpoints)
--SELECT checkingPeer AS Peer1, checkedPeer AS Peer2,
--(PointsAmount - COALESCE ((SELECT PointsAmount FROM tb 
--WHERE tb.CheckingPeer = t.CheckedPeer AND tb.checkedPeer = t.CheckingPeer), 0))
--AS PointsAmount
--FROM transferredpoints t ;
--
--DROP TABLE present_transferred_points;
--SELECT * FROM present_transferred_points;

--CREATE OR REPLACE FUNCTION present_transferred_points() RETURNS TABLE 
--(Peer1 varchar, Peer2 varchar, PointsAmount integer) AS $$
--BEGIN
--	RETURN query 
--	WITH tb AS (SELECT * FROM transferredpoints)
--	SELECT checkingPeer AS Peer1, checkedPeer AS Peer2,
--	(t.PointsAmount - COALESCE ((SELECT tb.PointsAmount FROM tb 
--	WHERE t.CheckingPeer = tb.CheckedPeer AND t.checkedPeer = tb.CheckingPeer ), 0)) 
--	AS PointsAmount
--	FROM transferredpoints t ;
--END
--$$ LANGUAGE plpgsql;

SELECT * FROM present_transferred_points();
--3.2
CREATE OR REPLACE FUNCTION xp_by_peer() RETURNS TABLE 
(Peer varchar, Task varchar, XP integer) AS $$
BEGIN
	RETURN query
	SELECT c.peer, c.task, xp.xpamount
	FROM checks c 
	LEFT JOIN xp ON c.id = xp."Check" 
	LEFT JOIN p2p p ON c.id = p."Check"
	LEFT JOIN verter v ON c.id = v."Check"
	WHERE p.state = 'Success' AND (v.state = 'Success' OR v.state IS NULL);
END
$$ LANGUAGE plpgsql;

--SELECT * FROM xp_by_peer();
--3.3
CREATE OR REPLACE FUNCTION get_not_exited_peers(dt date) RETURNS SETOF varchar AS $$
BEGIN 
	RETURN query
	SELECT peer 
	FROM timetracking 
	WHERE "date" = dt AND state = 2
	GROUP BY peer
	HAVING count(*) = 1;
END
$$ LANGUAGE plpgsql;

--SELECT * FROM get_not_exited_peers('2023-09-15');
--3.4
CREATE OR REPLACE FUNCTION get_number_of_transferred_peerpoints() RETURNS TABLE 
(Peer varchar, PointsChange bigint) AS $$
BEGIN
	RETURN query
	WITH tb AS (
		SELECT CheckingPeer, PointsAmount
		FROM transferredpoints t 
		UNION ALL 
		SELECT CheckedPeer, PointsAmount
		FROM transferredpoints t )
	SELECT CheckingPeer AS Peer, sum(pointsamount) AS PointsChange
	FROM tb
	GROUP BY Peer
	ORDER BY PointsChange DESC ; 
END
$$ LANGUAGE plpgsql;

SELECT * FROM get_number_of_transferred_peerpoints();

--3.5


--3.6
CREATE OR REPLACE FUNCTION  get_most_frequently_checked_task() RETURNS TABLE ("Day" date, Task varchar) AS $$
BEGIN 
	RETURN query
	WITH max_count_by_day AS (
		WITH all_tasks_count AS (
			SELECT c.date, c.task, count(*)
			FROM checks c 
			GROUP BY c.task, c.date)
		SELECT date, all_tasks_count.task, count,
		max(count) OVER (PARTITION BY date) AS max
		FROM all_tasks_count )
	SELECT date AS DAY, max_count_by_day.task AS Task
	FROM max_count_by_day
	WHERE count = max;
END
$$ LANGUAGE plpgsql;

--SELECT * FROM get_most_frequently_checked_task();
--3.7
CREATE OR REPLACE FUNCTION get_peers_completed_block(block_name varchar, OUT peer varchar, OUT finish_day timestamp) 
RETURNS SETOF record AS $$
BEGIN 
	RETURN query 
	WITH tbl AS (
		SELECT  c.peer, c.task, pp.time AS finish_day,
		DENSE_RANK()  OVER (PARTITION BY c.peer ORDER BY c.task) AS series
		FROM p2p pp JOIN checks c ON pp."Check" = c.id 
		WHERE c.task LIKE (block_name || '%') AND pp.state = 'Success')
	SELECT tbl.peer, tbl.finish_day
	FROM tbl
	WHERE task = (SELECT max(title) FROM tasks WHERE title LIKE (block_name || '%')) 
			AND series = (SELECT count(*) FROM tasks WHERE title LIKE (block_name || '%'))
	ORDER BY finish_day;
END
$$ LANGUAGE plpgsql;

SELECT * FROM get_peers_completed_block ('SQL');
--3.8
CREATE OR REPLACE FUNCTION get_recommended_checking_peer() RETURNS SETOF record AS $$
DECLARE 
	Peer varchar;
	RecommendedPeer varchar;
	r record;
BEGIN 
	FOR peer IN (SELECT nickname AS Peer FROM peers)
		LOOP 
			WITH all_recommendations AS (
				WITH peer_friends AS (
					SELECT peer1
					FROM friends f 
					WHERE peer2=peer
					UNION 
					SELECT peer2 
					FROM friends
					WHERE peer1=peer)
				SELECT pf.peer1, rec.recommendedpeer , 
				count(rec.recommendedpeer) OVER (PARTITION BY rec.recommendedpeer) AS recommendations_number
				FROM peer_friends pf JOIN recommendations rec ON pf.peer1=rec.peer)
			SELECT DISTINCT ar.recommendedpeer INTO RecommendedPeer
			FROM all_recommendations ar
			WHERE ar.recommendedpeer != peer AND recommendations_number = (SELECT max(recommendations_number) 
																			FROM all_recommendations);
			r = row(Peer, RecommendedPeer);
			RETURN NEXT r;
		END LOOP;
	RETURN;
END
$$ LANGUAGE plpgsql;

--SELECT * FROM  get_recommended_checking_peer() AS tbl(Peer varchar, RecommendedPeer varchar);
--3.9
CREATE OR REPLACE FUNCTION  get_percent_of_peers_started_task(blockname1 varchar, blockname2 varchar, 
OUT started_block_1 bigint, OUT started_block_2 bigint, OUT started_both_blocks bigint, 
OUT didnt_start_any_block bigint) RETURNS SETOF record AS $$
DECLARE 
	block1 varchar = (blockname1 || 1);
	block2 varchar = (blockname2 || 1);
	total bigint = (SELECT (100 / (SELECT count(*) FROM peers)));
BEGIN 
	RETURN query 
	WITH started_task AS (
			SELECT peer , task, nickname,
			dense_rank() over(PARTITION BY peer ORDER BY (task LIKE (blockname1 || '%'), 
			task LIKE (blockname2 || '%'))) AS dr
			FROM checks c FULL JOIN peers p ON c.peer = p.nickname),
		sql_ AS (
			SELECT count(*) sql_per 
			FROM (SELECT DISTINCT nickname FROM started_task
			WHERE task LIKE (block1 || '%') AND (nickname NOT IN (SELECT DISTINCT nickname FROM started_task
			WHERE task LIKE (block2 || '%'))))AS SQL),
		linux AS (
			SELECT count(*) linux_per 
			FROM (SELECT DISTINCT nickname FROM started_task
			WHERE task LIKE (block2 || '%') AND (nickname NOT IN (SELECT DISTINCT nickname FROM started_task
			WHERE task LIKE (block1 || '%')))) AS linux),
		both_ AS (
			SELECT count(*) both_per 
			FROM (SELECT DISTINCT nickname FROM started_task
			GROUP BY nickname 
			HAVING count(DISTINCT dr) = 2) AS both_),
		none_ AS (
			SELECT count(DISTINCT nickname) none_per 
			FROM started_task
			WHERE task IS NULL)
	SELECT 
	(max(s.sql_per) * total) AS started_block_1, (max(l.linux_per) * total) AS started_block_1, 
	(max(b.both_per) * total) AS started_both_blocks, (max(n.none_per) * total) AS didnt_start_any_block
	FROM sql_ s 
	FULL  JOIN linux l ON s.sql_per = l.linux_per 
	FULL JOIN both_ b ON s.sql_per = b.both_per 
	FULL JOIN none_ n ON s.sql_per = n.none_per;
END
$$ LANGUAGE plpgsql;
--SELECT * FROM get_percent_of_peers_started_task('SQL', 'linux');

--3.10. Определить процент пиров, которые когда-либо успешно проходили проверку в свой день рождения
CREATE OR REPLACE FUNCTION get_success_on_birthday(OUT SuccessfulChecks bigint,OUT UnsuccessfulChecks bigint) AS $$
SELECT(
(SELECT count(DISTINCT p.nickname) AS SuccessfulChecks
FROM checks c 
	FULL JOIN peers p ON c.peer = p.nickname 
	FULL JOIN p2p pp ON c.id = pp."Check" 
	FULL JOIN verter v ON c.id = v."Check" 
WHERE ((EXTRACT (MONTH FROM p.birthday) = EXTRACT(MONTH FROM pp."time"))
		 AND (EXTRACT (DAY FROM p.birthday) = EXTRACT(DAY FROM pp."time"))
		 AND pp.state = 'Success' AND v.state IS NULL)
	OR ((EXTRACT (MONTH FROM p.birthday) = EXTRACT(MONTH FROM v."time"))
		 AND (EXTRACT (DAY FROM p.birthday) = EXTRACT(DAY FROM v."time"))
		 AND v.state = 'Success'))
	* 100 / (SELECT count(*) FROM peers),
(SELECT count(DISTINCT p.nickname) AS UnsuccessfulChecks
FROM checks c 
	FULL JOIN peers p ON c.peer = p.nickname 
	FULL JOIN p2p pp ON c.id = pp."Check" 
	FULL JOIN verter v ON c.id = v."Check" 
WHERE ((EXTRACT (MONTH FROM p.birthday) = EXTRACT(MONTH FROM pp."time"))
		 AND (EXTRACT (DAY FROM p.birthday) = EXTRACT(DAY FROM pp."time"))
		 AND pp.state = 'Failure' AND v.state IS NULL)
	OR ((EXTRACT (MONTH FROM p.birthday) = EXTRACT(MONTH FROM v."time"))
		 AND (EXTRACT (DAY FROM p.birthday) = EXTRACT(DAY FROM v."time"))
		 AND v.state = 'Failure'))
	* 100 / (SELECT count(*) FROM peers));
$$ LANGUAGE SQL;
--SELECT * FROM get_success_on_birthday();

--3.11. Определить всех пиров, которые сдали заданные задания 1 и 2, но не сдали задание 3
CREATE OR REPLACE FUNCTION get_tasks_handed_over(task1 varchar, task2 varchar, task3 varchar) 
RETURNS SETOF varchar AS $$
		SELECT DISTINCT c.peer AS peers
		FROM p2p pp JOIN checks c ON pp."Check" = c.id 
		WHERE (c.task = task1 AND pp.state = 'Start')
		INTERSECT 
		SELECT DISTINCT c.peer
		FROM p2p pp JOIN checks c ON pp."Check" = c.id 
		WHERE (c.task = task2 AND pp.state = 'Start')
		INTERSECT 
		SELECT DISTINCT c.peer
		FROM p2p pp JOIN checks c ON pp."Check" = c.id 
		WHERE c.peer NOT IN (SELECT c.peer
								FROM checks c JOIN p2p pp ON c.id = pp."Check" 
								WHERE task = task3 AND pp.state = 'Start');
$$ LANGUAGE SQL;
--SELECT * FROM get_tasks_handed_over('SQL1', 'SQL2', 'SQL3');

--3.12. Используя рекурсивное обобщенное табличное выражение, для каждой задачи вывести кол-во предшествующих ей задач
CREATE OR REPLACE FUNCTION get_count_of_previous_tasks (OUT task varchar, OUT prev_count int) 
RETURNS SETOF record AS $$
BEGIN 
	RETURN query
	WITH RECURSIVE count_parent_task(task, prev_count) AS 
	(
		SELECT title, 0 FROM tasks WHERE parenttask IS NULL
		UNION ALL 
		SELECT t.title, (cpt.prev_count + 1) 
		FROM tasks t, count_parent_task cpt
		WHERE t.parenttask = cpt.task
	)
	SELECT * FROM count_parent_task
	ORDER BY task;
END 
$$ LANGUAGE plpgsql;
-- SELECT * FROM get_count_of_previous_tasks();

--3.14. Определить пира с наибольшим количеством XP
CREATE OR REPLACE FUNCTION get_peer_with_max_xp(OUT peer varchar, OUT xp bigint) AS $$
WITH xp_by_peer AS (
	SELECT peer, sum(xpamount) xp_sum 
	FROM xp JOIN checks c ON xp."Check" = c.id 
	GROUP BY peer)
SELECT peer, xp_sum
FROM xp_by_peer
WHERE xp_sum = (SELECT max(xp_sum) FROM xp_by_peer);
$$ LANGUAGE SQL;
-- SELECT * FROM get_peer_with_max_xp();

--3.15. Определить пиров, приходивших раньше заданного времени не менее N раз за всё время
CREATE OR REPLACE FUNCTION get_peers_come_earlier(time_ time, n int) RETURNS SETOF varchar AS $$
BEGIN 
	RETURN query
	WITH freq AS (
		SELECT peer, count(*) frequency
		FROM timetracking t 
		WHERE t."time" < time_ AND state = 1
		GROUP BY peer
		ORDER BY frequency DESC)
	SELECT peer
	FROM freq
	WHERE frequency >= n;
END
$$ LANGUAGE plpgsql;
-- SELECT * FROM get_peers_come_earlier('09:00:00', 4);

