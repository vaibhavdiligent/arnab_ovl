*&---------------------------------------------------------------------*
*& Report  : ZTEST_SF_UPLOAD
*& Description: Programmatically creates Smart Form ZTEST_SF
*&              Equivalent of Adobe Form ZTEST_SFP
*&
*& HOW IT WORKS
*& ─────────────────────────────────────────────────────────────────────
*& Smart Forms stores its form definition as a set of function-builder
*& objects.  The SMARTFORMS transaction writes these objects via the
*& internal function group SSF.  This program calls the same internal
*& infrastructure using three phases:
*&
*&   Phase 1 – Build in-memory structures (interface, global defs,
*&              pages, windows, text/table nodes) using the confirmed
*&              shared DDIC types SFPIOPAR / SFPGDATA / FPCLINE.
*&
*&   Phase 2 – Persist the form by calling the Smart Forms internal
*&              save FM (SSF_SMART_FORM_TRANSLATE).  If the name
*&              differs in your release find it via:
*&                SE37 → search mask  SSF_SMART_FORM*
*&
*&   Phase 3 – Activate / generate the ABAP function module from the
*&              form definition (SSF_GENERATION).
*&
*& PREREQUISITES
*& ─────────────────────────────────────────────────────────────────────
*&   • Developer key (S_DEVELOP object S_DEVELOP ACTVT 01/02)
*&   • Smart Forms installed in the system
*&   • Run in a package where you are authorised to create objects
*&     (or leave package blank for $TMP / local development)
*&
*& ADJUSTING FM NAMES FOR YOUR RELEASE
*& ─────────────────────────────────────────────────────────────────────
*&   SE37 → wildcard search  SSF*  to list all available FMs.
*&   The save FM is  SSF_SMART_FORM_TRANSLATE  in most ECC / S/4 releases.
*&   The generate FM is  SSF_GENERATION.
*&   If these do not exist, check CL_SSF_FB_SMART_FORM methods in SE24.
*&---------------------------------------------------------------------*
REPORT ztest_sf_upload.

*----------------------------------------------------------------------*
* CONSTANTS
*----------------------------------------------------------------------*
CONSTANTS:
  c_formname  TYPE char30  VALUE 'ZTEST_SF',
  c_descript  TYPE char60  VALUE 'Table Demo Smart Form',
  c_langu     TYPE spras   VALUE 'E'.

*----------------------------------------------------------------------*
* DATA DECLARATIONS
*----------------------------------------------------------------------*
" ── Confirmed shared FP / Smart-Forms DDIC types ──────────────────────
DATA:
  ls_import_par   TYPE sfpiopar,              " one I/O parameter
  lt_import_pars  TYPE STANDARD TABLE OF sfpiopar,   " import params list

  ls_global_data  TYPE sfpgdata,              " one global variable
  lt_global_data  TYPE STANDARD TABLE OF sfpgdata,   " global data list

  ls_codeline     TYPE fpcline,               " one ABAP code line
  lt_types_code   TYPE STANDARD TABLE OF fpcline,    " TYPE definitions
  lt_init_code    TYPE STANDARD TABLE OF fpcline.    " INITIALIZATION code

" ── Result / status ───────────────────────────────────────────────────
DATA:
  lv_fm_name   TYPE rs38l_fnam,
  lv_rc        TYPE sy-subrc.

*----------------------------------------------------------------------*
* SELECTION SCREEN
*----------------------------------------------------------------------*
PARAMETERS:
  p_pkg  TYPE devclass DEFAULT '$TMP',          " package / $TMP
  p_del  AS CHECKBOX DEFAULT ' '.               " delete existing first

*======================================================================*
* START-OF-SELECTION
*======================================================================*
START-OF-SELECTION.

  PERFORM f_check_existing.
  PERFORM f_build_interface.
  PERFORM f_build_global_defs.
  PERFORM f_create_form_structure.
  PERFORM f_activate_form.
  PERFORM f_display_result.

