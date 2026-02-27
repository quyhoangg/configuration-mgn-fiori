CLASS zcl_gsp26_rule_status DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CONSTANTS: cv_draft     TYPE string VALUE 'DRAFT',
               cv_submitted TYPE string VALUE 'SUBMITTED',
               cv_approved  TYPE string VALUE 'APPROVED',
               cv_rejected  TYPE string VALUE 'REJECTED'.

    CLASS-METHODS is_transition_valid
      IMPORTING iv_req_id TYPE zconfreqh-req_id
                iv_next_status TYPE string
      RETURNING VALUE(rv_allowed) TYPE abap_bool.
ENDCLASS.

CLASS zcl_gsp26_rule_status IMPLEMENTATION.
  METHOD is_transition_valid.
    DATA lv_current_status TYPE string.
    rv_allowed = abap_false.

    SELECT SINGLE status FROM zconfreqh
      WHERE req_id = @iv_req_id
      INTO @lv_current_status.

    CASE lv_current_status.
      WHEN cv_draft.
        IF iv_next_status = cv_submitted. rv_allowed = abap_true. ENDIF.
      WHEN cv_submitted.
        IF iv_next_status = cv_approved OR iv_next_status = cv_rejected.
          rv_allowed = abap_true.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
