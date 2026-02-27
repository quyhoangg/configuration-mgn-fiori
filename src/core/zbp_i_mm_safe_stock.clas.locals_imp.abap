CLASS lhc_safestock DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS setAdminFields FOR DETERMINE ON MODIFY
      IMPORTING keys FOR SafeStock~setAdminFields.

    METHODS validateMandatory FOR VALIDATE ON SAVE
      IMPORTING keys FOR SafeStock~validateMandatory.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations
      FOR SafeStock RESULT result.
ENDCLASS.


CLASS lhc_safestock IMPLEMENTATION.

  METHOD setAdminFields.
    READ ENTITIES OF zi_mm_safe_stock IN LOCAL MODE
      ENTITY SafeStock
        FIELDS ( CreatedBy CreatedAt ChangedBy ChangedAt )
        WITH CORRESPONDING #( keys )
      RESULT DATA(entities).

    MODIFY ENTITIES OF zi_mm_safe_stock IN LOCAL MODE
      ENTITY SafeStock
        UPDATE FIELDS ( CreatedBy CreatedAt ChangedBy ChangedAt )
        WITH VALUE #( FOR entity IN entities
          ( %tky      = entity-%tky
            CreatedBy = COND #( WHEN entity-CreatedBy IS INITIAL
                                THEN sy-uname
                                ELSE entity-CreatedBy )
            CreatedAt = COND #( WHEN entity-CreatedAt IS INITIAL
                                THEN cl_abap_context_info=>get_system_time( )
                                ELSE entity-CreatedAt )
            ChangedBy = sy-uname
            ChangedAt = cl_abap_context_info=>get_system_time( )
          ) )
      REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).
  ENDMETHOD.


  METHOD validateMandatory.
    READ ENTITIES OF zi_mm_safe_stock IN LOCAL MODE
      ENTITY SafeStock
        FIELDS ( EnvId PlantId MatGroup MinQty )
        WITH CORRESPONDING #( keys )
      RESULT DATA(entities).

    LOOP AT entities INTO DATA(entity).
      IF entity-EnvId IS INITIAL.
        APPEND VALUE #( %tky = entity-%tky ) TO failed-safestock.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Environment ID is mandatory' )
                        %element-EnvId = if_abap_behv=>mk-on
        ) TO reported-safestock.
      ENDIF.

      IF entity-PlantId IS INITIAL.
        APPEND VALUE #( %tky = entity-%tky ) TO failed-safestock.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Plant ID is mandatory' )
                        %element-PlantId = if_abap_behv=>mk-on
        ) TO reported-safestock.
      ENDIF.

      IF entity-MatGroup IS INITIAL.
        APPEND VALUE #( %tky = entity-%tky ) TO failed-safestock.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Material Group is mandatory' )
                        %element-MatGroup = if_abap_behv=>mk-on
        ) TO reported-safestock.
      ENDIF.

      IF entity-MinQty IS INITIAL OR entity-MinQty <= 0.
        APPEND VALUE #( %tky = entity-%tky ) TO failed-safestock.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Minimum Quantity must be greater than 0' )
                        %element-MinQty = if_abap_behv=>mk-on
        ) TO reported-safestock.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_instance_authorizations.
    result = VALUE #( FOR key IN keys
      ( %tky    = key-%tky
        %update = if_abap_behv=>auth-allowed
        %delete = if_abap_behv=>auth-allowed
      ) ).
  ENDMETHOD.

ENDCLASS.
