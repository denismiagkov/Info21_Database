CREATE OR REPLACE FUNCTION check_parent_task_exists() RETURNS TRIGGER AS $$
BEGIN 
	IF ((SELECT count(*) FROM tasks WHERE parenttask IS NULL) < 1) 
		OR NEW.parenttask IS NOT NULL THEN 
			RETURN NEW;
	ELSE RETURN NULL;
	END IF; 
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS parent_task_exists ON tasks;
CREATE TRIGGER parent_task_exists BEFORE INSERT OR UPDATE ON tasks
FOR EACH ROW EXECUTE PROCEDURE check_parent_task_exists();

--
CREATE OR REPLACE FUNCTION check_parent_task_completed() RETURNS TRIGGER AS $$
DECLARE 
	check_parenttask_id int;
	parenttask_is_null bool;
BEGIN 
	IF ((SELECT parenttask FROM tasks WHERE title = NEW.task) IS NULL) THEN 
		parenttask_is_null = TRUE;
	ELSE 
		parenttask_is_null = FALSE;
		check_parenttask_id = (SELECT id 
							FROM checks c JOIN tasks t ON c.task = t.title 
							WHERE c.peer = NEW.peer 
								AND c.task = (SELECT parenttask FROM tasks t WHERE t.title = NEW.task));
	END IF;
	IF (
		('Success' IN (SELECT state FROM p2p WHERE "Check" = check_parenttask_id) 
		AND ('Success' IN (SELECT state FROM verter WHERE "Check" = check_parenttask_id) 
			OR (SELECT count(*) FROM verter WHERE "Check" = check_parenttask_id GROUP BY "Check") IS NULL)) 
		OR parenttask_is_null IS TRUE) THEN 
		RETURN NEW;
	ELSE 
		RETURN NULL;
	END IF;		
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS parent_task_completed ON checks;
CREATE TRIGGER parent_task_completed BEFORE INSERT OR UPDATE ON checks
FOR EACH ROW EXECUTE PROCEDURE check_parent_task_completed();

--
CREATE OR REPLACE FUNCTION check_incompleteness() RETURNS TRIGGER AS $$
BEGIN 
	IF (
		NEW.state = 'Start' 
		AND (SELECT state 
			FROM p2p p JOIN checks c ON p."Check" = c.id 
			WHERE c.task = (SELECT task FROM checks WHERE id = NEW."Check") 
							AND c.peer = (SELECT peer FROM checks WHERE id = NEW."Check")
							AND p.checkingpeer = (SELECT checkingpeer FROM p2p WHERE checkingpeer = NEW.checkingpeer)
			ORDER BY p.id DESC 
			LIMIT 1) = 'Start' 
				) THEN 
		RETURN NULL;
	ELSE 
		RETURN NEW;
	END IF;	
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS incompleted_check ON p2p;
CREATE TRIGGER incompleted_check BEFORE INSERT OR UPDATE ON p2p
FOR EACH ROW EXECUTE PROCEDURE check_incompleteness();

--
CREATE OR REPLACE FUNCTION check_record_status(_check int, status check_status) RETURNS bool AS $$
BEGIN 
	IF ((SELECT state FROM verter WHERE "Check"  = _check ORDER BY id DESC LIMIT 1) IS NULL   
		AND status = 'Start') THEN 
		RETURN TRUE;
	ELSEIF ((SELECT state FROM verter WHERE "Check"  = _check ORDER BY id DESC LIMIT 1) = 'Start'   
		AND status IN ('Success', 'Failure')) THEN 
		RETURN TRUE;
	ELSE RETURN FALSE;
	END IF;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION is_successful_check() RETURNS TRIGGER AS $$
DECLARE 
	status bool;
BEGIN 
	status = check_record_status(NEW."Check", NEW.state);
	IF (NEW."Check" IN (SELECT "Check" FROM p2p WHERE state = 'Success') AND status = TRUE) THEN 
		RETURN NEW;
	ELSE RETURN NULL;
	END IF;	
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS p2p_successful_check ON verter;
CREATE TRIGGER p2p_successful_check BEFORE INSERT OR UPDATE ON verter
FOR EACH ROW EXECUTE PROCEDURE is_successful_check();

--
CREATE OR REPLACE FUNCTION check_maximum_for_xp(xp_amount int, _check int) RETURNS bool AS $$
BEGIN 
	IF (xp_amount > (SELECT MaxXP 
						FROM tasks t JOIN checks c ON t.title = c.task
						WHERE c.id = _check)) THEN 
		RETURN FALSE;
	ELSE 
		RETURN TRUE;
	END IF;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_status_for_xp(_check int) RETURNS bool AS $$
BEGIN 
	IF (((SELECT state FROM p2p WHERE "Check" = _check ORDER BY id DESC LIMIT 1) = 'Success') 
		AND (SELECT state FROM verter WHERE "Check" = _check ORDER BY id DESC LIMIT 1) 
		IN (NULL, 'Success')) THEN 
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_xp() RETURNS TRIGGER AS $$
BEGIN 
	IF (check_maximum_for_xp(NEW.XPAmount, NEW."Check") = FALSE) THEN 
		RAISE EXCEPTION 'XP amount can not be more then max XP of the task';
	ELSEIF (check_status_for_xp(NEW."Check") = FALSE ) THEN 
		RAISE EXCEPTION 'XP amount can not be received for not successful task';
	END IF;
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS is_xp_correct ON XP;
CREATE TRIGGER is_xp_correct BEFORE INSERT OR UPDATE ON XP
FOR EACH ROW EXECUTE PROCEDURE check_xp();

















