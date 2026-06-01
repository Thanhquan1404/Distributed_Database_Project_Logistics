---* Search warehouse
CREATE OR REPLACE PROCEDURE Search_Warehouses(
    p_cursor      OUT SYS_REFCURSOR,
    v_Hub_ID      VARCHAR2  DEFAULT NULL,   -- Lọc theo Hub ID (LIKE)
    v_Hub_Name    NVARCHAR2 DEFAULT NULL,   -- Lọc theo tên kho (LIKE)
    v_Region_Code VARCHAR2  DEFAULT NULL    -- Lọc theo vùng: 'DN' | 'HN' | 'HCM'
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
        WHERE (v_Hub_ID      IS NULL OR UPPER(w.Hub_ID)      LIKE '%' || UPPER(v_Hub_ID)      || '%')
          AND (v_Hub_Name    IS NULL OR UPPER(w.Hub_Name)    LIKE '%' || UPPER(v_Hub_Name)    || '%')
          AND (v_Region_Code IS NULL OR w.Region_Code        = UPPER(v_Region_Code))
        ORDER BY w.Region_Code, w.Hub_ID;
END Search_Warehouses;
/

SET SERVEROUTPUT ON;

DECLARE
    v_cursor SYS_REFCURSOR;

    v_Hub_ID      VARCHAR2(20);
    v_Hub_Name    NVARCHAR2(100);
    v_Region_Code VARCHAR2(10);
    v_Created_At  DATE;
    v_Created_By  VARCHAR2(50);
    v_Updated_By  VARCHAR2(50);

BEGIN
    Search_Warehouses(
        p_cursor      => v_cursor,
        v_Hub_ID      => NULL, -- Thay đổi để search theo HUB_ID, nếu set NULL sẽ search toàn bộ Hub_ID
        v_Hub_Name    => NULL, -- Thay đổi để search theo HUB_NAME, nếu set NULL sẽ search toàn bộ Hub_Name
        v_Region_Code => NULL  -- Thay đổi để search theo REGION_CODE (HN, HCM, DN), nếu set NULL sẽ search toàn bộ Region
    );

    DBMS_OUTPUT.PUT_LINE(
        RPAD('Hub ID', 15) ||
        RPAD('Hub Name', 35) ||
        RPAD('Region', 10) ||
        RPAD('Created At', 22) ||
        RPAD('Created By', 20) ||
        RPAD('Updated By', 20)
    );

    DBMS_OUTPUT.PUT_LINE(
        RPAD('-', 15, '-') ||
        RPAD('-', 35, '-') ||
        RPAD('-', 10, '-') ||
        RPAD('-', 22, '-') ||
        RPAD('-', 20, '-') ||
        RPAD('-', 20, '-')
    );

    LOOP
        FETCH v_cursor INTO
            v_Hub_ID,
            v_Hub_Name,
            v_Region_Code,
            v_Created_At,
            v_Created_By,
            v_Updated_By;

        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(v_Hub_ID, 15) ||
            RPAD(v_Hub_Name, 35) ||
            RPAD(v_Region_Code, 10) ||
            RPAD(TO_CHAR(v_Created_At, 'DD/MM/YYYY HH24:MI'), 22) ||
            RPAD(NVL(v_Created_By, '-'), 20) ||
            RPAD(NVL(v_Updated_By, '-'), 20)
        );
    END LOOP;

    CLOSE v_cursor;

END;
/