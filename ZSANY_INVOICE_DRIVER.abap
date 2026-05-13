*&---------------------------------------------------------------------*
*& Report  ZSANY_INVOICE_DRIVER
*& Description: Driver program for Smart Form ZSANY_INVOICE_SF
*&              (equivalent of Adobe Form ZSANY_INVOICE_INTERFACE)
*&
*& The Adobe Form interface defines 4 IMPORT parameters:
*&   LV_STR   TYPE STRING
*&   I_VBELN  TYPE VBRP-VBELN  (billing document)
*&   I_VGBEL  TYPE VBRP-VGBEL  (reference delivery)
*&   I_AUBEL  TYPE VBRP-AUBEL  (reference sales order)
*&
*& Prerequisites:
*&   Smart Form ZSANY_INVOICE_SF must be created and activated in
*&   SMARTFORMS.  Follow ZSANY_INVOICE_SF_CREATION_GUIDE.txt.
*&---------------------------------------------------------------------*
REPORT zsany_invoice_driver.

*----------------------------------------------------------------------*
* SELECTION SCREEN
*----------------------------------------------------------------------*
PARAMETERS:
  p_vbeln TYPE vbrp-vbeln OBLIGATORY,
  p_vgbel TYPE vbrp-vgbel,
  p_aubel TYPE vbrp-aubel,
  p_str   TYPE string.

*----------------------------------------------------------------------*
* DATA DECLARATIONS
*----------------------------------------------------------------------*
DATA: lv_fm_name TYPE rs38l_fnam,
      ls_control TYPE ssfctrlop,
      ls_output  TYPE ssfcompop.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = 'ZSANY_INVOICE_SF'
    IMPORTING
      fm_name            = lv_fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc <> 0.
    MESSAGE 'Smart Form ZSANY_INVOICE_SF not found or not active.' TYPE 'E'.
    RETURN.
  ENDIF.

  ls_control-no_dialog = abap_true.
  ls_control-preview   = abap_true.
  ls_output-tdimmed    = abap_false.
  ls_output-tddest     = 'LP01'.

  CALL FUNCTION lv_fm_name
    EXPORTING
      control_parameters = ls_control
      output_options     = ls_output
      lv_str             = p_str
      i_vbeln            = p_vbeln
      i_vgbel            = p_vgbel
      i_aubel            = p_aubel
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
