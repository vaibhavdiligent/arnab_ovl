*&---------------------------------------------------------------------*
*& Report  : ZTEST_SF_DRIVER
*& Description: Driver program to call Smart Form ZTEST_SF
*&              (equivalent of Adobe Form ZTEST_SFP)
*&
*& Prerequisites:
*&   Smart Form ZTEST_SF must be created first in transaction SMARTFORMS.
*&   Follow the instructions in ZTEST_SF_CREATION_GUIDE.txt to build it.
*&---------------------------------------------------------------------*
REPORT ztest_sf_driver.

*----------------------------------------------------------------------*
* SELECTION SCREEN
*----------------------------------------------------------------------*
PARAMETERS: p_vbeln TYPE vbeln_va OBLIGATORY.

*----------------------------------------------------------------------*
* DATA DECLARATIONS
*----------------------------------------------------------------------*
DATA: lv_fm_name  TYPE rs38l_fnam,
      ls_control  TYPE ssfctrlop,
      ls_output   TYPE ssfcompop.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

  " Resolve the generated function module name for Smart Form ZTEST_SF
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = 'ZTEST_SF'
    IMPORTING
      fm_name            = lv_fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc <> 0.
    MESSAGE 'Smart Form ZTEST_SF not found. Create it via transaction SMARTFORMS.' TYPE 'E'.
    RETURN.
  ENDIF.

  " Output control: show print preview, no dialog
  ls_control-no_dialog = abap_true.
  ls_control-preview   = abap_true.

  " Output options: spool defaults
  ls_output-tdimmed    = abap_false.
  ls_output-tddest     = 'LP01'.

  " Call the Smart Form's generated function module
  CALL FUNCTION lv_fm_name
    EXPORTING
      control_parameters = ls_control
      output_options     = ls_output
      vbeln              = p_vbeln
    EXCEPTIONS
      formatting_error   = 1
      internal_error     = 2
      send_error         = 3
      user_canceled      = 4
      OTHERS             = 5.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
