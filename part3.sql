--3.1. Написать функцию, возвращающую таблицу TransferredPoints в более человекочитаемом виде
CREATE OR REPLACE FUNCTION present_transferred_points() RETURNS TABLE 
(Peer1 varchar, Peer2 varchar, PointsAmount integer) AS $$
BEGIN
	RETURN query 
	SELECT t1.checkingPeer AS Peer1, t1.checkedPeer AS Peer2,
	(t1.PointsAmount - t2.PointsAmount) AS PointsAmount 
	FROM transferredpoints t1, transferredpoints t2 
	WHERE t2.CheckingPeer = t1.CheckedPeer AND t2.checkedPeer = t1.CheckingPeer 
	AND t1.checkingpeer < t1.checkedpeer 
	UNION
	SELECT t1.checkingPeer AS Peer1, t1.checkedPeer AS Peer2, t1.PointsAmount AS PointsAmount 
	FROM transferredpoints t1
	EXCEPT
	SELECT t1.checkingPeer, t1.checkedPeer, t1.PointsAmount
	FROM transferredpoints t1, transferredpoints t2 
	WHERE t1.checkingPeer = t2.checkedPeer AND t1.checkedPeer = t2.checkingPeer
	ORDER BY peer1;
END
$$ LANGUAGE plpgsql;
--SELECT * FROM present_transferred_points();

--3.2. Написать функцию, которая возвращает таблицу вида: ник пользователя, название проверенного задания,
-- кол-во полученного XP
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

--3.3. Написать функцию, определяющую пиров, которые не выходили из кампуса в течение всего дня
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
--SELECT * FROM get_not_exited_peers('2023-02-15');

--3.4. Посчитать изменение в количестве пир поинтов каждого пира по таблице TransferredPoints
CREATE OR REPLACE PROCEDURE get_number_of_transferred_peer_points(get_result refcursor) AS $$
BEGIN
	OPEN get_result FOR EXECUTE 
	'WITH tb AS (
		SELECT CheckingPeer, PointsAmount
		FROM transferredpoints t 
		UNION ALL 
		SELECT CheckedPeer, PointsAmount*(-1)
		FROM transferredpoints t )
	SELECT CheckingPeer AS Peer, sum(pointsamount) AS PointsChange
	FROM tb
	GROUP BY Peer
	ORDER BY PointsChange DESC' ; 
END
$$ LANGUAGE plpgsql;
--CALL get_number_of_transferred_peer_points('get_result');
--FETCH ALL FROM "get_result";
--CLOSE "get_result";

--3.5. Посчитать изменение в количестве пир поинтов каждого пира по таблице, возвращаемой первой функцией из Part 3
CREATE OR REPLACE PROCEDURE get_peer_points_changed(get_result refcursor) AS $$
BEGIN 
	OPEN get_result FOR 
	SELECT COALESCE (t1.peer1, t2.peer2) peer, (COALESCE (sum1, 0) + COALESCE (sum2, 0)) points_change
	FROM 
		(SELECT peer1, sum(pointsamount) sum1
		FROM (SELECT * FROM present_transferred_points()) t
		GROUP BY peer1) t1
		FULL JOIN 
		(SELECT peer2, sum(pointsamount)*(-1) sum2
		FROM (SELECT * FROM present_transferred_points()) t
		GROUP BY peer2) t2
		ON t1.peer1 = t2.peer2
	ORDER BY points_change DESC;
END 
$$ LANGUAGE plpgsql;
--CALL get_peer_points_changed('get_result');
--FETCH ALL FROM "get_result";
--CLOSE "get_result";

--3.6. Определить самое часто проверяемое задание за каждый день
CREATE OR REPLACE PROCEDURE  get_most_frequently_checked_task(get_result refcursor) AS $$
BEGIN 
	OPEN get_result FOR 
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
--CALL get_most_frequently_checked_task('get_result');
--FETCH ALL FROM "get_result";
--CLOSE "get_result";

--3.7. Найти всех пиров, выполнивших весь заданный блок задач и дату завершения последнего задания
CREATE OR REPLACE PROCEDURE get_peers_completed_block(block_name varchar, get_result refcursor) AS $$
BEGIN 
	OPEN get_result FOR   
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
--CALL get_peers_completed_block('linux', 'get_result');
--FETCH ALL FROM "get_result";
--CLOSE "get_result";

