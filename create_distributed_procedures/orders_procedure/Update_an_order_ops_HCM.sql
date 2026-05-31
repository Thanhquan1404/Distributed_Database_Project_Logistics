CREATE OR REPLACE PROCEDURE Update_Order_Ops(
    v_Order_ID      VARCHAR2,
    v_Status        VARCHAR2 DEFAULT NULL,
    v_Mode_Shipment VARCHAR2 DEFAULT NULL,
    v_Dest_Hub      VARCHAR2 DEFAULT NULL
) AS
    v_region VARCHAR2(3);
    v_count NUMBER;
BEGIN
    -- Tìm Order_Ops đang nằm ở site nào dựa trên Order_ID (cần xác định bằng cách thử từng site)
    SELECT COUNT(*) INTO v_count FROM Orders_Ops WHERE Order_ID = v_Order_ID;
    IF v_count > 0 THEN
        v_region := 'HCM';
    ELSE
        SELECT COUNT(*) INTO v_count FROM Orders_Ops@ThanhQuan_Oracle_DistributedDatabase WHERE Order_ID = v_Order_ID;
        IF v_count > 0 THEN
            v_region := 'DN';
        ELSE
            SELECT COUNT(*) INTO v_count FROM Orders_Ops@MinhThuy_Oracle_DistributedDatabase WHERE Order_ID = v_Order_ID;
            IF v_count > 0 THEN
                v_region := 'HN';
            ELSE
                RAISE_APPLICATION_ERROR(-20030, 'Order_ID không tồn tại trong Orders_Ops');
            END IF;
        END IF;
    END IF;

    -- Cập nhật tại đúng site
    IF v_region = 'DN' THEN
        UPDATE Orders_Ops@ThanhQuan_Oracle_DistributedDatabase
        SET Status = NVL(v_Status, Status),
            Mode_Of_Shipment = NVL(v_Mode_Shipment, Mode_Of_Shipment),
            Dest_Hub = NVL(v_Dest_Hub, Dest_Hub),
            Updated_By = 'HCM'
        WHERE Order_ID = v_Order_ID;
    ELSIF v_region = 'HN' THEN
        UPDATE Orders_Ops@MinhThuy_Oracle_DistributedDatabase
        SET Status = NVL(v_Status, Status),
            Mode_Of_Shipment = NVL(v_Mode_Shipment, Mode_Of_Shipment),
            Dest_Hub = NVL(v_Dest_Hub, Dest_Hub),
            Updated_By = 'HCM'
        WHERE Order_ID = v_Order_ID;
    ELSE
        UPDATE Orders_Ops
        SET Status = NVL(v_Status, Status),
            Mode_Of_Shipment = NVL(v_Mode_Shipment, Mode_Of_Shipment),
            Dest_Hub = NVL(v_Dest_Hub, Dest_Hub),
            Updated_By = 'HCM'
        WHERE Order_ID = v_Order_ID;
    END IF;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END Update_Order_Ops;
/