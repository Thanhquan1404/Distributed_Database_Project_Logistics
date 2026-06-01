---* View all orders operations 
CREATE OR REPLACE PROCEDURE View_All_Orders_Ops(
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
        SELECT
            o.Order_ID,
            o.Customer_ID,
            o.Product_ID,
            o.Root_Hub,
            o.Dest_Hub,
            get_region_of_hub(o.Root_Hub) AS Origin_Region,  
            get_region_of_hub(o.Dest_Hub) AS Dest_Region,    
            o.Mode_Of_Shipment,
            o.Status,
            o.Created_At,
            o.Created_By,
            o.Updated_By
        FROM (
            SELECT * FROM Orders_Ops                                      
            UNION ALL
            SELECT * FROM Orders_Ops@KimNgan_Oracle_DistributedDatabase  
            UNION ALL
            SELECT * FROM Orders_Ops@ThanhQuan_Oracle_DistributedDatabase   
        ) o
        ORDER BY o.Created_At DESC;
END View_All_Orders_Ops;
/

SET SERVEROUTPUT ON;

DECLARE
    v_cursor SYS_REFCURSOR;

    v_Order_ID         VARCHAR2(30);
    v_Customer_ID      VARCHAR2(30);
    v_Product_ID       VARCHAR2(30);
    v_Root_Hub         VARCHAR2(30);
    v_Dest_Hub         VARCHAR2(30);
    v_Origin_Region    VARCHAR2(10);
    v_Dest_Region      VARCHAR2(10);
    v_Mode_Shipment    VARCHAR2(30);
    v_Status           VARCHAR2(30);
    v_Created_At       TIMESTAMP;
    v_Created_By       VARCHAR2(50);
    v_Updated_By       VARCHAR2(50);

    v_count NUMBER := 0;

BEGIN
    View_All_Orders_Ops(v_cursor);

    DBMS_OUTPUT.PUT_LINE(
        RPAD('Order ID',15) ||
        RPAD('Customer',15) ||
        RPAD('Product',15) ||
        RPAD('Origin',10) ||
        RPAD('Dest',10) ||
        RPAD('Ship Mode',18) ||
        RPAD('Status',15) ||
        RPAD('Created At',22)
    );

    DBMS_OUTPUT.PUT_LINE(RPAD('-',120,'-'));

    LOOP
        FETCH v_cursor INTO
            v_Order_ID,
            v_Customer_ID,
            v_Product_ID,
            v_Root_Hub,
            v_Dest_Hub,
            v_Origin_Region,
            v_Dest_Region,
            v_Mode_Shipment,
            v_Status,
            v_Created_At,
            v_Created_By,
            v_Updated_By;

        EXIT WHEN v_cursor%NOTFOUND;

        v_count := v_count + 1;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(v_Order_ID,15) ||
            RPAD(v_Customer_ID,15) ||
            RPAD(v_Product_ID,15) ||
            RPAD(v_Origin_Region,10) ||
            RPAD(v_Dest_Region,10) ||
            RPAD(v_Mode_Shipment,18) ||
            RPAD(v_Status,15) ||
            RPAD(TO_CHAR(v_Created_At,'DD/MM/YYYY HH24:MI'),22)
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-',120,'-'));
    DBMS_OUTPUT.PUT_LINE('Total Orders: ' || v_count);

    CLOSE v_cursor;
END;
/