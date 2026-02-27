CLASS zcl_gsp26_rule_validator DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    " Kiểm tra CONF_ID có tồn tại trong danh mục không
    CLASS-METHODS check_catalog_existence
      IMPORTING iv_conf_id TYPE zconfcatalog-conf_id
      RETURNING VALUE(rv_exists) TYPE abap_bool.
ENDCLASS.

CLASS zcl_gsp26_rule_validator IMPLEMENTATION.
  METHOD check_catalog_existence.
    SELECT SINGLE @abap_true
      FROM zconfcatalog
      WHERE conf_id = @iv_conf_id
      INTO @rv_exists.
  ENDMETHOD.
ENDCLASS.
