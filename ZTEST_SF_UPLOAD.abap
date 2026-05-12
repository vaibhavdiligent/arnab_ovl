*&---------------------------------------------------------------------*
*& Report  : ZTEST_SF_UPLOAD
*& Description: Uploads a Smart Form from an XML file into the system
*&              using the same internal API that abapGit uses.
*&
*& BASED ON  : abapGit's ZCL_ABAPGIT_OBJECT_SSFO->deserialize method
*&             https://github.com/abapGit/abapGit/blob/main/src/objects/
*&                     zcl_abapgit_object_ssfo.clas.abap
*&
*& WORKS BY  : Calling SAP's documented class CL_SSF_FB_SMART_FORM
*&             methods enqueue → xml_upload → store → dequeue.
*&             These methods are present in every ECC / S/4 release
*&             that has Smart Forms (the SMARTFORMS transaction uses
*&             the same class internally).
*&
*& USAGE     :
*&   1. Save the Smart Form XML file on your front-end PC, e.g.
*&        C:\temp\ZTEST_SF.ssfo.xml
*&   2. Run this report (SE38 → ZTEST_SF_UPLOAD).
*&   3. Enter the file path, target package, and master language.
*&   4. Hit Execute (F8).  The form is created/overwritten and saved
*&      as active.  Then run report ZTEST_SF_DRIVER to test it.
*&
*& INPUT XML FORMAT
*&   The XML must be the SAP Smart Forms internal format
*&   (root element <sf:SMARTFORM xmlns:sf="urn:sap-com:SmartForms:..."/>
*&   optionally wrapped in <abapGit>...</abapGit>).
*&   See zbox_label.ssfo.xml in this repo as a working reference.
*&---------------------------------------------------------------------*
REPORT ztest_sf_upload.

*----------------------------------------------------------------------*
* SELECTION SCREEN
*----------------------------------------------------------------------*
PARAMETERS:
  p_file TYPE string LOWER CASE OBLIGATORY
                       DEFAULT 'C:\temp\ZTEST_SF.ssfo.xml',
  p_pkg  TYPE devclass DEFAULT '$TMP',
  p_lang TYPE spras    DEFAULT 'E'.

*----------------------------------------------------------------------*
* DATA DECLARATIONS
*----------------------------------------------------------------------*
DATA:
  lo_sf       TYPE REF TO cl_ssf_fb_smart_form,
  lo_res      TYPE REF TO cl_ssf_fb_smart_form,
  lx_error    TYPE REF TO cx_ssf_fb,
  lv_text     TYPE string,
  lv_formname TYPE tdsfname,
  lv_xstring  TYPE xstring,
  lt_xdata    TYPE TABLE OF x255,
  lv_length   TYPE i,
  lv_filename TYPE string.

DATA:
  lo_streamfactory TYPE REF TO if_ixml_stream_factory,
  lo_istream       TYPE REF TO if_ixml_istream,
  lo_parser        TYPE REF TO if_ixml_parser,
  lo_xml           TYPE REF TO if_ixml,
  lo_doc           TYPE REF TO if_ixml_document,
  lo_root          TYPE REF TO if_ixml_element,
  lo_smartform_el  TYPE REF TO if_ixml_element.

*======================================================================*
* START-OF-SELECTION
*======================================================================*
START-OF-SELECTION.

  WRITE: / 'ZTEST_SF_UPLOAD – Smart Form upload via CL_SSF_FB_SMART_FORM'.
  WRITE: / '----------------------------------------------------------'.

* ── 1. Read XML file from the front-end PC ────────────────────────────
  lv_filename = p_file.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_filename
      filetype                = 'BIN'
    IMPORTING
      filelength              = lv_length
    CHANGING
      data_tab                = lt_xdata
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.

  IF sy-subrc <> 0.
    WRITE: / '[ERROR] Could not read file:', lv_filename.
    WRITE: / '        sy-subrc =', sy-subrc.
    RETURN.
  ENDIF.

  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = lv_length
    IMPORTING
      buffer       = lv_xstring
    TABLES
      binary_tab   = lt_xdata
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.

  IF sy-subrc <> 0.
    WRITE: / '[ERROR] Could not convert file to xstring.'.
    RETURN.
  ENDIF.

  WRITE: / 'File read OK :', lv_filename, '(', lv_length, 'bytes ).'.

