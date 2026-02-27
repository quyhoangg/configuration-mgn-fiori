CLASS lhc_limitconf DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS setAdminFields FOR DETERMINE ON MODIFY
      IMPORTING keys FOR LimitConf~setAdminFields.

    METHODS validateMandatory FOR VALIDATE ON SAVE
      IMPORTING keys FOR LimitConf~validateMandatory.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations
      FOR LimitConf RESULT result.
ENDCLASS.


CLASS lhc_limitconf IMPLEMENTATION.

  METHOD setAdminFields.
    READ ENTITIES OF zi_fi_limit_conf IN LOCAL MODE
      ENTITY LimitConf
        FIELDS ( CreatedBy CreatedAt ChangedBy ChangedAt )
        WITH CORRESPONDING #( keys )
      RESULT DATA(entities).

    MODIFY ENTITIES OF zi_fi_limit_conf IN LOCAL MODE
      ENTITY LimitConf
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
    READ ENTITIES OF zi_fi_limit_conf IN LOCAL MODE
      ENTITY LimitConf
        FIELDS ( EnvId ExpenseType GlAccount AutoApprLim )
        WITH CORRESPONDING #( keys )
      RESULT DATA(entities).

    LOOP AT entities INTO DATA(entity).
      IF entity-EnvId IS INITIAL.
        APPEND VALUE #( %tky = entity-%tky ) TO failed-limitconf.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Environment ID is mandatory' )
                        %element-EnvId = if_abap_behv=>mk-on
        ) TO reported-limitconf.
      ENDIF.

      IF entity-ExpenseType IS INITIAL.
        APPEND VALUE #( %tky = entity-%tky ) TO failed-limitconf.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Expense Type is mandatory' )
                        %element-ExpenseType = if_abap_behv=>mk-on
        ) TO reported-limitconf.
      ENDIF.

      IF entity-GlAccount IS INITIAL.
        APPEND VALUE #( %tky = entity-%tky ) TO failed-limitconf.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'GL Account is mandatory' )
                        %element-GlAccount = if_abap_behv=>mk-on
        ) TO reported-limitconf.
      ENDIF.

      IF entity-AutoApprLim IS INITIAL OR entity-AutoApprLim <= 0.
        APPEND VALUE #( %tky = entity-%tky ) TO failed-limitconf.
        APPEND VALUE #( %tky = entity-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Auto Approval Limit must be > 0' )
                        %element-AutoApprLim = if_abap_behv=>mk-on
        ) TO reported-limitconf.
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
