CREATE OR REPLACE PROCEDURE Delete_Warehouse(v_Hub_ID VARCHAR2) AS
    v_region VARCHAR2(255);
BEGIN
    -- Xác định region
    BEGIN
        SELECT Region_Code INTO v_region FROM Warehouses WHERE Hub_ID = v_Hub_ID;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        BEGIN
            SELECT Region_Code INTO v_region FROM Warehouses@ThanhQuan_Oracle_DistributedDatabase WHERE Hub_ID = v_Hub_ID;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            SELECT Region_Code INTO v_region FROM Warehouses@KimNgan_Oracle_DistributedDatabase WHERE Hub_ID = v_Hub_ID;
        END;
    END;
    
    IF v_region = 'DN' THEN
        DELETE FROM Warehouses@ThanhQuan_Oracle_DistributedDatabase WHERE Hub_ID = v_Hub_ID;
    ELSIF v_region = 'HN' THEN
        DELETE FROM Warehouses WHERE Hub_ID = v_Hub_ID;
    ELSE
        DELETE FROM Warehouses@KimNgan_Oracle_DistributedDatabase WHERE Hub_ID = v_Hub_ID;
    END IF;
    COMMIT;
END;
/