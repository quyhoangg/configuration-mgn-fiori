CLASS lhc_Req DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      gc_st_draft     TYPE zde_requ_status VALUE 'DRAFT',
      gc_st_submitted TYPE zde_requ_status VALUE 'SUBMITTED',
      gc_st_approved  TYPE zde_requ_status VALUE 'APPROVED',
      gc_st_rejected  TYPE zde_requ_status VALUE 'REJECTED',
      gc_st_active    TYPE zde_requ_status VALUE 'ACTIVE'.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Req RESULT result.

    METHODS approve FOR MODIFY
      IMPORTING keys FOR ACTION Req~approve RESULT result.

    METHODS reject FOR MODIFY
      IMPORTING keys FOR ACTION Req~reject RESULT result.

    METHODS submit FOR MODIFY
      IMPORTING keys FOR ACTION Req~submit RESULT result.

    METHODS set_default_and_admin_fields FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Req~set_default_and_admin_fields.

    METHODS validate_before_save FOR VALIDATE ON SAVE
      IMPORTING keys FOR Req~validate_before_save.

ENDCLASS.

CLASS lhc_Req IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD approve.

    DATA lv_now TYPE timestampl.
    GET TIME STAMP FIELD lv_now.

    READ ENTITIES OF zir_conf_req_h IN LOCAL MODE
      ENTITY Req
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(reqs).

    LOOP AT reqs ASSIGNING FIELD-SYMBOL(<r>).

      IF <r>-Status <> gc_st_submitted.
        APPEND VALUE #(
          %tky = <r>-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |Approve allowed only when status = { gc_st_submitted }| )
        ) TO reported-Req.
        APPEND VALUE #( %tky = <r>-%tky ) TO failed-Req.
        CONTINUE.
      ENDIF.

      "APPROVED
      MODIFY ENTITIES OF zir_conf_req_h IN LOCAL MODE
        ENTITY Req UPDATE FIELDS ( Status ApprovedBy ApprovedAt )
        WITH VALUE #( ( %tky = <r>-%tky
                        Status     = gc_st_approved
                        ApprovedBy = sy-uname
                        ApprovedAt = lv_now ) ).

      "TODO: apply config + audit log

      "ACTIVE
      MODIFY ENTITIES OF zir_conf_req_h IN LOCAL MODE
        ENTITY Req UPDATE FIELDS ( Status )
        WITH VALUE #( ( %tky = <r>-%tky Status = gc_st_active ) ).

    ENDLOOP.

    result = VALUE #( FOR r IN reqs ( %tky = r-%tky ) ).

  ENDMETHOD.

  METHOD reject.

    DATA lv_now TYPE timestampl.
    GET TIME STAMP FIELD lv_now.

    READ ENTITIES OF zir_conf_req_h IN LOCAL MODE
      ENTITY Req
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(reqs).

    LOOP AT reqs ASSIGNING FIELD-SYMBOL(<r>).

      IF <r>-Status <> gc_st_submitted.
        APPEND VALUE #(
          %tky = <r>-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |Reject allowed only when status = { gc_st_submitted }| )
        ) TO reported-Req.
        APPEND VALUE #( %tky = <r>-%tky ) TO failed-Req.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zir_conf_req_h IN LOCAL MODE
        ENTITY Req UPDATE FIELDS ( Status RejectedBy RejectedAt )
        WITH VALUE #(
          ( %tky = <r>-%tky
            Status     = gc_st_rejected
            RejectedBy = sy-uname
            RejectedAt = lv_now ) ).

    ENDLOOP.

    result = VALUE #( FOR r IN reqs ( %tky = r-%tky ) ).

  ENDMETHOD.

  METHOD submit.

    READ ENTITIES OF zir_conf_req_h IN LOCAL MODE
    ENTITY Req
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(reqs).

    LOOP AT reqs ASSIGNING FIELD-SYMBOL(<r>).

      IF <r>-Status <> gc_st_draft.
        CONTINUE.
      ENDIF.

      "Check items exist
      READ ENTITIES OF zir_conf_req_h IN LOCAL MODE
        ENTITY Req BY \_Items
        ALL FIELDS WITH VALUE #( ( %tky = <r>-%tky ) )
        RESULT DATA(items).

      IF items IS INITIAL.
        APPEND VALUE #(
          %tky = <r>-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Request must contain at least one item before submit' )
        ) TO reported-Req.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zir_conf_req_h IN LOCAL MODE
        ENTITY Req UPDATE FIELDS ( Status )
        WITH VALUE #( ( %tky = <r>-%tky Status = gc_st_submitted ) ).

    ENDLOOP.

    result = VALUE #( FOR r IN reqs ( %tky = r-%tky ) ).

  ENDMETHOD.

  METHOD set_default_and_admin_fields.

    DATA lv_now TYPE timestampl.
    GET TIME STAMP FIELD lv_now.

    "Read current instances
    READ ENTITIES OF zir_conf_req_h IN LOCAL MODE
      ENTITY Req
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(reqs).

    MODIFY ENTITIES OF zir_conf_req_h IN LOCAL MODE
      ENTITY Req
      UPDATE FIELDS ( Status CreatedBy CreatedAt ChangedBy ChangedAt )
      WITH VALUE #(
        FOR r IN reqs
        ( %tky      = r-%tky
          Status    = COND #( WHEN r-Status    IS INITIAL THEN gc_st_draft ELSE r-Status )
          CreatedBy = COND #( WHEN r-CreatedBy IS INITIAL THEN sy-uname    ELSE r-CreatedBy )
          CreatedAt = COND #( WHEN r-CreatedAt IS INITIAL THEN lv_now      ELSE r-CreatedAt )
          ChangedBy = sy-uname
          ChangedAt = lv_now ) ).

  ENDMETHOD.

  METHOD validate_before_save.

    READ ENTITIES OF zir_conf_req_h IN LOCAL MODE
      ENTITY Req
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(reqs).

    "1) Header rule: ACTIVE/REJECTED
    LOOP AT reqs ASSIGNING FIELD-SYMBOL(<r>).

      IF <r>-Status = gc_st_active OR <r>-Status = gc_st_rejected.

        APPEND VALUE #(
          %tky = <r>-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Completed request cannot be changed' )
        ) TO reported-Req.

        APPEND VALUE #( %tky = <r>-%tky ) TO failed-Req.

      ENDIF.

    ENDLOOP.

    "2) Item rule: mandantory ConfId/TargetEnvId/Action
    READ ENTITIES OF zir_conf_req_h IN LOCAL MODE
      ENTITY Req BY \_Items
      ALL FIELDS WITH VALUE #( FOR r IN reqs ( %tky = r-%tky ) )
      RESULT DATA(items).

    DATA(lv_item_error) = abap_false.

    LOOP AT items ASSIGNING FIELD-SYMBOL(<i>).
      IF <i>-ConfId IS INITIAL OR <i>-TargetEnvId IS INITIAL OR <i>-Action IS INITIAL.
        lv_item_error = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_item_error = abap_true.

      "Report errors on header saved
      LOOP AT reqs ASSIGNING FIELD-SYMBOL(<rh>).
        APPEND VALUE #(
          %tky = <rh>-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Item validation failed: ConfId/TargetEnvId/Action are required' )
        ) TO reported-Req.

        APPEND VALUE #( %tky = <rh>-%tky ) TO failed-Req.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_Item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validate_item FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~validate_item.

ENDCLASS.

CLASS lhc_Item IMPLEMENTATION.

  METHOD validate_item.
    "No logic here - validated in header validation
  ENDMETHOD.

ENDCLASS.
