CREATE OR REPLACE PROCEDURE Update_Order_Payment(
    v_Order_ID   VARCHAR2,
    v_Amount     NUMBER DEFAULT NULL,
    v_Pay_Status VARCHAR2 DEFAULT NULL
) AS
    v_count NUMBER;
BEGIN
    -- Kiểm tra Order_Payment tồn tại tại HCM
    SELECT COUNT(*) INTO v_count FROM Orders_Payment@KimNgan_Oracle_DistributedDatabase WHERE Order_ID = v_Order_ID;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20031, 'Order_ID không tồn tại trong Orders_Payment');
    END IF;

    UPDATE Orders_Payment@KimNgan_Oracle_DistributedDatabase
    SET Amount = NVL(v_Amount, Amount),
        Pay_Status = NVL(v_Pay_Status, Pay_Status),
        Updated_By = 'DN'
    WHERE Order_ID = v_Order_ID;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END Update_Order_Payment;
/