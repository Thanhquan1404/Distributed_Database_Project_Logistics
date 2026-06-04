CREATE OR REPLACE TRIGGER TRG_CHECK_WAREHOUSE_ID
BEFORE INSERT OR UPDATE OF Hub_ID ON Warehouses
FOR EACH ROW
BEGIN
    -- Kiểm tra định dạng ID phải bắt đầu bằng HUB + Region_Code của Site (DN)
    IF :NEW.Hub_ID NOT LIKE 'HUB' || :NEW.Region_Code || '%' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Lỗi: Hub_ID phải tuân theo định dạng: HUB + REGION (Ví dụ: HUBDN...)');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_LOCAL_DN_WAREHOUSE
BEFORE INSERT OR UPDATE OF Hub_ID, Region_Code ON Warehouses
FOR EACH ROW
BEGIN
    -- Kiểm tra tiền tố ID của Kho
    IF :NEW.Hub_ID NOT LIKE 'HUBDN%' THEN
        RAISE_APPLICATION_ERROR(-20021, 'Lỗi bảo mật Site DN: Hub_ID bắt buộc phải bắt đầu bằng "HUBDN"!');
    END IF;
    
    -- Kiểm tra mã Vùng miền vật lý tại site
    IF :NEW.Region_Code != 'DN' THEN
        RAISE_APPLICATION_ERROR(-20022, 'Lỗi bảo mật Site DN: Region_Code tại site này bắt buộc phải là "DN"!');
    END IF;
END;
/
