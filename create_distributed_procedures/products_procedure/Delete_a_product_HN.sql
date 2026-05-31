----* Delete a product
CREATE OR REPLACE PROCEDURE Delete_Product(
    v_Product_ID IN VARCHAR2
)
AS
    v_dn_exists NUMBER;
    v_hn_exists NUMBER;
    v_hcm_exists NUMBER;
BEGIN
    --- Kiểm tra sản phẩm có tồn tại ở local và remote  không 
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

    -- Xoá ở cả 3 site
    DELETE FROM Products@ThanhQuan_Oracle_DistributedDatabase WHERE Product_ID = v_Product_ID;
    DELETE FROM Products WHERE Product_ID = v_Product_ID;
    DELETE FROM Products@KimNgan_Oracle_DistributedDatabase WHERE Product_ID = v_Product_ID;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END Delete_Product;
/