*----------------------------------------------------------------------*
* FORM: Check / delete existing form
*----------------------------------------------------------------------*
FORM f_check_existing.

  DATA lv_exists TYPE abap_bool.

  " Try to resolve the FM – if it works, the form already exists
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = c_formname
    IMPORTING
      fm_name            = lv_fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc = 0.
    lv_exists = abap_true.
    WRITE: / 'Form', c_formname, 'already exists (FM:', lv_fm_name, ')'.
    IF p_del = abap_true.
      WRITE: / '  → Delete flag set: will overwrite existing form.'.
    ELSE.
      WRITE: / '  → Delete flag not set: SKIPPING creation. Tick "Del" to overwrite.'.
      RETURN.
    ENDIF.
  ELSE.
    WRITE: / 'Form', c_formname, 'does not exist – will create fresh.'.
  ENDIF.

ENDFORM.

*----------------------------------------------------------------------*
* FORM: Build interface parameters
*----------------------------------------------------------------------*
FORM f_build_interface.

  " ── Import parameter: VBELN TYPE VBELN ────────────────────────────
  CLEAR ls_import_par.
  ls_import_par-name     = 'VBELN'.
  ls_import_par-typing   = 'TYPE'.
  ls_import_par-typename = 'VBELN'.
  ls_import_par-optional = abap_false.
  ls_import_par-byvalue  = abap_false.
  APPEND ls_import_par TO lt_import_pars.

  WRITE: / 'Interface built: IMPORT VBELN TYPE VBELN'.

ENDFORM.

*----------------------------------------------------------------------*
* FORM: Build global definitions (types, data, initialization)
*----------------------------------------------------------------------*
FORM f_build_global_defs.

  " ── TYPE definitions ───────────────────────────────────────────────
  CLEAR ls_codeline.

  ls_codeline-line = 'TYPES: BEGIN OF ty_vbap,'.                     APPEND ls_codeline TO lt_types_code.
  ls_codeline-line = '         vbeln  TYPE vbeln_va,'.                APPEND ls_codeline TO lt_types_code.
  ls_codeline-line = '         posnr  TYPE posnr_va,'.                APPEND ls_codeline TO lt_types_code.
  ls_codeline-line = '         matnr  TYPE matnr,'.                   APPEND ls_codeline TO lt_types_code.
  ls_codeline-line = '         matwa  TYPE matwa,'.                   APPEND ls_codeline TO lt_types_code.
  ls_codeline-line = '       END OF ty_vbap.'.                        APPEND ls_codeline TO lt_types_code.
  CLEAR ls_codeline.
  ls_codeline-line = 'TYPES: ty_vbap1 TYPE TABLE OF ty_vbap.'.        APPEND ls_codeline TO lt_types_code.

  " ── Global variable declarations ───────────────────────────────────
  " Internal table IT_VBAP
  CLEAR ls_global_data.
  ls_global_data-name     = 'IT_VBAP'.
  ls_global_data-typing   = 'TYPE'.
  ls_global_data-typename = 'TY_VBAP1'.
  APPEND ls_global_data TO lt_global_data.

  " Work area WA_VBAP (used in table-node loop body)
  CLEAR ls_global_data.
  ls_global_data-name     = 'WA_VBAP'.
  ls_global_data-typing   = 'TYPE'.
  ls_global_data-typename = 'TY_VBAP'.
  APPEND ls_global_data TO lt_global_data.

  " ── Initialization code ────────────────────────────────────────────
  CLEAR ls_codeline.
  ls_codeline-line = 'SELECT vbeln posnr matnr matwa'. APPEND ls_codeline TO lt_init_code.
  ls_codeline-line = '  FROM vbap'.                    APPEND ls_codeline TO lt_init_code.
  ls_codeline-line = '  INTO TABLE it_vbap'.           APPEND ls_codeline TO lt_init_code.
  ls_codeline-line = '  WHERE vbeln = vbeln.'.         APPEND ls_codeline TO lt_init_code.
  ls_codeline-line = 'IF sy-subrc = 0.'.               APPEND ls_codeline TO lt_init_code.
  ls_codeline-line = 'ENDIF.'.                         APPEND ls_codeline TO lt_init_code.

  WRITE: / 'Global definitions built: TY_VBAP, TY_VBAP1, IT_VBAP, WA_VBAP + init code'.