--3.8. Определить, к какому пиру стоит идти на проверку каждому обучающемуся
CREATE OR REPLACE PROCEDURE get_recommended_checking_peer(get_result refcursor) AS $$
BEGIN
	OPEN get_result FOR
	SELECT peer1 AS peer, recommendedpeer 
	FROM (WITH 
			fr AS 
			(SELECT peer1, peer2 FROM friends
			UNION 
			SELECT peer2, peer1 FROM friends)
		SELECT DISTINCT ON (peer1) peer1, recommendedpeer, count(recommendedpeer) max_count
		FROM fr LEFT JOIN recommendations r ON fr.peer2 = r.peer
		WHERE peer1 != recommendedpeer
		GROUP BY peer1, recommendedpeer
		ORDER BY peer1, max_count DESC) foo;
END 
$$ LANGUAGE plpgsql;
--CALL get_recommended_checking_peer('get_result');
--FETCH ALL FROM "get_result";
--CLOSE "get_result";

--3.9. Определить процент пиров, которые: *) Приступили только к блоку 1; 
-- *) Приступили только к блоку 2; *) Приступили к обоим;  *) Не приступили ни к одному
CREATE OR REPLACE PROCEDURE  get_percent_of_peers_started_task(blockname1 varchar, blockname2 varchar, 
get_result refcursor) AS $$
BEGIN 
	OPEN get_result FOR 
	WITH started_task AS (
			SELECT peer , task, nickname,
			dense_rank() over(PARTITION BY peer ORDER BY (task LIKE (blockname1 || '%'), 
			task LIKE (blockname2 || '%'))) AS dr
			FROM checks c FULL JOIN peers p ON c.peer = p.nickname),
		block1 AS (
			SELECT count(*) block1_per 
			FROM (SELECT DISTINCT nickname FROM started_task
			WHERE task LIKE (blockname1 || '1') AND (nickname NOT IN (SELECT DISTINCT nickname FROM started_task
			WHERE task LIKE (blockname2 || '1'))))AS block1),
		block2 AS (
			SELECT count(*) block2_per 
			FROM (SELECT DISTINCT nickname FROM started_task
			WHERE task LIKE (blockname2 || '1') AND (nickname NOT IN (SELECT DISTINCT nickname FROM started_task
			WHERE task LIKE (blockname1 || '1')))) AS block2),
		both_ AS (
			SELECT count(*) both_per 
			FROM (SELECT DISTINCT nickname FROM started_task
			WHERE task LIKE (blockname1 || '1') AND (nickname IN (SELECT DISTINCT nickname FROM started_task
			WHERE task LIKE (blockname2 || '1')))) AS both_),
		none_ AS (
			SELECT count(DISTINCT nickname) none_per 
			FROM started_task
			WHERE task IS NULL)
	SELECT 
	(max(b1.block1_per) * (SELECT (100 / (SELECT count(*) FROM peers)))) AS started_block_1, 
	(max(b2.block2_per) * (SELECT (100 / (SELECT count(*) FROM peers)))) AS started_block_2, 
	(max(b.both_per) * (SELECT (100 / (SELECT count(*) FROM peers)))) AS started_both_blocks, 
	(max(n.none_per) * (SELECT (100 / (SELECT count(*) FROM peers)))) AS didnt_start_any_block
	FROM block1 b1 
	FULL  JOIN block2 b2 ON b1.block1_per = b2.block2_per 
	FULL JOIN both_ b ON b1.block1_per = b.both_per 
	FULL JOIN none_ n ON b1.block1_per = n.none_per;
END
$$ LANGUAGE plpgsql;
--CALL get_percent_of_peers_started_task('SQL', 'linux', 'get_result');
--FETCH ALL FROM "get_result";
--CLOSE "get_result";

--3.10. Определить процент пиров, которые когда-либо успешно проходили проверку в свой день рождения
CREATE OR REPLACE PROCEDURE get_success_on_birthday(get_result refcursor) AS $$
BEGIN 
	OPEN get_result FOR 
	SELECT (successfulchecks * 100 / (successfulchecks+unsuccessfulchecks)) AS successfulchecks,
		(unsuccessfulchecks * 100 / (successfulchecks+unsuccessfulchecks)) AS unsuccessfulchecks
	FROM
	(SELECT * FROM 
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
		 AND v.state = 'Success')) AS q1,
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
		 AND v.state = 'Failure')) AS q2) AS q;
END 
$$ LANGUAGE plpgsql;
--CALL get_success_on_birthday('get_result');
--FETCH ALL FROM "get_result";
--CLOSE "get_result";

