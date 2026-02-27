CLASS zcl_gsp26_rule_writer DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS log_audit_entry
      IMPORTING iv_conf_id  TYPE sysuuid_x16
                iv_req_id   TYPE sysuuid_x16 OPTIONAL
                iv_mod_id   TYPE char10
                iv_act_type TYPE zde_action_type
                iv_tab_name TYPE char30
                iv_env_id   TYPE zde_env_id
                is_old_data TYPE any OPTIONAL
                is_new_data TYPE any OPTIONAL
      RAISING   cx_uuid_error. " Giải quyết lỗi Exception UUID ở image_3c8b4b.png
ENDCLASS.

CLASS zcl_gsp26_rule_writer IMPLEMENTATION.
  METHOD log_audit_entry.
    " Lấy timestamp hiện tại (khớp với kiểu TIMESTAMPL trong bảng ZAUDITLOG)
    GET TIME STAMP FIELD DATA(lv_timestamp).

    " Map chính xác với cấu trúc định nghĩa trong bảng ZAUDITLOG (image_3c8462.png)
    DATA(ls_audit) = VALUE zauditlog(
      log_id      = cl_system_uuid=>create_uuid_x16_static( )
      req_id      = iv_req_id
      conf_id     = iv_conf_id
      module_id   = iv_mod_id
      action_type = iv_act_type
      table_name  = iv_tab_name
      env_id      = iv_env_id
      old_data    = /ui2/cl_json=>serialize( data = is_old_data )
      new_data    = /ui2/cl_json=>serialize( data = is_new_data )
      changed_by  = sy-uname
      changed_at  = lv_timestamp " Đã sửa lỗi Type Mismatch ở image_3c8840.png
    ).

    " Thực hiện ghi vào Database
    INSERT zauditlog FROM ls_audit.
  ENDMETHOD.
ENDCLASS.
