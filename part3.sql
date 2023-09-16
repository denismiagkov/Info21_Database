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
--2
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
--3
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
--4
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

--5


--6
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

SELECT * FROM get_most_frequently_checked_task();




