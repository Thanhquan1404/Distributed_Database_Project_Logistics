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
        VALUES (v_Hub_ID, v_Hub_Name, v_Region_Code, 'HCM');
    ELSIF v_Region_Code = 'HN' THEN
        INSERT INTO Warehouses@MinhThuy_Oracle_DistributedDatabase (Hub_ID, Hub_Name, Region_Code, Created_By)
        VALUES (v_Hub_ID, v_Hub_Name, v_Region_Code, 'HCM');
    ELSIF v_Region_Code = 'HCM' THEN
        INSERT INTO Warehouses (Hub_ID, Hub_Name, Region_Code, Created_By)
        VALUES (v_Hub_ID, v_Hub_Name, v_Region_Code, 'HCM');
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

EXEC Insert_Warehouse('HUBHCM001', 'Bình Tân', 'HCM');
EXEC Insert_Warehouse('HUBHCM002', 'Tân Phú', 'HCM');
EXEC Insert_Warehouse('HUBHCM003', 'Thủ Đức', 'HCM');
EXEC Insert_Warehouse('HUBHCM004', 'Bến Thành', 'HCM');
EXEC Insert_Warehouse('HUBHCM005', 'Ba Son', 'HCM');
EXEC Insert_Warehouse('HUBHCM006', 'Nhà Bè', 'HCM');
EXEC Insert_Warehouse('HUBHCM007', 'Củ Chi', 'HCM');