CREATE OR REPLACE PROCEDURE View_All_Orders_Payment(
    p_cursor OUT SYS_REFCURSOR
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
        FROM Orders_Payment@KimNgan_Oracle_DistributedDatabase op
        ORDER BY op.Created_At DESC;
END View_All_Orders_Payment;
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
    View_All_Orders_Payment(v_cursor);

    DBMS_OUTPUT.PUT_LINE(
        RPAD('Order ID',15) ||
        LPAD('Amount',18) ||
        RPAD('Status',15) ||
        RPAD('Created At',22) ||
        RPAD('Created By',20)
    );

    DBMS_OUTPUT.PUT_LINE(RPAD('-',90,'-'));

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
            RPAD(TO_CHAR(v_Created_At,'DD/MM/YYYY HH24:MI'),22) ||
            RPAD(NVL(v_Created_By,'-'),20)
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-',90,'-'));
    DBMS_OUTPUT.PUT_LINE('Total Payment Records: ' || v_count);

    CLOSE v_cursor;
END;
/