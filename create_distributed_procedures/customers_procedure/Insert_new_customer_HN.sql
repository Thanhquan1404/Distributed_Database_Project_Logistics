--- Customers Procedures
---* Function to get city in region
CREATE OR REPLACE FUNCTION get_region_from_city(v_city NVARCHAR2) RETURN VARCHAR2
IS
BEGIN
    IF v_city IN (N'Hà Nội', N'Hải Phòng', N'Bắc Ninh', N'Hạ Long', N'Nam Định', N'Thái Bình', N'Hưng Yên', N'Hải Dương') THEN
        RETURN 'HN';
    ELSIF v_city IN (N'Đà Nẵng', N'Huế', N'Hội An', N'Tam Kỳ', N'Quảng Ngãi', N'Bình Định', N'Phú Yên', N'Nha Trang') THEN
        RETURN 'DN';
    ELSIF v_city IN (N'Hồ Chí Minh', N'Cần Thơ', N'Biên Hòa', N'Vũng Tàu', N'Bình Dương', N'Long An', N'Tiền Giang', N'Đồng Nai') THEN
        RETURN 'HCM';
    ELSE
        RETURN NULL; 
    END IF;
END;
/

---* Insert new customer
CREATE OR REPLACE PROCEDURE Insert_Customer(
    v_Customer_ID      VARCHAR2,
    v_Customer_Name    NVARCHAR2,
    v_City            NVARCHAR2,
    v_Customer_Rating NUMBER DEFAULT 0
) AS
    v_region VARCHAR2(3);
BEGIN
    -- Xác định vùng dựa trên City
    v_region := get_region_from_city(v_City);
    IF v_region IS NULL THEN
        RAISE_APPLICATION_ERROR(-20010, 'City không thuộc vùng nào được định nghĩa: ' || v_City);
    END IF;

    -- Chèn vào đúng site
    IF v_region = 'DN' THEN
        INSERT INTO Customers@ThanhQuan_Oracle_DistributedDatabase (Customer_ID, Customer_Name, City, Customer_Rating, Created_By)
        VALUES (v_Customer_ID, v_Customer_Name, v_City, v_Customer_Rating, 'HN');
    ELSIF v_region = 'HN' THEN
        INSERT INTO Customers (Customer_ID, Customer_Name, City, Customer_Rating, Created_By)
        VALUES (v_Customer_ID, v_Customer_Name, v_City, v_Customer_Rating, 'HN');
    ELSE -- HCM
        INSERT INTO Customers@KimNgan_Oracle_DistributedDatabase (Customer_ID, Customer_Name, City, Customer_Rating, Created_By)
        VALUES (v_Customer_ID, v_Customer_Name, v_City, v_Customer_Rating, 'HN');
    END IF;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END Insert_Customer;
/

EXEC Insert_Customer('CUS1036', 'Nguyen Van Teo', 'Hải Phòng', 5);
EXEC Insert_Customer('CUS1037', 'Le Thi Kobe', 'Bắc Ninh', 5);
EXEC Insert_Customer('CUS1038', 'Tran Van Gi', 'Nam Định', 5);
