--2.1. Написать процедуру добавления P2P проверки
CREATE OR REPLACE PROCEDURE add_p2p_check (checked_peer varchar, checking_peer varchar,
task_name varchar, p2p_check_status check_status) AS $$
DECLARE 
	checks_id int;
BEGIN 
	IF (p2p_check_status = 'Start') THEN 
		INSERT INTO checks (peer, task, date)
		VALUES (checked_peer, task_name, current_date);
		checks_id = (SELECT max(id) FROM checks
					WHERE peer = checked_peer AND  task = task_name AND date = current_date);
	ELSE 
		checks_id = (SELECT c.id FROM checks c JOIN p2p p ON c.id =p."Check" 
					WHERE c.peer = checked_peer AND p.checkingpeer = checking_peer AND task = task_name);
	END IF;
	INSERT INTO p2p ("Check", checkingpeer, state, "time")
	VALUES (checks_id, checking_peer, p2p_check_status, now());
END
$$ LANGUAGE plpgsql;
--CALL add_p2p_check('janis', 'paul', 'intro', 'Start');

--2.2. Написать процедуру добавления проверки Verter'ом
CREATE OR REPLACE PROCEDURE add_verter_check (checked_peer varchar, task_name varchar,
verter_status check_status, time_ timestamp) AS $$
DECLARE 
	checks_id int;
BEGIN 
	checks_id = (SELECT c.id FROM checks c JOIN p2p p ON c.id = p."Check"
				WHERE c.peer = checked_peer AND c.task = task_name AND p.state = 'Success'
				ORDER BY p.id DESC LIMIT 1);
	INSERT INTO verter ("Check", state, "time")
	VALUES (checks_id, verter_status, time_);	
END
$$ LANGUAGE plpgsql;
--CALL add_verter_check('ringo', 'SQL1', 'Start', '2023-03-20 16:00:00');

--2.3. Написать триггер: после добавления записи со статутом "начало" в таблицу P2P, 
--изменить соответствующую запись в таблице TransferredPoints
CREATE OR REPLACE FUNCTION add_point_to_peer() RETURNS TRIGGER AS $$
DECLARE 
	new_checked_peer varchar;
BEGIN 
	new_checked_peer = (SELECT peer FROM checks c JOIN p2p p ON c.id = p."Check"
						WHERE c.id  = NEW."Check" LIMIT 1);
	IF (NEW.state = 'Start') THEN 
		IF ((SELECT count(*) FROM transferredpoints
			WHERE checkingpeer = NEW.checkingpeer AND checkedpeer = new_checked_peer) = 0) THEN 
			INSERT INTO transferredpoints (checkingpeer, checkedpeer, pointsamount)
			VALUES (NEW.checkingpeer, new_checked_peer, 1);
		ELSE
			UPDATE transferredpoints SET pointsamount = (pointsamount + 1)
			WHERE checkingpeer = NEW.checkingpeer AND checkedpeer = new_checked_peer;
		END IF;
	END IF;
	RETURN NULL;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_transfer_point ON p2p;
CREATE TRIGGER check_transfer_point AFTER INSERT OR UPDATE ON p2p
FOR EACH ROW EXECUTE PROCEDURE add_point_to_peer();

--2.4. Написать триггер: перед добавлением записи в таблицу XP, проверить корректность добавляемой записи
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
		AND (((SELECT state FROM verter WHERE "Check" = _check ORDER BY id DESC LIMIT 1) 
		= 'Success') OR ((SELECT state FROM verter WHERE "Check" = _check ORDER BY id DESC LIMIT 1) 
		IS NULL))) THEN 
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






