*&---------------------------------------------------------------------*
*& Report zseed_confcatalog
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zseed_confcatalog.

DATA: lt_catalog TYPE STANDARD TABLE OF zconfcatalog,
      lv_ts      TYPE timestampl.

GET TIME STAMP FIELD lv_ts.

"Skip if data had already
SELECT SINGLE @abap_true FROM zconfcatalog INTO @DATA(lv_exists).
IF sy-subrc = 0.
  WRITE: / 'ZCONFCATALOG already has data. Skip seeding.'.
  RETURN.
ENDIF.

TRY.
    APPEND VALUE zconfcatalog(
      client      = sy-mandt
      conf_id     = cl_system_uuid=>create_uuid_x16_static( )
      module_id   = 'MM'
      conf_name   = 'Warehouse Route'
      conf_type   = 'TABLE'
      target_cds  = 'ZI_MM_ROUTE_CONF'
      description = 'Maintain warehouse routes'
      is_active   = abap_true
      created_by  = sy-uname
      created_at  = lv_ts
    ) TO lt_catalog.

    APPEND VALUE zconfcatalog(
      client      = sy-mandt
      conf_id     = cl_system_uuid=>create_uuid_x16_static( )
      module_id   = 'MM'
      conf_name   = 'Safety Stock'
      conf_type   = 'TABLE'
      target_cds  = 'ZI_MM_SAFE_STOCK'
      description = 'Maintain safety stock'
      is_active   = abap_true
      created_by  = sy-uname
      created_at  = lv_ts
    ) TO lt_catalog.

    APPEND VALUE zconfcatalog(
      client      = sy-mandt
      conf_id     = cl_system_uuid=>create_uuid_x16_static( )
      module_id   = 'FI'
      conf_name   = 'Expense Limit'
      conf_type   = 'TABLE'
      target_cds  = 'ZI_FI_LIMIT_CONF'
      description = 'Maintain expense limit'
      is_active   = abap_true
      created_by  = sy-uname
      created_at  = lv_ts
    ) TO lt_catalog.

    APPEND VALUE zconfcatalog(
      client      = sy-mandt
      conf_id     = cl_system_uuid=>create_uuid_x16_static( )
      module_id   = 'SD'
      conf_name   = 'Price Config'
      conf_type   = 'TABLE'
      target_cds  = 'ZI_SD_PRICE_CONF'
      description = 'Maintain price rules'
      is_active   = abap_true
      created_by  = sy-uname
      created_at  = lv_ts
    ) TO lt_catalog.

  CATCH cx_uuid_error INTO DATA(lx_uuid).
    WRITE: / |UUID generation failed: { lx_uuid->get_text( ) }|.
    RETURN.
ENDTRY.

INSERT zconfcatalog FROM TABLE @lt_catalog.
COMMIT WORK.

WRITE: / |Seed done. Inserted { sy-dbcnt } row(s) into ZCONFCATALOG.|.