ENDFORM.

*----------------------------------------------------------------------*
* FORM: Create form structure via Smart Forms internal API
*
*  The Smart Forms builder API is internal/unreleased by SAP.
*  The call below uses SSF_SMART_FORM_TRANSLATE which is the FM
*  the SMARTFORMS transaction itself calls when saving a form.
*
*  If your system does not have SSF_SMART_FORM_TRANSLATE:
*    1. Run SE37 and search for  SSF_SMART_FORM*
*    2. Inspect the parameters of what you find
*    3. Adapt the EXPORTING / TABLES parameters below accordingly
*
*  Alternative class-based path (newer releases):
*    DATA lo_form TYPE REF TO cl_ssf_fb_smart_form.
*    CALL METHOD cl_ssf_fb_smart_form=>get_instance
*      EXPORTING iv_formname = c_formname
*      RECEIVING ro_form     = lo_form.
*    " then use lo_form->* methods to add nodes, save, etc.
*----------------------------------------------------------------------*
FORM f_create_form_structure.

  " ── Form header / attributes ───────────────────────────────────────
  DATA:
    ls_formattr  TYPE sfscreen,       " Form attributes (SMARTFORMS header)
    ls_interface TYPE sfpinterf,      " Interface header
    ls_globdef   TYPE sfpglobdef.     " Global definitions header

  ls_formattr-formname  = c_formname.
  ls_formattr-descript  = c_descript.
  ls_formattr-langu     = c_langu.
  ls_formattr-devclass  = p_pkg.

  " ── Node-tree: Page, Window, Text node, Table node ─────────────────
  " The node tree is built using Smart Forms node structures.
  " Smart Forms nodes are stored as instances of CL_SSF_FB_* classes.
  " This program builds the equivalent data structures that the
  " SMARTFORMS 'Save' action produces in the database.

  DATA: lt_nodes TYPE ssf_t_nodes.     " Smart Forms node table

  DATA: ls_node  TYPE ssf_node.        " One Smart Forms node

  " ── PAGE1 ──────────────────────────────────────────────────────────
  CLEAR ls_node.
  ls_node-nodetype   = 'PAGE'.
  ls_node-name       = 'PAGE1'.
  ls_node-descript   = 'Page 1'.
  ls_node-active     = 'X'.
  ls_node-papformat  = 'LETTER'.       " 8.5 × 11 in (same as Adobe Form)
  ls_node-paplandsc  = ' '.            " Portrait
  ls_node-nexpage    = ''.             " No next page
  APPEND ls_node TO lt_nodes.

  " ── MAIN window ────────────────────────────────────────────────────
  CLEAR ls_node.
  ls_node-nodetype   = 'WINDOW'.
  ls_node-name       = 'MAIN'.
  ls_node-descript   = 'Main output window'.
  ls_node-active     = 'X'.
  ls_node-parent     = 'PAGE1'.
  ls_node-wintype    = 'MAIN'.         " MAIN window type
  ls_node-left       = '6.35'.         " mm – mirrors Adobe Form content area
  ls_node-top        = '6.35'.
  ls_node-width      = '203.2'.        " 8 in
  ls_node-height     = '266.7'.        " 10.5 in
  APPEND ls_node TO lt_nodes.

  " ── TEXT node: Sales Document header ───────────────────────────────
  " Mirrors Adobe Form field VBELN (caption 'Sales Document', y=85.725mm)
  CLEAR ls_node.
  ls_node-nodetype   = 'TEXT'.
  ls_node-name       = 'TEXT_VBELN'.
  ls_node-descript   = 'Sales Document header'.
  ls_node-active     = 'X'.
  ls_node-parent     = 'MAIN'.
  ls_node-textvalue  = 'Sales Document: &VBELN&'.
  ls_node-paraformat = 'AS1'.          " Bold heading paragraph
  APPEND ls_node TO lt_nodes.

  " ── TABLE node: line items ──────────────────────────────────────────
  " Mirrors Adobe Form subform BodyRow (bound to IT_VBAP → DATA[*])
  CLEAR ls_node.
  ls_node-nodetype   = 'TABLE'.
  ls_node-name       = 'TABLE_ITEMS'.
  ls_node-descript   = 'Sales Order Line Items'.
  ls_node-active     = 'X'.
  ls_node-parent     = 'MAIN'.
  ls_node-itab       = 'IT_VBAP'.     " Internal table to loop over
  ls_node-warea      = 'WA_VBAP'.     " Work area
  APPEND ls_node TO lt_nodes.

  " ── TABLE HEADER row ───────────────────────────────────────────────
  CLEAR ls_node.
  ls_node-nodetype   = 'TABLEHEADER'.
  ls_node-name       = 'TBL_HDR'.
  ls_node-active     = 'X'.
  ls_node-parent     = 'TABLE_ITEMS'.
  APPEND ls_node TO lt_nodes.

  " ── TABLE HEADER cells (column captions) ───────────────────────────
  " Column widths: 62 mm each – identical to Adobe Form field widths
  DATA: lt_columns TYPE ssf_t_columns,
        ls_column  TYPE ssf_column.

  CLEAR ls_column. ls_column-colname = 'COL_VBELN'. ls_column-colwidth = '62'. ls_column-coldesc = 'Sales Doc'.        APPEND ls_column TO lt_columns.
  CLEAR ls_column. ls_column-colname = 'COL_POSNR'. ls_column-colwidth = '62'. ls_column-coldesc = 'Item'.             APPEND ls_column TO lt_columns.
  CLEAR ls_column. ls_column-colname = 'COL_MATNR'. ls_column-colwidth = '62'. ls_column-coldesc = 'Material Number'.  APPEND ls_column TO lt_columns.
  CLEAR ls_column. ls_column-colname = 'COL_MATWA'. ls_column-colwidth = '62'. ls_column-coldesc = 'Mat. Entered'.     APPEND ls_column TO lt_columns.

  " ── TABLE BODY row (data cells, one per IT_VBAP entry) ─────────────
  " Field values use Smart Forms field syntax  &WA_VBAP-<field>&
  " maxChars match the Adobe Form: VBELN=10, POSNR=6, MATNR/MATWA=18
  DATA: lt_cells   TYPE ssf_t_cells,
        ls_cell    TYPE ssf_cell.

  CLEAR ls_cell. ls_cell-colname = 'COL_VBELN'. ls_cell-fieldref = 'WA_VBAP-VBELN'. ls_cell-maxchars = 10. APPEND ls_cell TO lt_cells.
  CLEAR ls_cell. ls_cell-colname = 'COL_POSNR'. ls_cell-fieldref = 'WA_VBAP-POSNR'. ls_cell-maxchars = 6.  APPEND ls_cell TO lt_cells.
  CLEAR ls_cell. ls_cell-colname = 'COL_MATNR'. ls_cell-fieldref = 'WA_VBAP-MATNR'. ls_cell-maxchars = 18. APPEND ls_cell TO lt_cells.
  CLEAR ls_cell. ls_cell-colname = 'COL_MATWA'. ls_cell-fieldref = 'WA_VBAP-MATWA'. ls_cell-maxchars = 18. APPEND ls_cell TO lt_cells.

  " ── Save the form using Smart Forms internal FM ────────────────────
  "
  " SSF_SMART_FORM_TRANSLATE is the internal FM called by SMARTFORMS
  " when the user clicks Save.  It accepts the form tree and persists
  " it to the Smart Forms repository tables.
  "
  " If this FM does not exist in your system:
  "   SE37 → search  SSF_SMART*  to find the equivalent in your release.
  "
  CALL FUNCTION 'SSF_SMART_FORM_TRANSLATE'
    EXPORTING
      form_attr        = ls_formattr
    TABLES
      import_pars      = lt_import_pars
      global_data      = lt_global_data
      types_code       = lt_types_code
      init_code        = lt_init_code
      form_nodes       = lt_nodes
      form_columns     = lt_columns
      form_cells       = lt_cells
    EXCEPTIONS
      form_not_found   = 1
      form_exists      = 2
      invalid_data     = 3
      OTHERS           = 4.

  CASE sy-subrc.
    WHEN 0.
      WRITE: / 'Form structure saved successfully.'.
    WHEN 2.
      WRITE: / 'Form already exists (delete first or tick "Del" checkbox).'.
    WHEN OTHERS.
      WRITE: / '[ERROR] SSF_SMART_FORM_TRANSLATE returned rc =', sy-subrc.
      WRITE: / '        Check SE37 for the correct FM in your SAP release.'.
      WRITE: / '        Alternative: create the form manually using'.
      WRITE: / '        ZTEST_SF_CREATION_GUIDE.txt'.
  ENDCASE.

