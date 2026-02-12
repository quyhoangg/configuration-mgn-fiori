CLASS lhc_catalog DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR catalog RESULT result.

    METHODS validatemoduleid FOR VALIDATE ON SAVE
      IMPORTING keys FOR catalog~validatemoduleid.

    METHODS validatetargettable FOR VALIDATE ON SAVE
      IMPORTING keys FOR catalog~validatetargettable.

ENDCLASS.

CLASS lhc_catalog IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD validatemoduleid.
      READ ENTITIES OF ZI_CONF_CATALOG IN LOCAL MODE
      ENTITY Catalog
        FIELDS ( ModuleId ) WITH CORRESPONDING #( keys )
      RESULT DATA(catalogs).
    LOOP AT catalogs INTO DATA(catalog).
      IF catalog-ModuleId IS INITIAL.
        APPEND VALUE #( %tky = catalog-%tky ) TO failed-catalog.
        APPEND VALUE #( %tky = catalog-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Module ID is required' )
                      ) TO reported-catalog.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatetargettable.
      READ ENTITIES OF ZI_CONF_CATALOG IN LOCAL MODE
      ENTITY Catalog
        FIELDS ( TargetTable ) WITH CORRESPONDING #( keys )
      RESULT DATA(catalogs).
    LOOP AT catalogs INTO DATA(catalog).
      IF catalog-TargetTable IS INITIAL.
        APPEND VALUE #( %tky = catalog-%tky ) TO failed-catalog.
        APPEND VALUE #( %tky = catalog-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Target Table is required' )
                      ) TO reported-catalog.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
