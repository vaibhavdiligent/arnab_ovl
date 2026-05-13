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

* ── 3. Locate <sf:SMARTFORM> element (to extract FORMNAME only) ────────
  IF lo_root->get_name( ) CS 'SMARTFORM'.
    lo_smartform_el = lo_root.
  ELSE.
    " abapGit wrapper – scan children safely, skipping comment/text nodes
    DATA: lo_child_node TYPE REF TO if_ixml_node,
          lo_child_el   TYPE REF TO if_ixml_element.
    lo_child_node = lo_root->get_first_child( ).
    WHILE lo_child_node IS NOT INITIAL.
      IF lo_child_node->get_type( ) = if_ixml_node=>co_node_element.
        lo_child_el ?= lo_child_node.
        IF lo_child_el->get_name( ) CS 'SMARTFORM'.
          lo_smartform_el = lo_child_el.
          EXIT.
        ENDIF.
      ENDIF.
      lo_child_node = lo_child_node->get_next( ).
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

* ── 5. Pre-delete existing form via FB_DELETE_FORM ─────────────────────
*   abapGit uses FB_DELETE_FORM to remove a Smart Form (see
*   ZCL_ABAPGIT_OBJECT_SSFO->delete).  This function module cleanly
*   removes the form across ALL Smart Forms tables (STXFADM, STXFOBJ,
*   text tables, etc.) — direct SQL on STXFADM alone leaves orphan
*   node rows that cause the next upload to produce duplicate nodes.
  DATA: lv_tadir_obj_name TYPE sobj_name,
        lv_form_check     TYPE stxfadm-formname.
  lv_tadir_obj_name = lv_formname.

  SELECT SINGLE formname FROM stxfadm INTO lv_form_check
    WHERE formname = lv_formname.

  IF sy-subrc = 0.
    WRITE: / 'Form', lv_formname, 'already exists – deleting via FB_DELETE_FORM.'.
    CALL FUNCTION 'FB_DELETE_FORM'
      EXPORTING
        i_formname            = lv_formname
        i_with_dialog         = abap_false
        i_with_confirm_dialog = abap_false
      EXCEPTIONS
        no_form               = 1
        OTHERS                = 2.
    IF sy-subrc = 0.
      WRITE: / '  FB_DELETE_FORM succeeded.'.
    ELSE.
      WRITE: / '  FB_DELETE_FORM returned sy-subrc =', sy-subrc,
               '– falling back to direct table cleanup.'.
      DELETE FROM stxfadm WHERE formname = lv_formname.
    ENDIF.
    " Always also clear the TADIR entry so INSERT mode is unambiguous
    DELETE FROM tadir
      WHERE pgmid    = 'R3TR'
        AND object   = 'SSFO'
        AND obj_name = lv_tadir_obj_name.
    COMMIT WORK.
  ELSE.
    WRITE: / 'No existing form – proceeding directly to INSERT.'.
  ENDIF.

* ── 6. Upload via CL_SSF_FB_SMART_FORM (same calls as abapGit) ─────────
  CREATE OBJECT lo_sf.

  TRY.
      lo_sf->enqueue(
        suppress_corr_check = space
        master_language     = p_lang
        mode                = 'INSERT'
        formname            = lv_formname ).

      " Pass the OUTER document root (the <abapGit> wrapper, or the
      " document root when there is no wrapper).  abapGit itself does:
      "   io_xml->get_raw()->get_root_element()
      " which returns the <abapGit> element.  Passing the inner
      " <sf:SMARTFORM> causes xml_upload to misread the tree structure.
      lo_sf->xml_upload(
        EXPORTING
          dom      = lo_root
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
