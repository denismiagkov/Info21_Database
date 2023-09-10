DROP TRIGGER IF EXISTS parent_task_exists ON tasks;
CREATE TRIGGER parent_task_exists BEFORE INSERT OR UPDATE ON tasks
FOR EACH ROW EXECUTE PROCEDURE check_parent_task_exists();

CREATE OR REPLACE FUNCTION check_parent_task_exists() RETURNS TRIGGER AS $$
BEGIN 
	IF ((SELECT count(*) FROM tasks WHERE parenttask IS NULL) < 1) 
		OR NEW.parenttask IS NOT NULL THEN 
			RETURN NEW;
	ELSE RETURN NULL;
	END IF; 
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_parent_task_completed() RETURNS TRIGGER AS $$
DECLARE 
	check_parenttask_id int;
	parenttask_is_null bool;
BEGIN 
	check_parenttask_id = (SELECT id 
							FROM checks c JOIN tasks t ON c.task = t.title 
							WHERE c.peer = NEW.peer 
								AND c.task = (SELECT parenttask FROM tasks t WHERE t.title = NEW.task));
	IF ((SELECT parenttask FROM tasks WHERE title = NEW.task) IS NULL) THEN 
		parenttask_is_null = TRUE;
	ELSE 
		parenttask_is_null = FALSE;
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


