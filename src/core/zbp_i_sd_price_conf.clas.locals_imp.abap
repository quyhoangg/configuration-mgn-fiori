CLASS lhc_priceconf DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS setAdminFields FOR DETERMINE ON MODIFY
      IMPORTING keys FOR PriceConf~setAdminFields.

    METHODS validateMandatory FOR VALIDATE ON SAVE
      IMPORTING keys FOR PriceConf~validateMandatory.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR PriceConf~validateDates.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations
      FOR PriceConf RESULT result.
ENDCLASS.


CLASS lhc_priceconf IMPLEMENTATION.

  METHOD setAdminFields.
    READ ENTITIES OF zi_sd_price_conf IN LOCAL MODE
      ENTITY PriceConf
        FIELDS ( CreatedBy CreatedAt ChangedBy ChangedAt )
        WITH CORRESPONDING #( keys )
      RESULT DATA(entities).

    MODIFY ENTITIES OF zi_sd_price_conf IN LOCAL MODE
      ENTITY PriceConf
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
    READ ENTITIES OF zi_sd_price_conf IN LOCAL MODE
      ENTITY PriceConf
        FIELDS ( EnvId BranchId CustGroup )
        WITH CORRESPONDING #( keys )
      RESULT DATA(entities).

    LOOP AT entities INTO DATA(entity).
      IF entity-EnvId IS INITIAL.
        APPEND VALUE #( %tky = entity-%tky ) TO failed-priceconf.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Environment ID is mandatory' )
                        %element-EnvId = if_abap_behv=>mk-on
        ) TO reported-priceconf.
      ENDIF.

      IF entity-BranchId IS INITIAL.
        APPEND VALUE #( %tky = entity-%tky ) TO failed-priceconf.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Branch ID is mandatory' )
                        %element-BranchId = if_abap_behv=>mk-on
        ) TO reported-priceconf.
      ENDIF.

      IF entity-CustGroup IS INITIAL.
        APPEND VALUE #( %tky = entity-%tky ) TO failed-priceconf.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Customer Group is mandatory' )
                        %element-CustGroup = if_abap_behv=>mk-on
        ) TO reported-priceconf.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD validateDates.
    READ ENTITIES OF zi_sd_price_conf IN LOCAL MODE
      ENTITY PriceConf
        FIELDS ( ValidFrom ValidTo )
        WITH CORRESPONDING #( keys )
      RESULT DATA(entities).

    LOOP AT entities INTO DATA(entity).
      IF entity-ValidFrom IS NOT INITIAL AND entity-ValidTo IS NOT INITIAL.
        IF entity-ValidTo < entity-ValidFrom.
          APPEND VALUE #( %tky = entity-%tky ) TO failed-priceconf.
          APPEND VALUE #( %tky = entity-%tky
                          %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text     = 'Valid To must be after Valid From' )
                          %element-ValidTo = if_abap_behv=>mk-on
          ) TO reported-priceconf.
        ENDIF.
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
