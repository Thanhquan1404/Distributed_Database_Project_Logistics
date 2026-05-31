--- Orders Procedures
---* Get Region ID when knowning hub ID
CREATE OR REPLACE FUNCTION get_region_of_hub(v_hub_id VARCHAR2) RETURN VARCHAR2
IS
    v_region VARCHAR2(3);
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM Warehouses WHERE Hub_ID = v_hub_id;
    IF v_count > 0 THEN
        SELECT Region_Code INTO v_region FROM Warehouses WHERE Hub_ID = v_hub_id;
        RETURN v_region;
    END IF;
    SELECT COUNT(*) INTO v_count FROM Warehouses@MinhThuy_Oracle_DistributedDatabase WHERE Hub_ID = v_hub_id;
    IF v_count > 0 THEN
        SELECT Region_Code INTO v_region FROM Warehouses@MinhThuy_Oracle_DistributedDatabase WHERE Hub_ID = v_hub_id;
        RETURN v_region;
    END IF;
    SELECT COUNT(*) INTO v_count FROM Warehouses@KimNgan_Oracle_DistributedDatabase WHERE Hub_ID = v_hub_id;
    IF v_count > 0 THEN
        SELECT Region_Code INTO v_region FROM Warehouses@KimNgan_Oracle_DistributedDatabase WHERE Hub_ID = v_hub_id;
        RETURN v_region;
    END IF;
    RETURN NULL;
END;
/

--* Insert an order that satisfies horizontal fragments devided into Orders_Ops and Orders_Payment
CREATE OR REPLACE PROCEDURE Insert_Order(
    v_Order_ID           VARCHAR2,
    v_Customer_ID        VARCHAR2,
    v_Product_ID         VARCHAR2,
    v_Root_Hub           VARCHAR2,
    v_Dest_Hub           VARCHAR2,
    v_Mode_Of_Shipment   VARCHAR2,
    v_Status             VARCHAR2 DEFAULT 'PENDING',
    v_Amount             NUMBER,
    v_Pay_Status         VARCHAR2 DEFAULT 'UNPAID'
) AS
    v_root_region VARCHAR2(3);
    v_cust_exists NUMBER;
    v_prod_exists NUMBER;
    v_root_hub_exists NUMBER;
    v_dest_hub_exists NUMBER;
BEGIN
    -- Kiểm tra ràng buộc toàn vẹn phân tán
    -- Customer: kiểm tra tồn tại (có thể ở bất kỳ site nào)
    SELECT COUNT(*) INTO v_cust_exists FROM Customers WHERE Customer_ID = v_Customer_ID;
    IF v_cust_exists = 0 THEN
        SELECT COUNT(*) INTO v_cust_exists FROM Customers@MinhThuy_Oracle_DistributedDatabase WHERE Customer_ID = v_Customer_ID;
    END IF;
    IF v_cust_exists = 0 THEN
        SELECT COUNT(*) INTO v_cust_exists FROM Customers@KimNgan_Oracle_DistributedDatabase WHERE Customer_ID = v_Customer_ID;
    END IF;
    IF v_cust_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20020, 'Customer_ID không tồn tại');
    END IF;

    -- Product: full replicate, kiểm tra local đủ
    SELECT COUNT(*) INTO v_prod_exists FROM Products WHERE Product_ID = v_Product_ID;
    IF v_prod_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20021, 'Product_ID không tồn tại');
    END IF;

    -- Root_Hub và Dest_Hub phải tồn tại (dùng hàm hub_exists đã viết hoặc kiểm tra thủ công)
    v_root_region := get_region_of_hub(v_Root_Hub);
    IF v_root_region IS NULL THEN
        RAISE_APPLICATION_ERROR(-20022, 'Root_Hub không tồn tại hoặc không xác định được region');
    END IF;

    IF get_region_of_hub(v_Dest_Hub) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20023, 'Dest_Hub không tồn tại');
    END IF;

    -- 1. Chèn vào Orders_Ops tại site tương ứng với Root_Hub
    IF v_root_region = 'DN' THEN
        INSERT INTO Orders_Ops (Order_ID, Customer_ID, Product_ID, Root_Hub, Dest_Hub, Mode_Of_Shipment, Status, Created_By)
        VALUES (v_Order_ID, v_Customer_ID, v_Product_ID, v_Root_Hub, v_Dest_Hub, v_Mode_Of_Shipment, v_Status, 'DN');
    ELSIF v_root_region = 'HN' THEN
        INSERT INTO Orders_Ops@MinhThuy_Oracle_DistributedDatabase (Order_ID, Customer_ID, Product_ID, Root_Hub, Dest_Hub, Mode_Of_Shipment, Status, Created_By)
        VALUES (v_Order_ID, v_Customer_ID, v_Product_ID, v_Root_Hub, v_Dest_Hub, v_Mode_Of_Shipment, v_Status, 'DN');
    ELSE -- HCM
        INSERT INTO Orders_Ops@KimNgan_Oracle_DistributedDatabase (Order_ID, Customer_ID, Product_ID, Root_Hub, Dest_Hub, Mode_Of_Shipment, Status,  Created_By)
        VALUES (v_Order_ID, v_Customer_ID, v_Product_ID, v_Root_Hub, v_Dest_Hub, v_Mode_Of_Shipment, v_Status, 'DN');
    END IF;

    -- 2. Chèn vào Orders_Payment (centralized tại HCM)
    INSERT INTO Orders_Payment@KimNgan_Oracle_DistributedDatabase (Order_ID, Amount, Pay_Status, Created_By)
    VALUES (v_Order_ID, v_Amount, v_Pay_Status, 'DN');

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END Insert_Order;
/