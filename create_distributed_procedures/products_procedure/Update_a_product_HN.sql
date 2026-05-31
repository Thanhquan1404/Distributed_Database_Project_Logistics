----* Update product information 
CREATE OR REPLACE PROCEDURE Update_Product(
    v_Product_ID IN VARCHAR2,
    v_Product_Name IN NVARCHAR2 DEFAULT NULL,
    v_Weight IN NUMBER DEFAULT NULL,
    v_Cost IN NUMBER DEFAULT NULL,
    v_Rating IN NUMBER DEFAULT NULL
)
AS
    v_dn_exists NUMBER;
    v_hn_exists NUMBER;
    v_hcm_exists NUMBER;
BEGIN
    -- Kiểm tra sản phẩm có tồn tại ở local và remote  không 
    SELECT COUNT(*) INTO v_dn_exists FROM Products@ThanhQuan_Oracle_DistributedDatabase WHERE Product_ID = v_Product_ID;
    SELECT COUNT(*) INTO v_hn_exists FROM Products WHERE Product_ID = v_Product_ID;
    SELECT COUNT(*) INTO v_hcm_exists FROM Products@KimNgan_Oracle_DistributedDatabase WHERE Product_ID = v_Product_ID;
    
    IF v_dn_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Product_ID không tồn tại ở site Đà Nẵng');
    ELSIF v_hn_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Product_ID không tồn tại ở site Hà Nội');
    ELSIF v_hcm_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Product_ID không tồn tại ở site Hồ Chí Minh');
    END IF;

    -- Cập nhật local
    UPDATE Products
    SET Product_Name = NVL(v_Product_Name, Product_Name),
        Weight = NVL(v_Weight, Weight),
        Cost_Of_Product = NVL(v_Cost, Cost_Of_Product),
        Rating = NVL(v_Rating, Rating),
        Updated_By = 'HN'
    WHERE Product_ID = v_Product_ID;

    -- Cập nhật remote DN
    UPDATE Products@ThanhQuan_Oracle_DistributedDatabase
    SET Product_Name = NVL(v_Product_Name, Product_Name),
        Weight = NVL(v_Weight, Weight),
        Cost_Of_Product = NVL(v_Cost, Cost_Of_Product),
        Rating = NVL(v_Rating, Rating),
        Updated_By = 'HN'
    WHERE Product_ID = v_Product_ID;

    -- Cập nhật remote HCM
    UPDATE Products@KimNgan_Oracle_DistributedDatabase
    SET Product_Name = NVL(v_Product_Name, Product_Name),
        Weight = NVL(v_Weight, Weight),
        Cost_Of_Product = NVL(v_Cost, Cost_Of_Product),
        Rating = NVL(v_Rating, Rating),
        Updated_By = 'HN'
    WHERE Product_ID = v_Product_ID;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END Update_Product;
/