ENDFORM.

*----------------------------------------------------------------------*
* FORM: Activate / generate the Smart Form function module
*----------------------------------------------------------------------*
FORM f_activate_form.

  WRITE: / 'Activating form', c_formname, '...'.

  " SSF_GENERATION compiles the form definition and produces the
  " ABAP function module that is later called at print time.
  CALL FUNCTION 'SSF_GENERATION'
    EXPORTING
      formname         = c_formname
    IMPORTING
      fm_name          = lv_fm_name
    EXCEPTIONS
      form_not_found   = 1
      error_in_form    = 2
      OTHERS           = 3.

  CASE sy-subrc.
    WHEN 0.
      WRITE: / 'Activation successful. Generated FM:', lv_fm_name.
    WHEN 1.
      WRITE: / '[ERROR] Form', c_formname, 'not found for activation.'.
      WRITE: / '        Ensure the save step (f_create_form_structure) ran without errors.'.
    WHEN 2.
      WRITE: / '[ERROR] The form contains errors. Fix them in transaction SMARTFORMS'.
      WRITE: / '        then re-run this program or activate manually (Ctrl+F3).'.
    WHEN OTHERS.
      WRITE: / '[ERROR] SSF_GENERATION returned rc =', sy-subrc.
  ENDCASE.

ENDFORM.

*----------------------------------------------------------------------*
* FORM: Display result summary
*----------------------------------------------------------------------*
FORM f_display_result.

  ULINE.
  WRITE: / 'SUMMARY'.
  ULINE.
  WRITE: / 'Form name  :', c_formname.
  WRITE: / 'Description:', c_descript.
  WRITE: / 'Package    :', p_pkg.

  IF lv_fm_name IS NOT INITIAL.
    WRITE: / 'Generated FM:', lv_fm_name.
    WRITE: / ''.
    WRITE: / 'To test the form, run report ZTEST_SF_DRIVER'.
    WRITE: / 'and enter a valid Sales Order number (VBELN).'.
  ELSE.
    WRITE: / ''.
    WRITE: / 'Form was NOT activated. Check errors above.'.
    WRITE: / 'You can also complete the form manually in'.
    WRITE: / 'transaction SMARTFORMS and activate with Ctrl+F3.'.
    WRITE: / 'See ZTEST_SF_CREATION_GUIDE.txt for step-by-step help.'.
  ENDIF.

ENDFORM.
