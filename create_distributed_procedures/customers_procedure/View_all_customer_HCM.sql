---* View All customers 
CREATE OR REPLACE PROCEDURE View_All_Customers(
    p_cursor OUT SYS_REFCURSOR
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
            SELECT * FROM Customers@ThanhQuan_Oracle_DistributedDatabase  
            UNION ALL
            SELECT * FROM Customers@MinhThuy_Oracle_DistributedDatabase    
        ) c
        ORDER BY c.Customer_ID;
END View_All_Customers;
/

SET SERVEROUTPUT ON;

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
    View_All_Customers(v_cursor);

    DBMS_OUTPUT.PUT_LINE(
        RPAD('Customer ID',15) ||
        RPAD('Customer Name',35) ||
        RPAD('City',20) ||
        RPAD('Region',10) ||
        RPAD('Rating',10) ||
        RPAD('Created By',20) ||
        RPAD('Updated By',20)
    );

    DBMS_OUTPUT.PUT_LINE(RPAD('-',130,'-'));

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
            RPAD(TO_CHAR(v_Customer_Rating),10) ||
            RPAD(NVL(v_Created_By,'-'),20) ||
            RPAD(NVL(v_Updated_By,'-'),20)
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-',130,'-'));
    DBMS_OUTPUT.PUT_LINE('Total Customers: ' || v_count);

    CLOSE v_cursor;
END;
/