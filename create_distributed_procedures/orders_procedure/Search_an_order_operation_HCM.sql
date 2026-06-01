--- Search Orders_Ops
CREATE OR REPLACE PROCEDURE Search_Orders_Ops(
    p_cursor           OUT SYS_REFCURSOR,
    v_Order_ID         VARCHAR2 DEFAULT NULL,   -- Lọc theo Order ID (LIKE)
    v_Customer_ID      VARCHAR2 DEFAULT NULL,   -- Lọc theo Customer
    v_Product_ID       VARCHAR2 DEFAULT NULL,   -- Lọc theo Product
    v_Status           VARCHAR2 DEFAULT NULL,   -- Lọc theo trạng thái
    v_Mode_Of_Shipment VARCHAR2 DEFAULT NULL,   -- Lọc theo phương thức vận chuyển
    v_Root_Hub         VARCHAR2 DEFAULT NULL,   -- Lọc theo hub xuất phát
    v_Dest_Hub         VARCHAR2 DEFAULT NULL,   -- Lọc theo hub đích
    v_From_Date        TIMESTAMP DEFAULT NULL,  -- Lọc từ ngày
    v_To_Date          TIMESTAMP DEFAULT NULL   -- Lọc đến ngày
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
            SELECT * FROM Orders_Ops@MinhThuy_Oracle_DistributedDatabase
            UNION ALL
            SELECT * FROM Orders_Ops@ThanhQuan_Oracle_DistributedDatabase
        ) o
        WHERE (v_Order_ID         IS NULL OR UPPER(o.Order_ID)         LIKE '%' || UPPER(v_Order_ID)         || '%')
          AND (v_Customer_ID      IS NULL OR UPPER(o.Customer_ID)      LIKE '%' || UPPER(v_Customer_ID)      || '%')
          AND (v_Product_ID       IS NULL OR UPPER(o.Product_ID)       LIKE '%' || UPPER(v_Product_ID)       || '%')
          AND (v_Status           IS NULL OR UPPER(o.Status)           = UPPER(v_Status))
          AND (v_Mode_Of_Shipment IS NULL OR UPPER(o.Mode_Of_Shipment) = UPPER(v_Mode_Of_Shipment))
          AND (v_Root_Hub         IS NULL OR UPPER(o.Root_Hub)         LIKE '%' || UPPER(v_Root_Hub)         || '%')
          AND (v_Dest_Hub         IS NULL OR UPPER(o.Dest_Hub)         LIKE '%' || UPPER(v_Dest_Hub)         || '%')
          AND (v_From_Date        IS NULL OR o.Created_At >= v_From_Date)
          AND (v_To_Date          IS NULL OR o.Created_At <= v_To_Date)
        ORDER BY o.Created_At DESC;
END Search_Orders_Ops;
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
    Search_Orders_Ops(
        p_cursor           => v_cursor,
        v_Order_ID         => NULL,
        v_Customer_ID      => NULL,
        v_Product_ID       => NULL,
        v_Status           => NULL,
        v_Mode_Of_Shipment => NULL,
        v_Root_Hub         => NULL,
        v_Dest_Hub         => NULL,
        v_From_Date        => NULL,
        v_To_Date          => NULL
    );

    DBMS_OUTPUT.PUT_LINE(
        RPAD('Order ID',15) ||
        RPAD('Customer',15) ||
        RPAD('Product',15) ||
        RPAD('Origin',10) ||
        RPAD('Dest',10) ||
        RPAD('Status',15)
    );

    DBMS_OUTPUT.PUT_LINE(RPAD('-',80,'-'));

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
            RPAD(v_Status,15)
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-',80,'-'));
    DBMS_OUTPUT.PUT_LINE('Total Orders Found: ' || v_count);

    CLOSE v_cursor;
END;
/