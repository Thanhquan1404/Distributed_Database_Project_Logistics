---* Search Customers
CREATE OR REPLACE PROCEDURE Search_Customers(
    p_cursor          OUT SYS_REFCURSOR,
    v_Customer_ID     VARCHAR2  DEFAULT NULL,   -- Lọc theo Customer ID (LIKE)
    v_Customer_Name   NVARCHAR2 DEFAULT NULL,   -- Lọc theo tên KH (LIKE)
    v_City            NVARCHAR2 DEFAULT NULL,   -- Lọc theo thành phố (LIKE)
    v_Region          VARCHAR2  DEFAULT NULL,   -- Lọc theo vùng: 'DN'|'HN'|'HCM'
    v_Min_Rating      NUMBER    DEFAULT NULL,   -- Rating tối thiểu
    v_Max_Rating      NUMBER    DEFAULT NULL    -- Rating tối đa
) AS
BEGIN
    OPEN p_cursor FOR
        SELECT
            c.Customer_ID,
            c.Customer_Name,
            c.City,
            get_region_from_city(c.City) AS Region,
            c.Customer_Rating,
            c.Created_At,
            c.Created_By,
            c.Updated_By
        FROM (
            SELECT * FROM Customers
            UNION ALL
            SELECT * FROM Customers@MinhThuy_Oracle_DistributedDatabase
            UNION ALL
            SELECT * FROM Customers@KimNgan_Oracle_DistributedDatabase
        ) c
        WHERE (v_Customer_ID   IS NULL OR UPPER(c.Customer_ID)   LIKE '%' || UPPER(v_Customer_ID)   || '%')
          AND (v_Customer_Name IS NULL OR UPPER(c.Customer_Name) LIKE '%' || UPPER(v_Customer_Name) || '%')
          AND (v_City          IS NULL OR UPPER(c.City)          LIKE '%' || UPPER(v_City)          || '%')
          AND (v_Region        IS NULL OR get_region_from_city(c.City) = UPPER(v_Region))
          AND (v_Min_Rating    IS NULL OR c.Customer_Rating >= v_Min_Rating)
          AND (v_Max_Rating    IS NULL OR c.Customer_Rating <= v_Max_Rating)
        ORDER BY c.Customer_ID;
END Search_Customers;
/

SET SERVEROUTPUT ON;

select * from customers;

DECLARE
    v_cursor SYS_REFCURSOR;

    v_Customer_ID     VARCHAR2(20);
    v_Customer_Name   NVARCHAR2(100);
    v_City            NVARCHAR2(100);
    v_Region          VARCHAR2(10);
    v_Customer_Rating NUMBER;
    v_Created_At      DATE;
    v_Created_By      VARCHAR2(50);
    v_Updated_By      VARCHAR2(50);

    v_count NUMBER := 0;
BEGIN
    Search_Customers(
        p_cursor        => v_cursor,
        v_Customer_ID   => NULL, -- Được sử dụng để search cho một Customer_ID cụ thể hoặc dùng NULL để cho tất cả 
        v_Customer_Name => NULL, -- Được sử dụng để search cho một Customer_name cụ thể hoặc dùng NULL để cho tất cả
        v_City          => NULL, -- Được sử dụng để search cho một City cụ thể (thông qua hàm get_region_from_city) hoặc dùng NULL để cho tất cả
        v_Region        => NULL, -- Được sử dụng để search cho một region cụ thể (HCM, DN, HN) hoặc dùng NULL để cho tất cả
        v_Min_Rating    => 1,
        v_Max_Rating    => 5
    );

    DBMS_OUTPUT.PUT_LINE(
        RPAD('Customer ID',15) ||
        RPAD('Customer Name',35) ||
        RPAD('City',20) ||
        RPAD('Region',10) ||
        RPAD('Rating',10)
    );

    DBMS_OUTPUT.PUT_LINE(RPAD('-',90,'-'));

    LOOP
        FETCH v_cursor INTO
            v_Customer_ID,
            v_Customer_Name,
            v_City,
            v_Region,
            v_Customer_Rating,
            v_Created_At,
            v_Created_By,
            v_Updated_By;

        EXIT WHEN v_cursor%NOTFOUND;

        v_count := v_count + 1;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(v_Customer_ID,15) ||
            RPAD(v_Customer_Name,35) ||
            RPAD(v_City,20) ||
            RPAD(v_Region,10) ||
            RPAD(TO_CHAR(v_Customer_Rating),10)
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-',90,'-'));
    DBMS_OUTPUT.PUT_LINE('Total Customers Found: ' || v_count);

    CLOSE v_cursor;
END;
/
