CREATE OR REPLACE TRIGGER TRG_CHECK_WAREHOUSE_ID
BEFORE INSERT OR UPDATE OF Hub_ID ON Warehouses
FOR EACH ROW
BEGIN
    -- Kiểm tra định dạng ID phải bắt đầu bằng HUB + Region_Code của Site (DN)
    IF :NEW.Hub_ID NOT LIKE 'HUB' || :NEW.Region_Code || '%' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Lỗi: Hub_ID phải tuân theo định dạng: HUB + REGION (Ví dụ: HUBHN...)');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_LOCAL_DN_WAREHOUSE
BEFORE INSERT OR UPDATE OF Hub_ID, Region_Code ON Warehouses
FOR EACH ROW
BEGIN
    IF :NEW.Hub_ID NOT LIKE 'HUBHN%' THEN
        RAISE_APPLICATION_ERROR(-20021, 'Lỗi bảo mật Site HCM: Hub_ID bắt buộc phải bắt đầu bằng "HUBHN"!');
    END IF;
    
    IF :NEW.Region_Code != 'HN' THEN
        RAISE_APPLICATION_ERROR(-20022, 'Lỗi bảo mật Site HN: Region_Code tại site này bắt buộc phải là "HN"!');
    END IF;
END;
/
