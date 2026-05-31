-- Initialize PROCEDURES 
--- Products Procedures
---* Insert new product
CREATE OR REPLACE PROCEDURE Insert_New_Product(
    v_Product_ID IN VARCHAR2,
    v_Product_Name IN NVARCHAR2,
    v_Product_Weight IN NUMBER,
    v_Cost_Of_Product IN NUMBER,
    v_Rating IN NUMBER
)
AS
    v_dn_exists NUMBER;
    v_hn_exists NUMBER;
    v_hcm_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_hcm_exists FROM Products WHERE Product_ID = v_Product_ID;
    SELECT COUNT(*) INTO v_dn_exists FROM Products@ThanhQuan_Oracle_DistributedDatabase WHERE Product_ID = v_Product_ID;
    SELECT COUNT(*) INTO v_hn_exists FROM Products@MinhThuy_Oracle_DistributedDatabase WHERE Product_ID = v_Product_ID;

    IF v_dn_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Product_ID đã tồn tại ở site Đà Nẵng');
    ELSIF v_hn_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Product_ID đã tồn tại ở site Hà Nội');
    ELSIF v_hcm_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Product_ID đã tồn tại ở site Hồ Chí Minh');
    END IF;

    INSERT INTO Products (Product_ID, Product_Name, Weight, Cost_Of_Product, Rating, Created_By)
    VALUES (v_Product_ID, v_Product_Name, v_Product_Weight, v_Cost_Of_Product, v_Rating, 'HCM');

    INSERT INTO Products@MinhThuy_Oracle_DistributedDatabase (Product_ID, Product_Name, Weight, Cost_Of_Product, Rating, Created_By)
    VALUES (v_Product_ID, v_Product_Name, v_Product_Weight, v_Cost_Of_Product, v_Rating, 'HCM');

    INSERT INTO Products@ThanhQuan_Oracle_DistributedDatabase (Product_ID, Product_Name, Weight, Cost_Of_Product, Rating, Created_By)
    VALUES (v_Product_ID, v_Product_Name, v_Product_Weight, v_Cost_Of_Product, v_Rating, 'HCM');

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;  
        RAISE;
END Insert_New_Product;
/