* ── 2. Parse XML into a DOM ───────────────────────────────────────────
  lo_xml = cl_ixml=>create( ).
  lo_doc = lo_xml->create_document( ).
  lo_streamfactory = lo_xml->create_stream_factory( ).
  lo_istream       = lo_streamfactory->create_istream_xstring( lv_xstring ).
  lo_parser        = lo_xml->create_parser( stream_factory = lo_streamfactory
                                            istream        = lo_istream
                                            document       = lo_doc ).

  IF lo_parser->parse( ) <> 0.
    WRITE: / '[ERROR] XML parse failed.'.
    RETURN.
  ENDIF.

  lo_istream->close( ).
  lo_root = lo_doc->get_root_element( ).
  IF lo_root IS INITIAL.
    WRITE: / '[ERROR] XML has no root element.'.
    RETURN.
  ENDIF.

* ── 3. Locate <sf:SMARTFORM> element (skip <abapGit> wrapper) ──────────
  IF lo_root->get_name( ) CS 'SMARTFORM'.
    lo_smartform_el = lo_root.
  ELSE.
    " abapGit wrapper – take first child
    lo_smartform_el ?= lo_root->get_first_child( ).
    WHILE lo_smartform_el IS NOT INITIAL
       AND NOT lo_smartform_el->get_name( ) CS 'SMARTFORM'.
      lo_smartform_el ?= lo_smartform_el->get_next( ).
    ENDWHILE.
  ENDIF.

  IF lo_smartform_el IS INITIAL.
    WRITE: / '[ERROR] No <SMARTFORM> element found in the XML.'.
    RETURN.
  ENDIF.

  WRITE: / 'XML parsed OK.  Root element:', lo_smartform_el->get_name( ).

* ── 4. Derive the form name from the XML HEADER ────────────────────────
  DATA: lo_header_el TYPE REF TO if_ixml_element,
        lo_fname_el  TYPE REF TO if_ixml_element.

  lo_header_el = lo_smartform_el->find_from_name( 'HEADER' ).
  IF lo_header_el IS NOT INITIAL.
    lo_fname_el = lo_header_el->find_from_name( 'FORMNAME' ).
    IF lo_fname_el IS NOT INITIAL.
      lv_formname = lo_fname_el->get_value( ).
    ENDIF.
  ENDIF.

  IF lv_formname IS INITIAL.
    WRITE: / '[ERROR] FORMNAME not found in XML <HEADER>.'.
    RETURN.
  ENDIF.

  WRITE: / 'Form name from XML:', lv_formname.

* ── 5. Clear leftover EDTFLAG / DELFLAG on the TADIR entry ─────────────
  " A previous broken run with IV_SET_EDTFLAG='X' persisted EDTFLAG='X'
  " in TADIR.  TR_TADIR_INTERFACE with IV_SET_EDTFLAG=' ' does NOT
  " reliably unset that flag — only direct UPDATE does.  Without this,
  " every subsequent upload raises:
  "   "You cannot edit object R3TR SSFO ZTEST_SF with the standard editor"
  DATA: lv_tadir_obj_name TYPE sobj_name,
        ls_tadir          TYPE tadir.
  lv_tadir_obj_name = lv_formname.

  SELECT SINGLE * FROM tadir INTO ls_tadir
    WHERE pgmid    = 'R3TR'
      AND object   = 'SSFO'
      AND obj_name = lv_tadir_obj_name.

  IF sy-subrc = 0 AND ( ls_tadir-edtflag = 'X' OR ls_tadir-delflag = 'X' ).
    UPDATE tadir SET edtflag = ' '
                     delflag = ' '
      WHERE pgmid    = 'R3TR'
        AND object   = 'SSFO'
        AND obj_name = lv_tadir_obj_name.
    COMMIT WORK.
    WRITE: / 'Cleared stale EDTFLAG/DELFLAG on TADIR entry for', lv_formname.
  ENDIF.

* ── 6. Upload via CL_SSF_FB_SMART_FORM (same calls as abapGit) ─────────
  CREATE OBJECT lo_sf.

  TRY.
      lo_sf->enqueue(
        suppress_corr_check = space
        master_language     = p_lang
        mode                = 'INSERT'
        formname            = lv_formname ).

      lo_sf->xml_upload(
        EXPORTING
          dom      = lo_smartform_el
          formname = lv_formname
          language = p_lang
        CHANGING
          sform    = lo_res ).

      lo_res->store(
        im_formname = lo_res->header-formname
        im_language = p_lang
        im_active   = abap_true ).

      lo_sf->dequeue( lv_formname ).

      WRITE: / '✔ Smart Form', lv_formname, 'created/updated and activated.'.
      WRITE: / '  Run report ZTEST_SF_DRIVER with a VBELN to test it.'.

    CATCH cx_ssf_fb INTO lx_error.
      lv_text = lx_error->get_text( ).
      WRITE: / '[ERROR]', lv_text.
      " Best-effort cleanup
      TRY.
          lo_sf->dequeue( lv_formname ).
        CATCH cx_root.
      ENDTRY.
  ENDTRY.
