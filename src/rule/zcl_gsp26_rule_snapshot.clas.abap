CLASS zcl_gsp26_rule_snapshot DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    " Backup dữ liệu Price Configuration
    CLASS-METHODS create_price_snapshot
      IMPORTING is_price_data TYPE zsd_price_conf.
ENDCLASS.

CLASS zcl_gsp26_rule_snapshot IMPLEMENTATION.
  METHOD create_price_snapshot.
    " Ghi trực tiếp vào bảng chính với version mới hoặc bảng history (nếu có)
    INSERT zsd_price_conf FROM is_price_data.
  ENDMETHOD.
ENDCLASS.
