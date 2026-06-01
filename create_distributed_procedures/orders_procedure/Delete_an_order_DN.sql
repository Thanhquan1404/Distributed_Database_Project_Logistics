CREATE OR REPLACE PROCEDURE Delete_Order(v_Order_ID VARCHAR2) AS
    v_region VARCHAR2(3);
    v_count NUMBER;
BEGIN
    -- Xác định site chứa Orders_Ops
    SELECT COUNT(*) INTO v_count FROM Orders_Ops WHERE Order_ID = v_Order_ID;
    IF v_count > 0 THEN
        v_region := 'DN';
        DELETE FROM Orders_Ops WHERE Order_ID = v_Order_ID;
    ELSE
        SELECT COUNT(*) INTO v_count FROM Orders_Ops@MinhThuy_Oracle_DistributedDatabase WHERE Order_ID = v_Order_ID;
        IF v_count > 0 THEN
            v_region := 'HN';
            DELETE FROM Orders_Ops@MinhThuy_Oracle_DistributedDatabase WHERE Order_ID = v_Order_ID;
        ELSE
            SELECT COUNT(*) INTO v_count FROM Orders_Ops@KimNgan_Oracle_DistributedDatabase WHERE Order_ID = v_Order_ID;
            IF v_count > 0 THEN
                v_region := 'HCM';
                DELETE FROM Orders_Ops@KimNgan_Oracle_DistributedDatabase WHERE Order_ID = v_Order_ID;
            ELSE
                RAISE_APPLICATION_ERROR(-20032, 'Order_ID không tồn tại trong Orders_Ops');
            END IF;
        END IF;
    END IF;

    -- Xoá Orders_Payment tại HCM (nếu có)
    DELETE FROM Orders_Payment@KimNgan_Oracle_DistributedDatabase WHERE Order_ID = v_Order_ID;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END Delete_Order;
/