--- Warehouses Procedures
---* Insert new warehouse 
CREATE OR REPLACE PROCEDURE Insert_Warehouse(
    v_Hub_ID      VARCHAR2,
    v_Hub_Name    NVARCHAR2,
    v_Region_Code VARCHAR2
) AS
    v_target_link VARCHAR2(100);
BEGIN
    -- Xác định site đích dựa trên Region_Code
    IF v_Region_Code = 'DN' THEN
        -- Local (Đà Nẵng)
        INSERT INTO Warehouses@ThanhQuan_Oracle_DistributedDatabase (Hub_ID, Hub_Name, Region_Code, Created_By)
        VALUES (v_Hub_ID, v_Hub_Name, v_Region_Code, 'HN');
    ELSIF v_Region_Code = 'HN' THEN
        INSERT INTO Warehouses (Hub_ID, Hub_Name, Region_Code, Created_By)
        VALUES (v_Hub_ID, v_Hub_Name, v_Region_Code, 'HN');
    ELSIF v_Region_Code = 'HCM' THEN
        INSERT INTO Warehouses@KimNgan_Oracle_DistributedDatabase (Hub_ID, Hub_Name, Region_Code, Created_By)
        VALUES (v_Hub_ID, v_Hub_Name, v_Region_Code, 'HN');
    ELSE
        RAISE_APPLICATION_ERROR(-20100, 'Region_Code không hợp lệ (chỉ cho phép các giá trị(HCM, DN, HN)): ' || v_Region_Code);
    END IF;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

EXEC Insert_Warehouse('HUBHN001', 'Hồ Gươm', 'HN');
EXEC Insert_Warehouse('HUBHN002', 'Tây Hồ', 'HN');
EXEC Insert_Warehouse('HUBHN003', 'Đống Đa', 'HN');
EXEC Insert_Warehouse('HUBHN004', 'Ba Đình', 'HN');
EXEC Insert_Warehouse('HUBHN005', 'Thanh Xuân', 'HN');
EXEC Insert_Warehouse('HUBHN006', 'Hoàng Mai', 'HN');
EXEC Insert_Warehouse('HUBHN007', 'Long Biên', 'HN');