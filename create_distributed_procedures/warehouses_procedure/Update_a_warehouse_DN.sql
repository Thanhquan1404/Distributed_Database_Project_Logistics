CREATE OR REPLACE PROCEDURE Update_Warehouse(
    v_Hub_ID      VARCHAR2,
    v_Hub_Name    NVARCHAR2 DEFAULT NULL
) AS
    v_region VARCHAR2(255);
BEGIN
    -- Tìm region cũ
    BEGIN
        SELECT Region_Code INTO v_region FROM Warehouses WHERE Hub_ID = v_Hub_ID;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        BEGIN
            SELECT Region_Code INTO v_region FROM Warehouses@MinhThuy_Oracle_DistributedDatabase WHERE Hub_ID = v_Hub_ID;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            SELECT Region_Code INTO v_region FROM Warehouses@KimNgan_Oracle_DistributedDatabase WHERE Hub_ID = v_Hub_ID;
        END;
    END;

    -- Cập nhật tại đúng site
    IF v_region = 'DN' THEN
        UPDATE Warehouses
        SET Hub_Name = NVL(v_Hub_Name, Hub_Name),
            Updated_By = 'DN'
        WHERE Hub_ID = v_Hub_ID;
    ELSIF v_region = 'HN' THEN
        UPDATE Warehouses@MinhThuy_Oracle_DistributedDatabase
        SET Hub_Name = NVL(v_Hub_Name, Hub_Name), 
            Updated_By = 'DN'
        WHERE Hub_ID = v_Hub_ID;
    ELSE -- HCM
        UPDATE Warehouses@KimNgan_Oracle_DistributedDatabase
        SET Hub_Name = NVL(v_Hub_Name, Hub_Name),
            Updated_By = 'DN'
        WHERE Hub_ID = v_Hub_ID;
    END IF;
    COMMIT;
END;
/