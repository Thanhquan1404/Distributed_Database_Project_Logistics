---* Update a customer
CREATE OR REPLACE PROCEDURE Update_Customer(
    v_Customer_ID      VARCHAR2,
    v_Customer_Name    NVARCHAR2 DEFAULT NULL,
    v_New_City         NVARCHAR2 DEFAULT NULL, 
    v_Customer_Rating  NUMBER DEFAULT NULL
) AS
    v_old_region   VARCHAR2(3);
    v_old_city     NVARCHAR2(255);
    v_new_region   VARCHAR2(3);
    v_target_link  VARCHAR2(100);
    v_count        NUMBER;
BEGIN
    -- Tìm customer ở site nào
    SELECT COUNT(*) INTO v_count FROM Customers WHERE Customer_ID = v_Customer_ID;
    IF v_count > 0 THEN
        v_target_link := 'HCM';
        SELECT City INTO v_old_city FROM Customers WHERE Customer_ID = v_Customer_ID;
    ELSE
        SELECT COUNT(*) INTO v_count FROM Customers@ThanhQuan_Oracle_DistributedDatabase WHERE Customer_ID = v_Customer_ID;
        IF v_count > 0 THEN
            v_target_link := 'DN';
            SELECT City INTO v_old_city FROM Customers@ThanhQuan_Oracle_DistributedDatabase WHERE Customer_ID = v_Customer_ID;
        ELSE
            SELECT COUNT(*) INTO v_count FROM Customers@MinhThuy_Oracle_DistributedDatabase WHERE Customer_ID = v_Customer_ID;
            IF v_count > 0 THEN
                v_target_link := 'HN';
                SELECT City INTO v_old_city FROM Customers@MinhThuy_Oracle_DistributedDatabase WHERE Customer_ID = v_Customer_ID;
            ELSE
                RAISE_APPLICATION_ERROR(-20011, 'Customer_ID không tồn tại');
            END IF;
        END IF;
    END IF;

    -- Nếu có thay đổi City, kiểm tra cùng vùng
    IF v_New_City IS NOT NULL THEN
        v_old_region := get_region_from_city(v_old_city);
        v_new_region := get_region_from_city(v_New_City);
        IF v_old_region != v_new_region THEN
            RAISE_APPLICATION_ERROR(-20012, 'Không thể đổi City sang vùng khác (phải di chuyển fragment)');
        END IF;
    END IF;

    -- Thực hiện cập nhật tại đúng site
    IF v_target_link = 'DN' THEN
        UPDATE Customers@ThanhQuan_Oracle_DistributedDatabase
        SET Customer_Name = NVL(v_Customer_Name, Customer_Name),
            City = NVL(v_New_City, City),
            Customer_Rating = NVL(v_Customer_Rating, Customer_Rating),
            Updated_By='HCM'
        WHERE Customer_ID = v_Customer_ID;
    ELSIF v_target_link = 'HN' THEN
        UPDATE Customers@MinhThuy_Oracle_DistributedDatabase
        SET Customer_Name = NVL(v_Customer_Name, Customer_Name),
            City = NVL(v_New_City, City),
            Customer_Rating = NVL(v_Customer_Rating, Customer_Rating),
            Updated_By='HCM'
        WHERE Customer_ID = v_Customer_ID;
    ELSE
        UPDATE Customers
        SET Customer_Name = NVL(v_Customer_Name, Customer_Name),
            City = NVL(v_New_City, City),
            Customer_Rating = NVL(v_Customer_Rating, Customer_Rating),
            Updated_By='HCM'
        WHERE Customer_ID = v_Customer_ID;
    END IF;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END Update_Customer;
/