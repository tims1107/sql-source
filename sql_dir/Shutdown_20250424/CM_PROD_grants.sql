
BEGIN
    FOR t IN (SELECT table_name FROM all_tables WHERE owner = 'YOUR_SCHEMA') LOOP
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || t.owner || '.' || t.table_name || ' TO TARGET_USER';
    END LOOP;

    FOR v IN (SELECT view_name FROM all_views WHERE owner = 'YOUR_SCHEMA') LOOP
        EXECUTE IMMEDIATE 'GRANT SELECT ON ' || v.owner || '.' || v.view_name || ' TO TARGET_USER';
    END LOOP;

    FOR s IN (SELECT sequence_name FROM all_sequences WHERE owner = 'YOUR_SCHEMA') LOOP
        EXECUTE IMMEDIATE 'GRANT SELECT ON ' || s.owner || '.' || s.sequence_name || ' TO TARGET_USER';
    END LOOP;

    FOR p IN (SELECT object_name FROM all_objects WHERE object_type IN ('PROCEDURE', 'FUNCTION') AND owner = 'YOUR_SCHEMA') LOOP
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON ' || p.owner || '.' || p.object_name || ' TO TARGET_USER';
    END LOOP;

    FOR p IN (SELECT object_name FROM all_objects WHERE object_type = 'PACKAGE' AND owner = 'YOUR_SCHEMA') LOOP
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON ' || p.owner || '.' || p.object_name || ' TO TARGET_USER';
    END LOOP;
END;
/