CREATE OR REPLACE TRIGGER TRG_CHECK_CUSTOMER_ID
BEFORE INSERT OR UPDATE OF Customer_ID ON Customers
FOR EACH ROW
DECLARE
    v_region VARCHAR2(10);
BEGIN
    v_region := get_region_from_city(:NEW.City);
    
    IF :NEW.Customer_ID NOT LIKE 'CUST' || v_region || '%' THEN
        RAISE_APPLICATION_ERROR(-20003, 'Lỗi: Customer_ID phải bắt đầu bằng CUST + ' || v_region);
    END IF;
END;
/

---* Check valid ID of customer trước khi insert  
CREATE OR REPLACE TRIGGER TRG_LOCAL_DN_CUSTOMER
BEFORE INSERT OR UPDATE OF Customer_ID, City ON Customers
FOR EACH ROW
DECLARE
    v_region VARCHAR2(10);
BEGIN
    v_region := get_region_from_city(:NEW.City);
    
    IF :NEW.Customer_ID NOT LIKE 'CUSTHN%' THEN
        RAISE_APPLICATION_ERROR(-20023, 'Lỗi bảo mật Site DN: Customer_ID bắt buộc phải bắt đầu bằng "CUSTHN"!');
    END IF;
    
    IF v_region != 'HN' OR v_region IS NULL THEN
        RAISE_APPLICATION_ERROR(-20024, 'Lỗi bảo mật Site DN: Thành phố ' || :NEW.City || ' không thuộc phạm vi quản lý của chi nhánh Hà Nội!');
    END IF;
END;
/
