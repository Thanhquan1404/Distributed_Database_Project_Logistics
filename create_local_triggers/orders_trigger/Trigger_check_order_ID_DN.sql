CREATE OR REPLACE TRIGGER TRG_CHECK_ORDER_ID
BEFORE INSERT OR UPDATE OF Order_ID ON Orders_Ops
FOR EACH ROW
DECLARE
    v_hub_region VARCHAR2(3);
BEGIN
    -- Lấy Region của Root_Hub thông qua hàm bạn đã viết
    v_hub_region := get_region_of_hub(:NEW.Root_Hub);
    
    IF :NEW.Order_ID NOT LIKE 'ORD' || v_hub_region || '%' THEN
        RAISE_APPLICATION_ERROR(-20004, 'Lỗi: Order_ID phải bắt đầu bằng ORD + ' || v_hub_region || ' dựa trên Root_Hub.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_LOCAL_DN_ORDER
BEFORE INSERT OR UPDATE OF Order_ID, Root_Hub ON Orders_Ops
FOR EACH ROW
DECLARE
    v_hub_region VARCHAR2(3);
BEGIN
    v_hub_region := get_region_of_hub(:NEW.Root_Hub);
    
    -- Kiểm tra tiền tố ID Đơn hàng
    IF :NEW.Order_ID NOT LIKE 'ORDDN%' THEN
        RAISE_APPLICATION_ERROR(-20025, 'Lỗi bảo mật Site DN: Order_ID bắt buộc phải bắt đầu bằng "ORDDN"!');
    END IF;
    
    -- Đảm bảo Đơn hàng lưu tại DN thì Kho khởi tạo (Root_Hub) phải thuộc chi nhánh DN
    IF v_hub_region != 'DN' OR v_hub_region IS NULL THEN
        RAISE_APPLICATION_ERROR(-20026, 'Lỗi bảo mật Site DN: Kho gốc (Root_Hub) của đơn hàng này phải thuộc phân vùng ĐÀ NẴNG!');
    END IF;
END;
/