--3.11. Определить всех пиров, которые сдали заданные задания 1 и 2, но не сдали задание 3
CREATE OR REPLACE PROCEDURE get_tasks_handed_over(task1 varchar, task2 varchar, task3 varchar, 
get_result refcursor) AS $$
BEGIN 
	OPEN get_result FOR
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
END
$$ LANGUAGE plpgsql;
--CALL get_tasks_handed_over('SQL1', 'SQL2', 'SQL3', 'get_result');
--FETCH ALL FROM "get_result";
--CLOSE "get_result";

--3.12. Используя рекурсивное обобщенное табличное выражение, для каждой задачи вывести кол-во предшествующих ей задач
CREATE OR REPLACE PROCEDURE  get_count_of_previous_tasks (get_result refcursor) AS $$
BEGIN 
	OPEN get_result FOR 
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
--CALL get_count_of_previous_tasks('get_result');
--FETCH ALL FROM "get_result";
--CLOSE "get_result";

--3.14. Определить пира с наибольшим количеством XP
CREATE OR REPLACE PROCEDURE get_peer_with_max_xp(get_result refcursor) AS $$
BEGIN 
	OPEN get_result FOR 
	WITH xp_by_peer AS (
		SELECT peer, sum(xpamount) xp_sum 
		FROM xp JOIN checks c ON xp."Check" = c.id 
		GROUP BY peer)
	SELECT peer, xp_sum
	FROM xp_by_peer
	WHERE xp_sum = (SELECT max(xp_sum) FROM xp_by_peer);
END 
$$ LANGUAGE plpgsql;
--CALL get_peer_with_max_xp('get_result');
--FETCH ALL FROM "get_result";
--CLOSE "get_result";

--3.15. Определить пиров, приходивших раньше заданного времени не менее N раз за всё время
CREATE OR REPLACE PROCEDURE get_peers_come_earlier(time_ time, n int, get_result refcursor) AS $$
BEGIN 
	OPEN get_result FOR 
	SELECT peer
	FROM timetracking t 
	WHERE t."time" < time_ AND state = 1
	GROUP BY peer
	HAVING count(*) >=n;
END
$$ LANGUAGE plpgsql;
--CALL get_peers_come_earlier('10:00:00', 2, 'get_result');
--FETCH ALL FROM "get_result";
--CLOSE "get_result";

-- 3.16. Определить пиров, выходивших за последние N дней из кампуса больше M раз
CREATE OR REPLACE PROCEDURE get_peers_got_out_more_than(period_ int, count_ int, get_result refcursor) AS $$
BEGIN 
	OPEN get_result FOR
	SELECT peer
	FROM timetracking t 
	WHERE state = 2  AND date BETWEEN (current_date - period_) AND now()
	GROUP BY peer, date
	HAVING (count(state)-1) > count_;
END 
$$ LANGUAGE plpgSQL;
--CALL get_peers_got_out_more_than(365, 0, 'get_result');
--FETCH ALL FROM "get_result";
--CLOSE "get_result";

--3.17. Определить для каждого месяца процент ранних входов
CREATE OR REPLACE PROCEDURE get_early_entries(get_result refcursor) AS $$
BEGIN
	OPEN get_result FOR
	WITH 
	o_in AS (
		SELECT to_char(date_trunc('month', t.date), 'Month') AS month, count(state) AS overall_in
		FROM timetracking t JOIN peers p ON t.peer = p.nickname 
		WHERE t.state = 1 AND EXTRACT (MONTH FROM t.date) = EXTRACT (MONTH FROM p.birthday)
		GROUP BY date_trunc('month', t.date)),
	e_in AS (
		SELECT to_char(date_trunc('month', t.date), 'Month') AS month, count(state) AS early_in
		FROM timetracking t JOIN peers p ON t.peer = p.nickname 
		WHERE t.state = 1 AND EXTRACT (MONTH FROM t.date) = EXTRACT (MONTH FROM p.birthday)
			AND t."time"  < '12:00'
		GROUP BY date_trunc('month', t.date))
	SELECT o_in.month,COALESCE (round(e_in.early_in * 100 / o_in.overall_in), 0)
	FROM o_in LEFT JOIN e_in ON o_in.month = e_in.month;	
END
$$ LANGUAGE plpgsql;
--CALL get_early_entries('get_result');
--FETCH ALL FROM "get_result";
--CLOSE "get_result";


