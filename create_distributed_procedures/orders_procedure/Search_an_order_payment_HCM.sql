--- Search Orders_Payment
CREATE OR REPLACE PROCEDURE Search_Orders_Payment(
    p_cursor      OUT SYS_REFCURSOR,
    v_Order_ID    VARCHAR2  DEFAULT NULL,   -- Lọc theo Order ID (LIKE)
    v_Pay_Status  VARCHAR2  DEFAULT NULL,   -- 'PAID' | 'UNPAID' | 'REFUNDED'
    v_Min_Amount  NUMBER    DEFAULT NULL,   -- Số tiền từ
    v_Max_Amount  NUMBER    DEFAULT NULL,   -- Số tiền đến
    v_From_Date   TIMESTAMP DEFAULT NULL,  -- Từ ngày
    v_To_Date     TIMESTAMP DEFAULT NULL   -- Đến ngày
) AS
BEGIN
    OPEN p_cursor FOR
        SELECT
            op.Order_ID,
            op.Amount,
            op.Pay_Status,
            op.Created_At,
            op.Created_By,
            op.Updated_By
        FROM Orders_Payment op
        WHERE (v_Order_ID   IS NULL OR UPPER(op.Order_ID)   LIKE '%' || UPPER(v_Order_ID) || '%')
          AND (v_Pay_Status IS NULL OR UPPER(op.Pay_Status) = UPPER(v_Pay_Status))
          AND (v_Min_Amount IS NULL OR op.Amount >= v_Min_Amount)
          AND (v_Max_Amount IS NULL OR op.Amount <= v_Max_Amount)
          AND (v_From_Date  IS NULL OR op.Created_At >= v_From_Date)
          AND (v_To_Date    IS NULL OR op.Created_At <= v_To_Date)
        ORDER BY op.Created_At DESC;
END Search_Orders_Payment;
/

SET SERVEROUTPUT ON;

DECLARE
    v_cursor SYS_REFCURSOR;

    v_Order_ID    VARCHAR2(30);
    v_Amount      NUMBER;
    v_Pay_Status  VARCHAR2(20);
    v_Created_At  TIMESTAMP;
    v_Created_By  VARCHAR2(50);
    v_Updated_By  VARCHAR2(50);

    v_count NUMBER := 0;

BEGIN
    Search_Orders_Payment(
        p_cursor     => v_cursor,
        v_Order_ID   => NULL,
        v_Pay_Status => NULL,
        v_Min_Amount => 1,
        v_Max_Amount => 10000000,
        v_From_Date  => NULL,
        v_To_Date    => NULL
    );

    DBMS_OUTPUT.PUT_LINE(
        RPAD('Order ID',15) ||
        LPAD('Amount',18) ||
        RPAD('Status',15) ||
        RPAD('Created At',22)
    );

    DBMS_OUTPUT.PUT_LINE(RPAD('-',75,'-'));

    LOOP
        FETCH v_cursor INTO
            v_Order_ID,
            v_Amount,
            v_Pay_Status,
            v_Created_At,
            v_Created_By,
            v_Updated_By;

        EXIT WHEN v_cursor%NOTFOUND;

        v_count := v_count + 1;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(v_Order_ID,15) ||
            LPAD(TO_CHAR(v_Amount,'999,999,999,990.00'),18) ||
            RPAD(v_Pay_Status,15) ||
            RPAD(TO_CHAR(v_Created_At,'DD/MM/YYYY HH24:MI'),22)
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-',75,'-'));
    DBMS_OUTPUT.PUT_LINE('Total Records Found: ' || v_count);

    CLOSE v_cursor;
END;
/
