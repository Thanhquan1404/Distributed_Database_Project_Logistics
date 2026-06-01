---* View all warehouse
CREATE OR REPLACE PROCEDURE View_All_Warehouses(
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
        SELECT
            w.Hub_ID,
            w.Hub_Name,
            w.Region_Code,
            w.Created_At,
            w.Created_By,
            w.Updated_By
        FROM (
            SELECT * FROM Warehouses                                      
            UNION ALL
            SELECT * FROM Warehouses@MinhThuy_Oracle_DistributedDatabase  
            UNION ALL
            SELECT * FROM Warehouses@ThanhQuan_Oracle_DistributedDatabase    
        ) w
        ORDER BY w.Region_Code, w.Hub_ID;
END View_All_Warehouses;
/

SET SERVEROUTPUT ON;

DECLARE
    v_cursor SYS_REFCURSOR;
    v_hub_id      VARCHAR2(50);
    v_hub_name    VARCHAR2(100);
    v_region_code VARCHAR2(20);
    v_created_at  DATE;
    v_created_by  VARCHAR2(50);
    v_updated_by  VARCHAR2(50);
BEGIN
    View_All_Warehouses(v_cursor);

    LOOP
        FETCH v_cursor INTO
            v_hub_id,
            v_hub_name,
            v_region_code,
            v_created_at,
            v_created_by,
            v_updated_by;

        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            v_hub_id || ' - ' ||
            v_hub_name || ' - ' ||
            v_region_code
        );
    END LOOP;

    CLOSE v_cursor;
END;
/