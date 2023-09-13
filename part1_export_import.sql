CREATE OR REPLACE PROCEDURE export_to (table_name varchar, file_path varchar, delimiter_ varchar) AS $$
BEGIN 
	EXECUTE format('COPY %I TO %L DELIMITER %L CSV HEADER', table_name, file_path, delimiter_);	
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE import_from (table_name varchar, file_path varchar, delimiter_ varchar) AS $$
BEGIN 
	EXECUTE format('COPY %I FROM %L DELIMITER %L CSV HEADER', table_name, file_path, delimiter_);	
END;
$$ LANGUAGE plpgsql;