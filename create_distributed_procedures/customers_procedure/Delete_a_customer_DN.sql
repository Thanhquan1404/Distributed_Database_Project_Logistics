CREATE OR REPLACE PROCEDURE Delete_Customer(v_Customer_ID VARCHAR2) AS
    v_target_link VARCHAR2(100);
    v_count NUMBER;
BEGIN
    -- Xác định site chứa customer
    SELECT COUNT(*) INTO v_count FROM Customers WHERE Customer_ID = v_Customer_ID;
    IF v_count > 0 THEN
        DELETE FROM Customers WHERE Customer_ID = v_Customer_ID;
    ELSE
        SELECT COUNT(*) INTO v_count FROM Customers@MinhThuy_Oracle_DistributedDatabase WHERE Customer_ID = v_Customer_ID;
        IF v_count > 0 THEN
            DELETE FROM Customers@MinhThuy_Oracle_DistributedDatabase WHERE Customer_ID = v_Customer_ID;
        ELSE
            SELECT COUNT(*) INTO v_count FROM Customers@KimNgan_Oracle_DistributedDatabase WHERE Customer_ID = v_Customer_ID;
            IF v_count > 0 THEN
                DELETE FROM Customers@KimNgan_Oracle_DistributedDatabase WHERE Customer_ID = v_Customer_ID;
            ELSE
                RAISE_APPLICATION_ERROR(-20013, 'Customer_ID không tồn tại');
            END IF;
        END IF;
    END IF;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END Delete_Customer;
/